// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../../contracts/libraries/Order.sol";
// import "../../contracts/libraries/ParaSwapUtils.sol";
import "../../contracts/libraries/Error.sol";
import "../../contracts/interfaces/gmx/IDataStore.sol";
import "../../contracts/interfaces/gmx/IExchangeRouter.sol";
import "../../contracts/interfaces/IPerpetualVault.sol";
import "../../contracts/interfaces/IGmxProxy.sol";
import "../../contracts/interfaces/IVaultReader.sol";

import "./MockParaswapUtils.sol";

/**
 * @notice
 *  a vault contract that trades on GMX market and Paraswap DEX Aggregator
 *  it gets the signal(long/short/close flag and leverage value) from the off-chain script.
 *  if signal is long and leverage is 1x, swap collateral to `indexToken`.
 *  if signal is long with leverage above 1x, open a long position with a specified leverage on gmx market.
 *  if signal is short, open a short position with a specified leverage on gmx market.
 * 
 *  For now, we only support the GMX market in which `indexToken` is the same as `longToken`.
 *  We think the price impact of deposit and withdraw as a swap slippage loss. As if the more swap amount in dex, the much loss we get.
 *  GMX charges negative fee against collateral so collateral amount is decreased over time. It makes leverage value increasing.
 *  We have offchain script to address this. The offchain script monitors leverage value and adjusts when it exceeds the risky value to avoid liquidation.
 */
contract PerpetualVaultLens is IPerpetualVault, Initializable, Ownable2StepUpgradeable, ReentrancyGuardUpgradeable, MockParaSwapUtils {
  using SafeERC20 for IERC20;

  struct SwapProgress {               // swap process involves asynchronous operation so store swap progress data
    bool isCollateralToIndex;         // if swap `collateralToken` to `indexToken`, true and vice versa.
    uint256 swapped;                  // the amount of output token that has already been swapped. 
    uint256 remaining;                // the amount of input token that remains to be swapped
  }

  enum PROTOCOL {
    DEX,
    GMX
  }

  enum FLOW {
    NONE,
    DEPOSIT,
    SIGNAL_CHANGE,
    WITHDRAW,
    COMPOUND,
    LIQUIDATION
  }

  enum NextActionSelector {
    NO_ACTION,                        // state where no action is required
    INCREASE_ACTION,                  // represents increasing actions such as increasing a GMX perps position or increasing a spot position
    SWAP_ACTION,                      // represents swapping a token, either collateral to index or vice versa
    WITHDRAW_ACTION,                  // represents withdrawing funds
    COMPOUND_ACTION,                  // whenver claiming positive funding fee, we could have idle funds in the vault.
                                      //  If it's enough to deposit more into GMX, triggers `COMPOUND_ACTION`.
    SETTLE_ACTION,                    // settle fees and ensure state is up-to-date prior to withdrawals
    FINALIZE
  }

  struct Action {
    NextActionSelector selector;
    bytes data;
  }

  struct DepositInfo {
    uint256 amount;           // amount of deposit
    uint256 shares;           // amount of share corresponding to deposit amount
    address owner;            // depositor address
    uint256 executionFee;     // execution fee
    uint256 timestamp;        // timestamp of deposit
    address recipient;        // address of recipient when withdrawing, which is set at the moment of withdrawal request
  }

  // Vault variables
  uint256 public constant PRECISION = 1e30;
  uint256 public constant BASIS_POINTS_DIVISOR = 10_000;
  uint256 constant ONE_USD = 1e30;

  uint256 public totalShares;
  uint256 public counter;
  mapping (uint256 => DepositInfo) public depositInfo;
  mapping (address => EnumerableSet.UintSet) userDeposits;

  address public market;
  address public indexToken;
  IERC20 public collateralToken;
  IGmxProxy public gmxProxy;
  IVaultReader public vaultReader;
  
  address public keeper;
  address public treasury;
  bytes32 public curPositionKey;        //  current open positionKey
  uint256 public maxDepositAmount;   // max cap of collateral token that can be managrable in vault
  uint256 public minDepositAmount;   // min deposit amount of collateral
  uint256 public totalDepositAmount; // total collateral token amount deposited into the vault
  uint256 public governanceFee;      // percentage of fee to charge
  uint256 public callbackGasLimit;   // gas amount to compensate keeper calls and GMX callback function
  uint256 public lockTime;              // `lockTime` prevents the immediate withdrawal attempts after deposit
  uint256 public leverage;              // GMX position leverage value (decimals is 10000)
  
  Action public nextAction;
  FLOW public flow;
  uint256 flowData;
  bool public beenLong;               // true if current open position is long
  bool public positionIsClosed;       // true if there's no open position
  bool _gmxLock;                      // this is true while gmx action is in progress. i.e. from gmx call to gmx callback
  
  SwapProgress public swapProgressData;      // in order to deal with gmx swap failures, we utilize this struct to keep track of what has already been swapped to avoid overswapping
  bool public depositPaused;           // if true, deposit is paused
  
  //@audit ADDED FUZZING VAR
  bool public cancellationTriggered;

  event Minted(uint256 depositId, address depositor, uint256 shareAmount, uint256 depositAmount);
  event Burned(uint256 depositId, address recipient, uint256 shareAmount, uint256 amount);
  event DexSwap(
    address inputToken,
    uint256 inputAmount,
    address outputToken,
    uint256 outputAmount,
    bool isCollateralToIndex
  );
  event GmxSwap(
    address inputToken, 
    uint256 inputAmount, 
    address outputToken, 
    uint256 outputAmount,
    bool isCollateralToIndex
  );
  event GovernanceFeeCollected(address token, uint256 amount);
  event GmxPositionCallbackCalled(
    bytes32 requestKey,
    bool success
  );
  event GmxPositionUpdated(
    bytes32 positionKey,
    address market,
    bool isOpen,
    bool isLong,
    uint256 sizeInTokens,
    uint256 indexTokenPrice
  );
  event TokenTranferFailed(address recipient, uint256 amount);
  event ExecutionFeeRefundFailed(address recepient, uint256 amount);

  modifier onlyKeeper() {
    if (msg.sender != keeper) {
      revert Error.NotAKeeper();
    }
    _;
  }

  // Lock the contract from the moment we create position to the moment we get the callback from GMX keeper
  modifier gmxLock() {
    if (_gmxLock == true) {
      revert Error.GmxLock();
    }
    _;
  }

  // we prevent user interactions while a flow is still being in progress.
  modifier noneFlow() {
    if (flow != FLOW.NONE) {
      revert Error.FlowInProgress();
    }
    _;
  }

  /**
   * @notice
   *  `collateralToken` can be ETH, WETH, BTC, LINK, UNI, USDC, USDT, DAI, FRAX.
   * @param _market address of GMX market
   * @param _keeper keeper address
   * @param _treasury fee receiver
   * @param _gmxProxy address of GMXUtils contract
   * @param _minDepositAmount minimum deposit amount
   * @param _maxDepositAmount maximum deposit amount
   */
  function initialize(
    address _market,
    address _keeper,
    address _treasury,
    address _gmxProxy,
    address _vaultReader,
    uint256 _minDepositAmount,
    uint256 _maxDepositAmount,
    uint256 _leverage
  ) external initializer {
    __Ownable2Step_init();
    __ReentrancyGuard_init();
    if (
      _market == address(0) ||
      _gmxProxy == address(0) ||
      _keeper == address(0) ||
      _vaultReader == address(0) ||
      _treasury == address(0)
    ) {
      revert Error.ZeroValue();
    }
    market = _market;
    IGmxProxy(_gmxProxy).setPerpVault(address(this), market);
    gmxProxy = IGmxProxy(_gmxProxy);
    MarketProps memory marketInfo = IVaultReader(_vaultReader).getMarket(market);
    indexToken = marketInfo.indexToken;
    collateralToken = IERC20(marketInfo.shortToken);
    keeper = _keeper;
    treasury = _treasury;
    vaultReader = IVaultReader(_vaultReader);
    governanceFee = 500;  // 5%
    minDepositAmount = _minDepositAmount;
    maxDepositAmount = _maxDepositAmount;
    callbackGasLimit = 2_000_000;
    positionIsClosed = true;
    lockTime = 7 * 24 * 3600;                       // 1 week
    leverage = _leverage;
  }

  // function _getSwapProgress() public view returns (uint, uint) {
  //       uint swappedData = swapProgressData.swapped;
  //       uint remainingData = swapProgressData.remaining;
  //       return (swappedData, remainingData);
  //   }

    function _getGMXLock() public view returns (bool) {
        return _gmxLock;
    }

    function getGmxUtilsAddress() public view returns (address) {
        return address(gmxProxy);
    }

    function getPositionInfo(
        MarketPrices memory prices
    )
        external
        view
        returns (address, address, uint256, uint256, uint256, uint256, bool)
    {
        IVaultReader.PositionData memory positionData = vaultReader.getPositionInfo(
            curPositionKey,
            prices
        );
        return (
            market,
            address(collateralToken),
            positionData.sizeInUsd,
            positionData.sizeInTokens,
            positionData.collateralAmount,
            positionData.netValue,
            positionData.isLong
        );
    }

    function getRequestKey(address vault) public view returns (bytes32 requestKey) {
        (requestKey, ) = IGmxProxy(gmxProxy).queue();
    }

    function checkForCleanStart() public view returns (bool) {
        return (uint(nextAction.selector) == 0 &&
            cancellationTriggered == false); //NOTE: wasn't cancelled for any reason
    }

  /**
  * @notice Deposits collateral tokens into the vault.
  * @dev This function checks if deposits are paused, validates the deposit amount,
  *      and transfers the collateral tokens from the sender to the contract.
  *      If the position is closed, it directly mints shares for the deposit amount.
  *      If the position is open, it sets up the next action to register the requested position params.
  * @param amount The amount of collateral tokens to deposit.
  */
  function deposit(uint256 amount) external nonReentrant noneFlow payable {
    if (depositPaused == true) {
      revert Error.Paused();
    }
    if (amount < minDepositAmount) {
      revert Error.InsufficientAmount();
    }
    if (totalDepositAmount + amount > maxDepositAmount) {
      revert Error.ExceedMaxDepositCap();
    }

    cancellationTriggered = false;

    flow = FLOW.DEPOSIT;
    collateralToken.safeTransferFrom(msg.sender, address(this), amount);
    counter++;
    depositInfo[counter] = DepositInfo(amount, 0, msg.sender, 0, block.timestamp, address(0));
    totalDepositAmount += amount;
    EnumerableSet.add(userDeposits[msg.sender], counter);

    if (positionIsClosed) {
      MarketPrices memory prices;
      _mint(counter, amount, false, prices);
      _finalize(hex'');
    } else {
      _payExecutionFee(counter, true);
      // mint share token in the NextAction to involve off-chain price data and improve security
      nextAction.selector = NextActionSelector.INCREASE_ACTION;
      nextAction.data = abi.encode(beenLong);
    }
  }


  /**
  * @notice Withdraws collateral of user.
  * @dev If position is GMX position, first call `settle` function to settle pending fees 
  *   in order to avoid charging all fees from the withdrawer.
  * @param recipient The address to receive the tokens.
  * @param depositId The deposit ID to withdraw.
  */
  function withdraw(address recipient, uint256 depositId) public payable nonReentrant noneFlow {
    cancellationTriggered = false;

    flow = FLOW.WITHDRAW;
    flowData = depositId;

    if (recipient == address(0)) {
      revert Error.ZeroValue();
    }
    if (depositInfo[depositId].timestamp + lockTime >= block.timestamp) {
      revert Error.Locked();
    }
    if (EnumerableSet.contains(userDeposits[msg.sender], depositId) == false) {
      revert Error.InvalidUser();
    }
    if (depositInfo[depositId].shares == 0) {
      revert Error.ZeroValue();
    }

    depositInfo[depositId].recipient = recipient;
    _payExecutionFee(depositId, false);
    if (curPositionKey != bytes32(0)) {
      nextAction.selector = NextActionSelector.WITHDRAW_ACTION;
      _settle();  // Settles any outstanding fees and updates state before processing withdrawal
    } else {
      MarketPrices memory prices;
      _withdraw(depositId, hex'', prices);
    }
  }


  /**
  * @notice Off-chain script calls `run` function to change position type (long/short/close).
  * @param isOpen If true, open a position; if false, close the current position.
  * @param isLong If true, open a long position; if false, open a short position.
  * @param prices GMX price data of market tokens from GMX API call.
  * @param metadata Swap transaction data generated by off-chain script.
  */
  function run(
    bool isOpen,
    bool isLong,
    MarketPrices memory prices,
    bytes[] memory metadata
  ) external nonReentrant noneFlow onlyKeeper {
    if (gmxProxy.lowerThanMinEth()) {
      revert Error.LowerThanMinEth();
    }

    cancellationTriggered = false; //NOTE: added by fuzzer

    flow = FLOW.SIGNAL_CHANGE;

    if (isOpen) {
      if (positionIsClosed) {
        if (_isFundIdle() == false) {
          revert Error.InsufficientAmount();
        }
        if (_isLongOneLeverage(isLong)) {
          _runSwap(metadata, true, prices);
        } else {
          (uint256 acceptablePrice) = abi.decode(metadata[0], (uint256));
          _createIncreasePosition(isLong, acceptablePrice, prices);
        }
      } else {
        if (beenLong == isLong) {
          revert Error.NoAction();
        } else {
          // Close current position first and then open the requested position in the next action
          nextAction.selector = NextActionSelector.INCREASE_ACTION;
          nextAction.data = abi.encode(isLong);
          if (_isLongOneLeverage(beenLong)) {
            _runSwap(metadata, false, prices);
          } else {
            (uint256 acceptablePrice) = abi.decode(metadata[0], (uint256));
            _createDecreasePosition(0, 0, beenLong, acceptablePrice, prices);
          }
        }
      }
    } else {
      if (positionIsClosed == false) {
        if (_isLongOneLeverage(beenLong)) {
          _runSwap(metadata, false, prices);
        } else {
          (uint256 acceptablePrice) = abi.decode(metadata[0], (uint256));
          _createDecreasePosition(0, 0, beenLong, acceptablePrice, prices);
        }
      } else {
        revert Error.NoAction();
      }
    }
  }


  /**
   * @notice `flow` is not completed in one tx. So in that case, set up the next action data 
   *  and run the `nextAction`.
   * @param prices GMX price data of market tokens from GMX API call
   * @param metadata swap tx data. generated by off-chain script
   */
  function runNextAction(MarketPrices memory prices, bytes[] memory metadata) external nonReentrant gmxLock onlyKeeper {
    cancellationTriggered = false;

    Action memory _nextAction = nextAction;
    delete nextAction;
    if (_nextAction.selector == NextActionSelector.INCREASE_ACTION) {
      (bool _isLong) = abi.decode(_nextAction.data, (bool));

      if (_isLongOneLeverage(_isLong)) {
        _runSwap(metadata, true, prices);
      } else {
        // swap indexToken that could be generated from the last action into collateralToken
        // use only DexSwap
        if (
          IERC20(indexToken).balanceOf(address(this)) * prices.indexTokenPrice.min >= ONE_USD
        ) {
          (, bytes memory data) = abi.decode(metadata[1], (PROTOCOL, bytes));
          _doDexSwap(data, false);
        }
        (uint256 acceptablePrice) = abi.decode(metadata[0], (uint256));
        _createIncreasePosition(_isLong, acceptablePrice, prices);
      }
    } else if (_nextAction.selector == NextActionSelector.WITHDRAW_ACTION) {
      // swap indexToken that could be generated from settle action or liquidation/ADL into collateralToken
      // use only DexSwap
      if (
        IERC20(indexToken).balanceOf(address(this)) * prices.indexTokenPrice.min >= ONE_USD
      ) {
        (, bytes memory data) = abi.decode(metadata[1], (PROTOCOL, bytes));
        _doDexSwap(data, false);
      }
      uint256 depositId = flowData;
      _withdraw(depositId, metadata[0], prices);
    } else if (_nextAction.selector == NextActionSelector.SWAP_ACTION) {
      (, bool isCollateralToIndex) = abi.decode(
        _nextAction.data,
        (uint256, bool)
      );
      _runSwap(metadata, isCollateralToIndex, prices);
    } else if (_nextAction.selector == NextActionSelector.SETTLE_ACTION) {
      _settle();
    } else if (_nextAction.selector == NextActionSelector.FINALIZE) {
      if (
        IERC20(indexToken).balanceOf(address(this)) * prices.indexTokenPrice.min >= ONE_USD
      ) {
        (, bytes memory data) = abi.decode(metadata[1], (PROTOCOL, bytes));
        _doDexSwap(data, false);
      }
      _finalize(_nextAction.data);
    } else if (positionIsClosed == false && _isFundIdle()) {
      flow = FLOW.COMPOUND;
      if (_isLongOneLeverage(beenLong)) {
        _runSwap(metadata, true, prices);
      } else {
        (uint256 acceptablePrice) = abi.decode(metadata[0], (uint256));
        _createIncreasePosition(beenLong, acceptablePrice, prices);
      }
    } else {
      revert Error.InvalidCall();
    }
  }

  /**
   * @notice
   *  Cancel the current ongoing flow.
   * @dev
   *  In the case of 1x long leverage, we never cancel the ongoing flow.
   *  In the case of gmx position, we could cancel current ongoing 
   *   flow due to some accidents from our side or gmx side.
   */
  function cancelFlow() external nonReentrant gmxLock onlyKeeper {
    _cancelFlow();
  }

  /**
   * @notice Cancel order when order is not executed from GMX side
   *  Cancelling order is valid after the expiration time has passed since the order request is registered.
   */
  function cancelOrder() external nonReentrant onlyKeeper {
    if (_gmxLock == false) {
      revert Error.InvalidCall();
    }
    IGmxProxy(gmxProxy).cancelOrder();
  }

  /**
   * @notice
   *  GMX cap negative price impact on decrease orders. 
   *  If a trade is closed with a price impact higher than this percentage,
   *   then the additional impact would become claimable after a few days.
   *  This function is used to claim this manually.
   *  Resolves who and how much via off-chain script
   */
  function claimCollateralRebates(uint256[] memory timeKeys) external nonReentrant noneFlow onlyKeeper {
    address[] memory markets = new address[](1);
    markets[0] = market;
    address[] memory tokens = new address[](1);
    tokens[0] = address(collateralToken);

    IGmxProxy(gmxProxy).claimCollateralRebates(markets, tokens, timeKeys, treasury);
  }

  /**
  * @notice Callback function that is called when an order on GMX is executed successfully.
  *   This function handles the post-execution logic based on the type of order that was executed. 
  * @dev This callback function must never be reverted. It should wrap revertible external calls with `try-catch`.
  * @param requestKey The request key of the executed order.
  * @param positionKey The position key.
  * @param orderResultData Data from the order execution.
  */
  function afterOrderExecution(
    bytes32 requestKey,
    bytes32 positionKey,
    IGmxProxy.OrderResultData memory orderResultData,
    MarketPrices memory prices
  ) external nonReentrant {
    if (msg.sender != address(gmxProxy)) {
      revert Error.InvalidCall();
    }
    // MarketPrices memory marketPrices = gmxProxy.getMarketPrices(market);
    
    _gmxLock = false;
    // If the current action is `settle`
    if (orderResultData.isSettle) {
      nextAction.selector = NextActionSelector.WITHDRAW_ACTION;
      emit GmxPositionCallbackCalled(requestKey, true);
      return;
    }
    if (orderResultData.orderType == Order.OrderType.MarketIncrease) {
      curPositionKey = positionKey;
      if (flow == FLOW.DEPOSIT) {
        uint256 amount = depositInfo[counter].amount;
        uint256 feeAmount = vaultReader.getPositionFeeUsd(market, orderResultData.sizeDeltaUsd, false) / prices.shortTokenPrice.min;
        uint256 prevSizeInTokens = flowData;
        int256 priceImpact = vaultReader.getPriceImpactInCollateral(curPositionKey, orderResultData.sizeDeltaUsd, prevSizeInTokens, prices);
        uint256 increased;
        if (priceImpact > 0) {
          increased = amount - feeAmount - uint256(priceImpact) - 1;
        } else {
          increased = amount - feeAmount + uint256(-priceImpact) - 1;
        }
        _mint(counter, increased, false, prices);
        nextAction.selector = NextActionSelector.FINALIZE;
      } else {
        _updateState(false, orderResultData.isLong);
      }
    } else if (orderResultData.orderType == Order.OrderType.MarketDecrease) {
      uint256 sizeInUsd = vaultReader.getPositionSizeInUsd(curPositionKey);
      if (sizeInUsd == 0) {
        delete curPositionKey;
      }
      if (flow == FLOW.WITHDRAW) {
        nextAction.selector = NextActionSelector.FINALIZE;
        uint256 prevCollateralBalance = collateralToken.balanceOf(address(this)) - orderResultData.outputAmount;
        nextAction.data = abi.encode(prevCollateralBalance, sizeInUsd == 0, false);
      } else {
        _updateState(true, false);
      }
    } else if (orderResultData.orderType == Order.OrderType.MarketSwap) {
      uint256 outputAmount = orderResultData.outputAmount;
      if (swapProgressData.isCollateralToIndex) {
        emit GmxSwap(
          address(collateralToken),
          swapProgressData.remaining,
          indexToken,
          outputAmount,
          true
        );
      } else {
        emit GmxSwap(
          indexToken,
          swapProgressData.remaining,
          address(collateralToken),
          outputAmount,
          false
        );
      }
      
      if (flow == FLOW.DEPOSIT) {
        _mint(counter, outputAmount + swapProgressData.swapped, false, prices);
        _finalize(hex'');
      } else if (flow == FLOW.WITHDRAW) {
        _handleReturn(outputAmount + swapProgressData.swapped, false, false);
      } else {  // Same as if (flow == FLOW.SIGNAL_CHANGE || FLOW.COMPOUND)
        if (orderResultData.outputToken == indexToken) {
          _updateState(false, true);
        } else {
          _updateState(true, false);
        }
      }
    }

    cancellationTriggered = false;
    
    emit GmxPositionCallbackCalled(requestKey, true);
    if (flow == FLOW.SIGNAL_CHANGE) {
      emit GmxPositionUpdated(
        positionKey,
        market,
        orderResultData.orderType == Order.OrderType.MarketIncrease,
        orderResultData.isLong,
        orderResultData.sizeDeltaUsd,
        prices.indexTokenPrice.min
      );
    }
  }

  /**
   * @notice handles the liquidation and adl order execution result.
   * @dev keep the positionIsClosed value so that let the keeper be able to 
   *  create an order again with the liquidated fund
   */
  function afterLiquidationExecution() external {
    if (msg.sender != address(gmxProxy)) {
      revert Error.InvalidCall();
    }

    depositPaused = true;
    uint256 sizeInTokens = vaultReader.getPositionSizeInTokens(curPositionKey);
    if (sizeInTokens == 0) {
      delete curPositionKey;
    }

    if (flow == FLOW.NONE) {
      flow = FLOW.LIQUIDATION;
      nextAction.selector = NextActionSelector.FINALIZE;
    } else if (flow == FLOW.DEPOSIT) {
      flowData = sizeInTokens;
    } else if (flow == FLOW.WITHDRAW) {
      // restart the withdraw flow even though current step is FINALIZE.
      nextAction.selector = NextActionSelector.WITHDRAW_ACTION;
    }
  }


  /**
  * @notice Callback function triggered when an order execution on GMX is canceled due to an error.
  * @param requestKey The request key of the executed order.
  * @param orderType The type of order.
  * @param orderResultData The result data of the order execution.
  */
  function afterOrderCancellation(
    bytes32 requestKey,
    Order.OrderType orderType,
    IGmxProxy.OrderResultData memory orderResultData
  ) external {
    if (msg.sender != address(gmxProxy)) {
      revert Error.InvalidCall();
    }
    _gmxLock = false;

    if (orderResultData.isSettle) {
      // Retry settle action.
      nextAction.selector = NextActionSelector.SETTLE_ACTION;
    } else if (orderType == Order.OrderType.MarketSwap) {
      // If GMX swap fails, retry in the next action.
      nextAction.selector = NextActionSelector.SWAP_ACTION;
      // abi.encode(swapAmount, swapDirection): if swap direction is true, swap collateralToken to indexToken
      nextAction.data = abi.encode(swapProgressData.remaining, swapProgressData.isCollateralToIndex);
    } else {
      if (flow == FLOW.DEPOSIT) {
        nextAction.selector = NextActionSelector.INCREASE_ACTION;
        nextAction.data = abi.encode(beenLong);
      } else if (flow == FLOW.WITHDRAW) {
        nextAction.selector = NextActionSelector.WITHDRAW_ACTION;
      } else {
        // If signal change fails, the offchain script starts again from the current status.
        delete flowData;
        delete flow;
      }
    }

    cancellationTriggered = true;

    emit GmxPositionCallbackCalled(requestKey, false);
  }

  //////////////////////////////
  ////    View Functions    ////
  //////////////////////////////

  /**
   * @notice
   *  return total value of vault in terms of collteral token
   * @param prices gmx price data of market tokens that is from gmx api call
   */
  function totalAmount(MarketPrices memory prices) external view returns (uint256) {
    return _totalAmount(prices);
  }

  /**
   * @notice
   *  get all deposit ids of a user
   * @param user address of a user
   */
  function getUserDeposits(address user) external view returns (uint256[] memory depositIds) {
    uint256 length = EnumerableSet.length(userDeposits[user]);
    depositIds = new uint256[](length);
    for (uint8 i = 0; i < length; ) {
      depositIds[i] = EnumerableSet.at(userDeposits[user], i);
      unchecked {
        i = i + 1;
      }
    }
  }

  /**
   * @notice
   *  get the estimated execution fee amount to run deposit or withdrawal
   */
  function getExecutionGasLimit(bool isDeposit) public view returns (uint256 minExecutionGasLimit) {
    if (positionIsClosed == false) {
      if (_isLongOneLeverage(beenLong)) {
        minExecutionGasLimit = gmxProxy.getExecutionGasLimit(Order.OrderType.MarketSwap, callbackGasLimit);
      } else {
        if (isDeposit) {
          minExecutionGasLimit = gmxProxy.getExecutionGasLimit(Order.OrderType.MarketIncrease, callbackGasLimit);
        } else {
          // withdraw action has 2 gmx call parts: settle + decrease position
          minExecutionGasLimit = gmxProxy.getExecutionGasLimit(Order.OrderType.MarketDecrease, callbackGasLimit) * 2;
        }
      }
    }
  }

  /**
   * @notice
   *  check if there is the next action
   */
  function isNextAction() external view returns (NextActionSelector) {
    if (_gmxLock) {
      return NextActionSelector.NO_ACTION;
    } else if (nextAction.selector != NextActionSelector.NO_ACTION) {
      return nextAction.selector;
    } else if (positionIsClosed == false && _isFundIdle()) {
      return NextActionSelector.COMPOUND_ACTION;
    } else {
      return NextActionSelector.NO_ACTION;
    }
  }

  /**
  * @notice Checks if the contract is currently busy.
  * @return bool Returns true if the contract is busy, false otherwise.
  */
  function isBusy() external view returns (bool) {
    return flow != FLOW.NONE;
  }

  /**
  * @notice Checks if the GMX lock is currently active.
  * @return bool Returns true if the GMX lock is active, false otherwise.
  */
  function isLock() external view returns (bool) {
    return _gmxLock;
  }

  /**
  * @notice Sets the keeper address.
  * @param _keeper The address of the new keeper.
  */
  function setKeeper(address _keeper) external onlyOwner {
    if (_keeper == address(0)) revert Error.ZeroValue();
    keeper = _keeper;
  }

  /**
  * @notice Sets the treasury address.
  * @param _treasury The address of the new treasury.
  */
  function setTreasury(address _treasury) external onlyOwner {
    if (_treasury == address(0)) revert Error.ZeroValue();
    treasury = _treasury;
  }

  function setMinMaxDepositAmount(uint256 _minDepositAmount, uint256 _maxDepositAmount) external onlyOwner {
    minDepositAmount = _minDepositAmount;
    maxDepositAmount = _maxDepositAmount;
  }

  /**
  * @notice Sets the callback gas limit.
  * @param _callbackGasLimit The new callback gas limit.
  */
  function setCallbackGasLimit(uint256 _callbackGasLimit) external onlyOwner {
    callbackGasLimit = _callbackGasLimit;
  }

  /**
  * @notice Sets the lock time.
  * @param _lockTime The new lock time.
  */
  function setLockTime(uint256 _lockTime) external onlyOwner {
    lockTime = _lockTime;
  }

  /**
  * @notice Sets the deposit paused state.
  * @param _depositPaused If true, deposits are paused; if false, deposits are active.
  */
  function setDepositPaused(bool _depositPaused) external onlyOwner {
    depositPaused = _depositPaused;
  }

  function setVaultReader(address _vaultReader) external onlyOwner {
    vaultReader = IVaultReader(_vaultReader);
  }

  
  //////////////////////////////
  ////  Internal Functions  ////
  //////////////////////////////

  /**
   * @notice this function is an end of deposit flow.
   * @dev should update all necessary global state variables
   * 
   * @param depositId `depositId` of mint operation
   * @param amount actual deposit amount. if `_isLongOneLeverage` is `true`, amount of `indexToken`, or amount of `collateralToken`
   */
  function _mint(uint256 depositId, uint256 amount, bool refundFee, MarketPrices memory prices) internal {
    uint256 _shares;
    if (totalShares == 0) {
      _shares = depositInfo[depositId].amount * 1e8;
    } else {
      uint256 totalAmountBefore;
      if (positionIsClosed == false && _isLongOneLeverage(beenLong)) {
        totalAmountBefore = IERC20(indexToken).balanceOf(address(this)) - amount;
      } else {
        totalAmountBefore = _totalAmount(prices) - amount;
      }
      if (totalAmountBefore == 0) totalAmountBefore = 1;
      _shares = amount * totalShares / totalAmountBefore;
    }

    depositInfo[depositId].shares = _shares;
    totalShares = totalShares + _shares;

    if (refundFee) {
      uint256 usedFee = callbackGasLimit * tx.gasprice;
      if (depositInfo[counter].executionFee > usedFee) {
        try IGmxProxy(gmxProxy).refundExecutionFee(depositInfo[counter].owner, depositInfo[counter].executionFee - usedFee) {} catch {}
      }
    }

    emit Minted(depositId, depositInfo[depositId].owner, _shares, amount);
  }

  /**
   * burn shares corresponding to `depositId`
   * @param depositId `depositId` to burn
   */
  function _burn(uint256 depositId) internal {
    EnumerableSet.remove(userDeposits[depositInfo[depositId].owner], depositId);
    totalShares = totalShares - depositInfo[depositId].shares;
    delete depositInfo[depositId];
  }

  /**
   * @notice
   *  Any excess execution fee from GMX call is not refunded to the user.
   */
  function _payExecutionFee(uint256 depositId, bool isDeposit) internal {
    uint256 minExecutionFee = getExecutionGasLimit(isDeposit) * tx.gasprice;

    if (msg.value < minExecutionFee) {
      revert Error.InsufficientAmount();
    }
    if (msg.value > 0) {
      payable(address(gmxProxy)).transfer(msg.value);
      depositInfo[depositId].executionFee = msg.value;
    }
  }

  /**
  * @notice Calculates the total value of the vault in terms of collateral token.
  * @param prices GMX price data of market tokens from GMX API call.
  * @return The total value of the vault in terms of collateral token.
  */
  function _totalAmount(MarketPrices memory prices) internal view returns (uint256) {
    if (positionIsClosed) {
      return collateralToken.balanceOf(address(this));
    } else {
      IVaultReader.PositionData memory positionData = vaultReader.getPositionInfo(curPositionKey, prices);
      uint256 total = IERC20(indexToken).balanceOf(address(this)) * prices.indexTokenPrice.min / prices.shortTokenPrice.min
          + collateralToken.balanceOf(address(this))
          + positionData.netValue / prices.shortTokenPrice.min;

      return total;
    }
  }


  /**
  * @notice Checks if the contract has idle collateral funds that meet the minimum deposit amount.
  * @return bool Returns true if the idle collateral funds are greater than or equal to the minimum deposit amount, false otherwise.
  */
  function _isFundIdle() internal view returns (bool) {
    if (collateralToken.balanceOf(address(this)) >= minDepositAmount) {
      return true;
    } else {
      return false;
    }
  }


  /**
  * @notice Creates an increase position request.
  * @dev We register position information with GMX peripheral contracts to open perp positions.
  *      This function doesn't open the position actually; it just registers the request of creating position.
  *      The actual opening/closing is done by a keeper of the GMX vault.
  * @param _isLong If true, the position is long; if false, the position is short.
  */
  function _createIncreasePosition(
    bool _isLong,
    uint256 acceptablePrice,
    MarketPrices memory prices
  ) internal {
    // Check available amounts to open positions
    uint256 amountIn;
    if (flow == FLOW.DEPOSIT) {
      amountIn = depositInfo[counter].amount;
      flowData = vaultReader.getPositionSizeInTokens(curPositionKey);
    } else {
      amountIn = collateralToken.balanceOf(address(this));
    }

    Order.OrderType orderType = Order.OrderType.MarketIncrease;
    collateralToken.safeTransfer(address(gmxProxy), amountIn);
    uint256 sizeDelta = prices.shortTokenPrice.max * amountIn * leverage / BASIS_POINTS_DIVISOR;
    console.log("sizeDelta: %s", sizeDelta);
    IGmxProxy.OrderData memory orderData = IGmxProxy.OrderData({
      market: market,
      indexToken: indexToken,
      initialCollateralToken: address(collateralToken),
      swapPath: new address[](0),
      isLong: _isLong,
      sizeDeltaUsd: sizeDelta,
      initialCollateralDeltaAmount: 0,
      amountIn: amountIn,
      callbackGasLimit: callbackGasLimit,
      acceptablePrice: acceptablePrice,
      minOutputAmount: 0
    });
    _gmxLock = true;
    
    try gmxProxy.createOrder(orderType, orderData) {} catch {
      cancellationTriggered = true;
      require(cancellationTriggered == false, "Order creation failed");
    }
  }


  /**
  * @notice Creates a decrease position request.
  * @dev We register position information with GMX peripheral contracts to open perp positions.
  *      This function doesn't close the position actually; it just registers the request of creating position.
  *      The actual opening/closing is done by a keeper of the GMX vault.
  * @param collateralDeltaAmount The token amount of collateral to withdraw.
  * @param sizeDeltaInUsd The USD value of the change in position size (decimals is 30).
  * @param _isLong If true, the position is long; if false, the position is short.
  */
  function _createDecreasePosition(
    uint256 collateralDeltaAmount,
    uint256 sizeDeltaInUsd,
    bool _isLong,
    uint256 acceptablePrice,
    MarketPrices memory prices
  ) internal {
    address[] memory swapPath;
    Order.OrderType orderType = Order.OrderType.MarketDecrease;
    uint256 sizeInUsd = vaultReader.getPositionSizeInUsd(curPositionKey);
    if (
      sizeDeltaInUsd == 0 ||
      vaultReader.willPositionCollateralBeInsufficient(
        prices,
        curPositionKey,
        market,
        _isLong,
        sizeDeltaInUsd,
        collateralDeltaAmount
      )
    ) {
      sizeDeltaInUsd = sizeInUsd;
    }
    IGmxProxy.OrderData memory orderData = IGmxProxy.OrderData({
      market: market,
      indexToken: indexToken,
      initialCollateralToken: address(collateralToken),
      swapPath: swapPath,
      isLong: _isLong,
      sizeDeltaUsd: sizeDeltaInUsd,
      initialCollateralDeltaAmount: collateralDeltaAmount,
      amountIn: 0,
      callbackGasLimit: callbackGasLimit,
      acceptablePrice: acceptablePrice,
      minOutputAmount: 0
    });
    _gmxLock = true;
    
    try gmxProxy.createOrder(orderType, orderData) {} catch {
      cancellationTriggered = true;
      require(cancellationTriggered == false, "Order creation failed");
    }
  }



  /**
  * @notice Settles all pending fees (borrowing fee, negative funding fee) against collateral 
  *   to process withdrawal requests correctly.
  * @dev GMX applies all pending fees against collateral when updating the position, which can 
  *   result that the current withdrawer suffers all fees of entire position.
  *  This function calls `settle` to pay out fees against collateral so that fee deduction 
  *   from GMX positions is ignored in the withdrawal process.
  */
  function _settle() internal {
    IGmxProxy.OrderData memory orderData = IGmxProxy.OrderData({
      market: market,
      indexToken: indexToken,
      initialCollateralToken: address(collateralToken),
      swapPath: new address[](0),
      isLong: beenLong,
      sizeDeltaUsd: 0,
      initialCollateralDeltaAmount: 0,
      amountIn: 0,
      callbackGasLimit: callbackGasLimit,
      acceptablePrice: 0,
      minOutputAmount: 0
    });
    _gmxLock = true;
    gmxProxy.settle(orderData);
  }


  /**
  * @dev Swap data is an array of swap data and is passed from an off-chain script.
  *      It could contain only Paraswap data, GMX swap data, or both of them.
  *      If both are included, the first element of the array should always be Paraswap.
  * @param metadata Bytes array that includes swap data.
  * @param isCollateralToIndex Direction of swap. If true, swap `collateralToken` to `indexToken`.
  * @return completed If true, the swap action is completed; if false, the swap action will continue.
  */
  function _runSwap(bytes[] memory metadata, bool isCollateralToIndex, MarketPrices memory prices) internal returns (bool completed) {
    if (metadata.length == 0) {
      revert Error.InvalidData();
    }
    if (metadata.length == 2) {
      (PROTOCOL _protocol, bytes memory data) = abi.decode(metadata[0], (PROTOCOL, bytes));
      if (_protocol != PROTOCOL.DEX) {
        revert Error.InvalidData();
      }
      swapProgressData.swapped = swapProgressData.swapped + _doDexSwap(data, isCollateralToIndex);
      
      (_protocol, data) = abi.decode(metadata[1], (PROTOCOL, bytes));
      if (_protocol != PROTOCOL.GMX) {
        revert Error.InvalidData();
      }

      _doGmxSwap(data, isCollateralToIndex);
      return false;
    } else {
      if (metadata.length != 1) {
        revert Error.InvalidData();
      }
      (PROTOCOL _protocol, bytes memory data) = abi.decode(metadata[0], (PROTOCOL, bytes));
      if (_protocol == PROTOCOL.DEX) {
        uint256 outputAmount = _doDexSwap(data, isCollateralToIndex);
        
        // update global state
        if (flow == FLOW.DEPOSIT) {
          // last `depositId` equals with `counter` because another deposit is not allowed before previous deposit is completely processed
          _mint(counter, outputAmount + swapProgressData.swapped, true, prices);
        } else if (flow == FLOW.WITHDRAW) {
          _handleReturn(outputAmount + swapProgressData.swapped, false, true);
        } else {
          // in the flow of SIGNAL_CHANGE, if `isCollateralToIndex` is true, it is opening position, or closing position
          _updateState(!isCollateralToIndex, isCollateralToIndex);
        }
        
        return true;
      } else {
        _doGmxSwap(data, isCollateralToIndex);
        return false;
      }
    }
  }


  /**
  * @dev Executes a DEX swap using Paraswap.
  * @param data Swap transaction data.
  * @param isCollateralToIndex Direction of swap. If true, swap `collateralToken` to `indexToken`.
  * @return outputAmount The amount of output tokens received from the swap.
  */
  function _doDexSwap(bytes memory data, bool isCollateralToIndex) internal returns (uint256 outputAmount) {
    (address to, uint256 amount, bytes memory callData) = abi.decode(data, (address, uint256, bytes));
    IERC20 inputToken;
    IERC20 outputToken;
    if (isCollateralToIndex) {
      inputToken = collateralToken;
      outputToken = IERC20(indexToken);
    } else {
      inputToken = IERC20(indexToken);
      outputToken = collateralToken;
    }
    uint256 balBefore = outputToken.balanceOf(address(this));
    swap(to, callData);
    outputAmount = IERC20(outputToken).balanceOf(address(this)) - balBefore;
    emit DexSwap(address(inputToken), amount, address(outputToken), outputAmount, isCollateralToIndex);
  }


  /**
  * @dev Executes a GMX swap.
  * @param data Swap transaction data.
  * @param isCollateralToIndex Direction of swap. If true, swap `collateralToken` to `indexToken`.
  */
  function _doGmxSwap(bytes memory data, bool isCollateralToIndex) internal {
    Order.OrderType orderType = Order.OrderType.MarketSwap;
    (address[] memory gPath, uint256 amountIn, uint256 minOutputAmount) = abi.decode(data, (address[], uint256, uint256));
    swapProgressData.remaining = amountIn;
    swapProgressData.isCollateralToIndex = isCollateralToIndex;

    address tokenIn;
    if (isCollateralToIndex) {
      tokenIn = address(collateralToken);
    } else {
      tokenIn = address(indexToken);
    }
    IERC20(tokenIn).safeTransfer(address(gmxProxy), amountIn);
    
    IGmxProxy.OrderData memory orderData = IGmxProxy.OrderData({
      market: address(0),
      indexToken: address(0),
      initialCollateralToken: tokenIn,
      swapPath: gPath,
      isLong: isCollateralToIndex,    // this param has no meaning in swap order, but uses it to see the swap direction
      sizeDeltaUsd: 0,
      initialCollateralDeltaAmount: 0,
      amountIn: amountIn,
      callbackGasLimit: callbackGasLimit,
      acceptablePrice: 0,
      minOutputAmount: minOutputAmount
    });
    _gmxLock = true;
    
    try gmxProxy.createOrder(orderType, orderData) {} catch {
      cancellationTriggered = true;
      require(false, "Order creation failed");
    }
  }


  /**
  * @notice Handles the internal withdrawal process for a given deposit ID.
  * @dev This function calculates the share of the withdrawal, handles the swap if necessary, 
  *      and updates the position accordingly.
  * @param depositId The ID of the deposit to withdraw.
  */
  function _withdraw(uint256 depositId, bytes memory metadata, MarketPrices memory prices) internal {
    uint256 shares = depositInfo[depositId].shares;
    if (shares == 0) {
      revert Error.ZeroValue();
    }
    
    if (positionIsClosed) {
      _handleReturn(0, true, false);
    } else if (_isLongOneLeverage(beenLong)) {  // beenLong && leverage == BASIS_POINTS_DIVISOR
      uint256 swapAmount = IERC20(indexToken).balanceOf(address(this)) * shares / totalShares;
      nextAction.selector = NextActionSelector.SWAP_ACTION;
      // abi.encode(swapAmount, swapDirection): if swap direction is true, swap collateralToken to indexToken
      nextAction.data = abi.encode(swapAmount, false);
    } else if (curPositionKey == bytes32(0)) {    // vault liquidated
      _handleReturn(0, true, false);
    } else {
      IVaultReader.PositionData memory positionData = vaultReader.getPositionInfo(curPositionKey, prices);
      uint256 collateralDeltaAmount = positionData.collateralAmount * shares / totalShares;
      uint256 sizeDeltaInUsd = positionData.sizeInUsd * shares / totalShares;
      // we always charge the position fee of negative price impact case.
      uint256 feeAmount = vaultReader.getPositionFeeUsd(market, sizeDeltaInUsd, false) / prices.shortTokenPrice.max;
      int256 pnl = vaultReader.getPnl(curPositionKey, prices, sizeDeltaInUsd);
      if (pnl < 0) {
        collateralDeltaAmount = collateralDeltaAmount - feeAmount - uint256(-pnl) / prices.shortTokenPrice.max;
      } else {
        collateralDeltaAmount = collateralDeltaAmount - feeAmount;
      }
      uint256 acceptablePrice = abi.decode(metadata, (uint256));
      _createDecreasePosition(collateralDeltaAmount, sizeDeltaInUsd, beenLong, acceptablePrice, prices);
    }
  }


  /**
   * @notice this function is an end of withdrawal flow.
   * @dev should update all necessary global state variables
   * 
   * @param withdrawn amount of token withdrawn from the position
   * @param positionClosed true when position is closed completely by withdrawing all funds, or false
   */
  function _handleReturn(uint256 withdrawn, bool positionClosed, bool refundFee) internal {
    (uint256 depositId) = flowData;
    uint256 shares = depositInfo[depositId].shares;
    uint256 amount;
    if (positionClosed) {
      amount = collateralToken.balanceOf(address(this)) * shares / totalShares;
    } else {
      uint256 balanceBeforeWithdrawal = collateralToken.balanceOf(address(this)) - withdrawn;
      amount = withdrawn + balanceBeforeWithdrawal * shares / totalShares;
    }
    if (amount > 0) {
      _transferToken(depositId, amount);
    }
    emit Burned(depositId, depositInfo[depositId].recipient, depositInfo[depositId].shares, amount);
    _burn(depositId);

    if (refundFee) {
      uint256 usedFee = callbackGasLimit * tx.gasprice;
      if (depositInfo[depositId].executionFee > usedFee) {
        try IGmxProxy(gmxProxy).refundExecutionFee(depositInfo[counter].owner, depositInfo[counter].executionFee - usedFee) {} catch {}
      }
    }

    // update global state
    delete swapProgressData;
    delete flowData;
    delete flow;
  }

  /**
   * @dev Collect fee from the withdraw amount and transfer tokens to the user.
   *  Collect fee only when the user got the profit.
   */
  function _transferToken(uint256 depositId, uint256 amount) internal {
    uint256 fee;
    if (amount > depositInfo[depositId].amount) {
      fee = (amount - depositInfo[depositId].amount) * governanceFee / BASIS_POINTS_DIVISOR;
      if (fee > 0) {
        collateralToken.safeTransfer(treasury, fee);
      }
    }
    
    try collateralToken.transfer(depositInfo[depositId].recipient, amount - fee) {}
    catch  {
      collateralToken.transfer(treasury, amount - fee);
      emit TokenTranferFailed(depositInfo[depositId].recipient, amount - fee);
    }
    totalDepositAmount -= depositInfo[depositId].amount;
    
    emit GovernanceFeeCollected(address(collateralToken), fee);
  }

  /**
   * update global state in every steps of signal change action 
   * @param _positionIsClosed flag whether position is closed or not
   * @param _isLong isLong value
   */
  function _updateState(
    bool _positionIsClosed,
    bool _isLong
  ) internal {
    if (flow == FLOW.SIGNAL_CHANGE) {
      positionIsClosed = _positionIsClosed;
      if (_positionIsClosed == false) {
        beenLong = _isLong;
      }
    }
    
    if (nextAction.selector == NextActionSelector.NO_ACTION) {
      if (_isLongOneLeverage(_isLong)) {
        delete flowData;
        delete flow;
      } else {
        nextAction.selector = NextActionSelector.FINALIZE;
      }
    }
    delete swapProgressData;
  }

  function _finalize(bytes memory data) internal {
    if (flow == FLOW.WITHDRAW) {
      (uint256 prevCollateralBalance, bool positionClosed, bool refundFee) = abi.decode(data, (uint256, bool, bool));
      uint256 withdrawn = collateralToken.balanceOf(address(this)) - prevCollateralBalance;
      _handleReturn(withdrawn, positionClosed, refundFee);
    } else {
      delete swapProgressData;
      delete flowData;
      delete flow;
    }
  }

  function _cancelFlow() internal {
    if (flow == FLOW.DEPOSIT) {
      uint256 depositId = counter;
      collateralToken.safeTransfer(depositInfo[depositId].owner, depositInfo[depositId].amount);
      totalDepositAmount = totalDepositAmount - depositInfo[depositId].amount;
      EnumerableSet.remove(userDeposits[depositInfo[depositId].owner], depositId);
      try IGmxProxy(gmxProxy).refundExecutionFee(
        depositInfo[counter].owner,
        depositInfo[counter].executionFee
      ) {} catch {}
      delete depositInfo[depositId];
    } else if (flow == FLOW.WITHDRAW) {
      try IGmxProxy(gmxProxy).refundExecutionFee(
        depositInfo[counter].owner,
        depositInfo[counter].executionFee
      ) {} catch {}
    }
    
    // Setting flow to liquidation has no meaning.
    // The aim is to run FINAIZE action. (swap indexToken to collateralToken);
    flow = FLOW.LIQUIDATION;
    nextAction.selector = NextActionSelector.FINALIZE;
  }

  /**
  * @notice Checks if the position is a long position with 1x leverage.
  * @param _isLong If true, the position is a 1x long position.
  * @return bool Returns true if the position is a long position with 1x leverage, false otherwise.
  */
  function _isLongOneLeverage(bool _isLong) internal view returns (bool) {
    return _isLong && leverage == BASIS_POINTS_DIVISOR;
  }
}
