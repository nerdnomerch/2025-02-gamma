// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../../contracts/libraries/Position.sol";
import "../../contracts/libraries/Order.sol";
import "../../contracts/libraries/gmx/MarketUtils.sol";
import "../../contracts/interfaces/gmx/IDataStore.sol";
import "../../contracts/interfaces/gmx/IGmxReader.sol";
import "../../contracts/interfaces/gmx/IOrderHandler.sol";
import "../../contracts/interfaces/gmx/IOrderCallbackReceiver.sol";
import "../../contracts/interfaces/IPerpetualVault.sol";
import "../../contracts/interfaces/gmx/IExchangeRouter.sol";
import "../../contracts/interfaces/IGmxProxy.sol";
import {Test, console} from "forge-std/Test.sol";

/**
 * @title GMXUtils
 * @dev Contract for Interaction with GMX.
 *  this contract is not a library and is not recommended for several perpetual vaults to share a GMXUtils contract
 *  We should create one GMXUtils instance for one perpertual vault because all GMX positions are
 *  registered as GMXUtils address in GMX protocol
 */

contract MockGmxUtils is
    IOrderCallbackReceiver,
    Initializable,
    Ownable2StepUpgradeable
{
    using SafeERC20 for IERC20;
    using SafeCast for uint256;
    using Position for Position.Props;

    struct PositionData {
        uint256 sizeInUsd;
        uint256 sizeInTokens;
        uint256 collateralAmount;
        uint256 netValue;
        bool isLong;
    }

    struct OrderQueue {
        bytes32 requestKey;
        bool isSettle;
    }

    bytes32 public constant COLLATERAL_TOKEN =
        keccak256(abi.encode("COLLATERAL_TOKEN"));

    bytes32 public constant SIZE_IN_USD = keccak256(abi.encode("SIZE_IN_USD"));

    bytes32 public constant SIZE_IN_TOKENS =
        keccak256(abi.encode("SIZE_IN_TOKENS"));

    bytes32 public constant COLLATERAL_AMOUNT =
        keccak256(abi.encode("COLLATERAL_AMOUNT"));

    bytes32 public constant ESTIMATED_GAS_FEE_BASE_AMOUNT_V2_1 =
        keccak256(abi.encode("ESTIMATED_GAS_FEE_BASE_AMOUNT_V2_1"));

    bytes32 public constant ESTIMATED_GAS_FEE_PER_ORACLE_PRICE =
        keccak256(abi.encode("ESTIMATED_GAS_FEE_PER_ORACLE_PRICE"));

    bytes32 public constant ESTIMATED_GAS_FEE_MULTIPLIER_FACTOR =
        keccak256(abi.encode("ESTIMATED_GAS_FEE_MULTIPLIER_FACTOR"));

    bytes32 public constant INCREASE_ORDER_GAS_LIMIT =
        keccak256(abi.encode("INCREASE_ORDER_GAS_LIMIT"));

    bytes32 public constant DECREASE_ORDER_GAS_LIMIT =
        keccak256(abi.encode("DECREASE_ORDER_GAS_LIMIT"));

    bytes32 public constant SWAP_ORDER_GAS_LIMIT =
        keccak256(abi.encode("SWAP_ORDER_GAS_LIMIT"));

    bytes32 public constant SINGLE_SWAP_GAS_LIMIT =
        keccak256(abi.encode("SINGLE_SWAP_GAS_LIMIT"));

    bytes32 public constant POSITION_FEE_FACTOR =
        keccak256(abi.encode("POSITION_FEE_FACTOR"));

    bytes32 public constant EXECUTE_ORDER_FEATURE_DISABLED =
        keccak256(abi.encode("EXECUTE_ORDER_FEATURE_DISABLED"));

    bytes32 public constant IS_LONG = keccak256(abi.encode("IS_LONG"));

    bytes32 public constant referralCode = bytes32(0);

    uint256 public constant PRECISION = 1e30;

    uint256 public constant BASIS_POINTS_DIVISOR = 10_000;

    address public orderHandler;
    address public liquidationHandler;
    address public adlHandler;
    IExchangeRouter public gExchangeRouter;
    address public gmxRouter;
    IDataStore public dataStore;
    address public orderVault;
    IGmxReader public gmxReader;
    address public referralStorage;

    address public perpVault;

    OrderQueue public queue;
    uint256 public minEth;

    event ClaimPositiveFundingFees(address token1, uint256 amount1, address token2, uint256 amount2);
    event ClaimPositiveFundingFeeExecutionError(address[], address[], address);

    modifier validCallback(bytes32 key, Order.Props memory order) {
        require(
            msg.sender == address(orderHandler) ||
            msg.sender == address(liquidationHandler) ||
            msg.sender == address(adlHandler),
            "invalid caller"
        );
        require(order.addresses.account == address(this), "not mine");
        _;
    }

    function initialize(
        address _orderHandler,
        address _liquidationHandler,
        address _adlHandler,
        address _gExchangeRouter,
        address _gmxRouter,
        address _dataStore,
        address _orderVault,
        address _gmxReader,
        address _referralStorage
    ) external initializer {
        __Ownable2Step_init();
        orderHandler = _orderHandler;
        liquidationHandler = _liquidationHandler;
        adlHandler = _adlHandler;
        gExchangeRouter = IExchangeRouter(_gExchangeRouter);
        gmxRouter = _gmxRouter;
        dataStore = IDataStore(_dataStore);
        orderVault = _orderVault;
        gmxReader = IGmxReader(_gmxReader);
        referralStorage = _referralStorage;
        minEth = 0.002 ether;
    }

    receive() external payable {}

    function lowerThanMinEth() external view returns (bool) {
        if (address(this).balance >= minEth) return false;
        else return true;
    }

    function queueValue() external view returns (bytes32, bool) {
        return (
            queue.requestKey,
            queue.isSettle
        );
    }

    /**
     * @notice Retrieves the current market prices for a given market.
     * @param market The address of the market to retrieve prices for.
     * @return MarketPrices The data structure containing the current prices for the market's index, long, and short tokens.
     */
    function getMarketPrices(
        address market
    ) public view returns (MarketPrices memory) {
        MarketPrices memory prices;
        MarketProps memory marketInfo = gmxReader.getMarket(
            address(dataStore),
            market
        );
        address oracle = IOrderHandler(orderHandler).oracle();
        prices.indexTokenPrice = IOracle(oracle).getPrimaryPrice(
            marketInfo.indexToken
        );
        prices.longTokenPrice = IOracle(oracle).getPrimaryPrice(
            marketInfo.longToken
        );
        prices.shortTokenPrice = IOracle(oracle).getPrimaryPrice(
            marketInfo.shortToken
        );
        return prices;
    }

    /**
     * @notice Calculates the execution gas limit for a given order type and callback gas limit.
     * @param orderType The type of order (e.g., MarketIncrease, MarketDecrease, etc.).
     * @param _callbackGasLimit The gas limit specified for the callback.
     * @return executionGasLimit The calculated execution gas limit.
     */
    function getExecutionGasLimit(
        Order.OrderType orderType,
        uint256 _callbackGasLimit
    ) public view returns (uint256 executionGasLimit) {
        uint256 baseGasLimit = dataStore.getUint(
            ESTIMATED_GAS_FEE_BASE_AMOUNT_V2_1
        );
        uint256 oraclePriceCount = 5;       //  maximum number of oralce prices
        baseGasLimit +=
            dataStore.getUint(ESTIMATED_GAS_FEE_PER_ORACLE_PRICE) *
            oraclePriceCount;
        uint256 multiplierFactor = dataStore.getUint(
            ESTIMATED_GAS_FEE_MULTIPLIER_FACTOR
        );
        uint256 gasPerSwap = dataStore.getUint(SINGLE_SWAP_GAS_LIMIT);
        uint256 estimatedGasLimit;
        if (orderType == Order.OrderType.MarketIncrease) {
            estimatedGasLimit =
                dataStore.getUint(INCREASE_ORDER_GAS_LIMIT) +
                gasPerSwap;
        } else if (orderType == Order.OrderType.MarketDecrease) {
            estimatedGasLimit =
                dataStore.getUint(DECREASE_ORDER_GAS_LIMIT) +
                gasPerSwap;
        } else if (orderType == Order.OrderType.LimitDecrease) {
            estimatedGasLimit =
                dataStore.getUint(DECREASE_ORDER_GAS_LIMIT) +
                gasPerSwap;
        } else if (orderType == Order.OrderType.StopLossDecrease) {
            estimatedGasLimit =
                dataStore.getUint(DECREASE_ORDER_GAS_LIMIT) +
                gasPerSwap;
        } else if (orderType == Order.OrderType.MarketSwap) {
            estimatedGasLimit =
                dataStore.getUint(SWAP_ORDER_GAS_LIMIT) +
                gasPerSwap;
        }
        // multiply 1.2 (add some buffer) to ensure that the creation transaction does not revert.
        executionGasLimit =
            baseGasLimit +
            ((estimatedGasLimit + _callbackGasLimit) * multiplierFactor) /
            PRECISION;
    }

    /**
     * @notice Callback function called by the GMX order execution controller.
     * @dev This function is invoked after the GMX keeper executes the requested order within the next few blocks.
     * @param requestKey The key of the executed order.
     * @param order The data of the executed order.
     * @param eventData The event data associated with the order execution.
     */
    function afterOrderExecution(
        bytes32 requestKey,
        Order.Props memory order,
        EventLogData memory eventData
    ) external override validCallback(requestKey, order) {
        bytes32 positionKey = keccak256(
            abi.encode(
                address(this),
                order.addresses.market,
                order.addresses.initialCollateralToken,
                order.flags.isLong
            )
        );
        MarketPrices memory prices = getMarketPrices(order.addresses.market);
        // Claim funding fees for non-swap orders
        if (order.numbers.orderType != Order.OrderType.MarketSwap) {
            address[] memory markets = new address[](2);
            address[] memory tokens = new address[](2);
            markets[0] = order.addresses.market;
            markets[1] = order.addresses.market;
            MarketProps memory marketInfo = gmxReader.getMarket(
                address(dataStore),
                order.addresses.market
            );
            tokens[0] = marketInfo.indexToken;
            tokens[1] = marketInfo.shortToken;
            try
                gExchangeRouter.claimFundingFees(markets, tokens, perpVault)
            returns (uint256[] memory claimedAmounts) {
                emit ClaimPositiveFundingFees(tokens[0], claimedAmounts[0], tokens[1], claimedAmounts[1]);
            } catch {
                emit ClaimPositiveFundingFeeExecutionError(markets, tokens, perpVault);
            }
        }
        if (order.numbers.orderType == Order.OrderType.Liquidation) {
            if (eventData.uintItems.items[0].value > 0) {
                IERC20(eventData.addressItems.items[0].value).safeTransfer(perpVault, eventData.uintItems.items[0].value);
            }
            if (eventData.uintItems.items[1].value > 0) {
                IERC20(eventData.addressItems.items[1].value).safeTransfer(perpVault, eventData.uintItems.items[1].value);
            }
            IPerpetualVault(perpVault).afterLiquidationExecution();
        } else if (msg.sender == address(adlHandler)) {
            uint256 sizeInUsd = dataStore.getUint(keccak256(abi.encode(positionKey, SIZE_IN_USD)));
            if (eventData.uintItems.items[0].value > 0) {
                IERC20(eventData.addressItems.items[0].value).safeTransfer(perpVault, eventData.uintItems.items[0].value);
            }
            if (eventData.uintItems.items[1].value > 0) {
                IERC20(eventData.addressItems.items[1].value).safeTransfer(perpVault, eventData.uintItems.items[1].value);
            }
            if (sizeInUsd == 0) {
                IPerpetualVault(perpVault).afterLiquidationExecution();
            }
        } else {
            // Determine output token and amount for swap or decrease orders
            address outputToken;
            uint256 outputAmount;
            if (
                order.numbers.orderType == Order.OrderType.MarketSwap ||
                order.numbers.orderType == Order.OrderType.MarketDecrease
            ) {
                outputToken = eventData.addressItems.items[0].value;
                outputAmount = eventData.uintItems.items[0].value;
            }
            // Construct order result data and notify perpetual vault
            IGmxProxy.OrderResultData memory orderResultData = IGmxProxy.OrderResultData(
                order.numbers.orderType,
                order.flags.isLong,
                order.numbers.sizeDeltaUsd,
                outputToken,
                outputAmount,
                queue.isSettle
            );
            IPerpetualVault(perpVault).afterOrderExecution(requestKey, positionKey, orderResultData, prices);
            delete queue;
        }

    }


    /**
     * @notice Callback function called by the GMX order execution controller.
     * @dev This function is called when the submitted order data is incorrect or when a user cancels their order.
     * @param key The request key of the canceled order.
     * @param order The data of the canceled order.
     */
    function afterOrderCancellation(
        bytes32 key,
        Order.Props memory order,
        EventLogData memory /* eventData */
    ) external override validCallback(key, order) {
        IGmxProxy.OrderResultData memory orderResultData = IGmxProxy
            .OrderResultData(
                order.numbers.orderType,
                order.flags.isLong,
                order.numbers.sizeDeltaUsd,
                address(0),
                0,
                queue.isSettle
            );
        IPerpetualVault(perpVault).afterOrderCancellation(
            key,
            order.numbers.orderType,
            orderResultData
        );
        delete queue;
    }

    /**
     * limit order can be set with greater size than the available amount in the pool
     * so when it reaches to the trigger price, it cannot be executed and be frozen.
     * and at that time, `afterOrderFrozen` is called as a callback function.
     * According to the above rule, `afterOrderFrozen` is never called in our contract logic
     */
    function afterOrderFrozen(
        bytes32 key,
        Order.Props memory order,
        EventLogData memory
    ) external override validCallback(key, order) {}

    /**
     * Callback function from GMX to refund remaining gas.
     * @param key request key
     */
    function refundExecutionFee(
        bytes32 key,
        EventLogData memory
    ) external payable {}

    /**
     * @notice
     *  Returns the remaining execution fee after flow is completed.
     * @param receipient address to receive the remaining fee
     * @param amount amount of the remaining fee
     */
    function refundExecutionFee(address receipient, uint256 amount) external {
        require(msg.sender == perpVault, "invalid caller");
        payable(receipient).transfer(amount);
    }

    /**
     * @notice Sets the address of the perpetual vault.
     * @dev This function can only be called once. It requires the perpetual vault address to be non-zero and not already set.
     * @param _perpVault The address of the perpetual vault.
     */
    function setPerpVault(address _perpVault, address market) external {
        // require(tx.origin == owner(), "not owner");
        require(_perpVault != address(0), "zero address");
        require(perpVault == address(0), "already set");
        perpVault = _perpVault;
        gExchangeRouter.setSavedCallbackContract(market, address(this));
    }

    function setMinEth(uint256 _minEth) external onlyOwner {
        minEth = _minEth;
    }

    /**
     * @notice Creates an order.
     * @dev This function requires the receipient to be the perpetual vault and ensures sufficient ETH balance for the execution fee.
     *      It handles token approvals, transfers, and constructs the order parameters before creating the order via `gExchangeRouter`.
     * @param orderType The type of the order (e.g., MarketIncrease, MarketDecrease, etc.).
     * @param orderData The data associated with the order.
     * @return The request key of the created order.
     */
    function createOrder(
        Order.OrderType orderType,
        IGmxProxy.OrderData memory orderData
    ) public returns (bytes32) {
        require(msg.sender == perpVault, "invalid caller");
        uint256 positionExecutionFee = getExecutionGasLimit(
            orderType,
            orderData.callbackGasLimit
        ) * tx.gasprice;
        require(
            address(this).balance >= positionExecutionFee,
            "insufficient eth balance"
        );

        // check if execution feature is enabled
        bytes32 executeOrderFeatureKey = keccak256(
            abi.encode(
                EXECUTE_ORDER_FEATURE_DISABLED,
                orderHandler,
                orderType
            )
        );
        require(
            dataStore.getBool(executeOrderFeatureKey) == false,
            "gmx execution disabled"
        );

        gExchangeRouter.sendWnt{value: positionExecutionFee}(
            orderVault,
            positionExecutionFee
        );
        if (
            orderType == Order.OrderType.MarketSwap ||
            orderType == Order.OrderType.MarketIncrease
        ) {
            IERC20(orderData.initialCollateralToken).safeApprove(
                address(gmxRouter),
                orderData.amountIn
            );
            gExchangeRouter.sendTokens(
                orderData.initialCollateralToken,
                orderVault,
                orderData.amountIn
            );
        }
        CreateOrderParamsAddresses memory paramsAddresses = CreateOrderParamsAddresses({
                receiver: perpVault,
                cancellationReceiver: address(perpVault),
                callbackContract: address(this),
                uiFeeReceiver: address(0),
                market: orderData.market,
                initialCollateralToken: orderData.initialCollateralToken,
                swapPath: orderData.swapPath
            });

        CreateOrderParamsNumbers memory paramsNumber = CreateOrderParamsNumbers({
                sizeDeltaUsd: orderData.sizeDeltaUsd,
                initialCollateralDeltaAmount: orderData.initialCollateralDeltaAmount,
                triggerPrice: 0,
                acceptablePrice: orderData.acceptablePrice,
                executionFee: positionExecutionFee,
                callbackGasLimit: orderData.callbackGasLimit,
                minOutputAmount: orderData.minOutputAmount,      // this param is used when swapping. is not used in opening position even though swap involved.
                validFromTime: 0
            });
        CreateOrderParams memory params = CreateOrderParams({
            addresses: paramsAddresses,
            numbers: paramsNumber,
            orderType: orderType,
            decreasePositionSwapType: Order
                .DecreasePositionSwapType
                .SwapPnlTokenToCollateralToken,
            isLong: orderData.isLong,
            shouldUnwrapNativeToken: false,
            autoCancel: false,
            referralCode: referralCode
        });

        (bool success, bytes32 requestKey) = gExchangeRouter.createOrderFUZZ(
            params
        );

        require(success, "Order creation failed on GMX exchange router");
        queue.requestKey = requestKey;
        return requestKey;
    }

    /**
     * @notice Settles an order by creating a MarketDecrease order with minimal collateral delta amount.
     * @dev This function calculates the execution fee, ensures sufficient ETH balance, sets up the order parameters,
     *      and creates the order via the `gExchangeRouter`.
     * @param orderData The data associated with the order, encapsulated in an `OrderData` struct.
     * @return The request key of the created order.
     */
    function settle(
        IGmxProxy.OrderData memory orderData
    ) external returns (bytes32) {
        require(msg.sender == perpVault, "invalid caller");
        uint256 positionExecutionFee = getExecutionGasLimit(
            Order.OrderType.MarketDecrease,
            orderData.callbackGasLimit
        ) * tx.gasprice;
        require(
            address(this).balance >= positionExecutionFee,
            "insufficient eth balance"
        );
        gExchangeRouter.sendWnt{value: positionExecutionFee}(
            orderVault,
            positionExecutionFee
        );
        CreateOrderParamsAddresses memory paramsAddresses = CreateOrderParamsAddresses({
                receiver: perpVault,
                cancellationReceiver: address(perpVault),
                callbackContract: address(this),
                uiFeeReceiver: address(0),
                market: orderData.market,
                initialCollateralToken: orderData.initialCollateralToken,
                swapPath: new address[](0)
            });
        CreateOrderParamsNumbers memory paramsNumber = CreateOrderParamsNumbers({
                sizeDeltaUsd: 0,
                initialCollateralDeltaAmount: 1,
                triggerPrice: 0,
                acceptablePrice: 0,
                executionFee: positionExecutionFee,
                callbackGasLimit: orderData.callbackGasLimit,
                minOutputAmount: 0,      // this param is used when swapping. is not used in opening position even though swap involved.
                validFromTime: 0
            });
        CreateOrderParams memory params = CreateOrderParams({
            addresses: paramsAddresses,
            numbers: paramsNumber,
            orderType: Order.OrderType.MarketDecrease,
            decreasePositionSwapType: Order
                .DecreasePositionSwapType
                .SwapPnlTokenToCollateralToken,
            isLong: orderData.isLong,
            shouldUnwrapNativeToken: false,
            autoCancel: false,
            referralCode: referralCode
        });
        bytes32 requestKey = gExchangeRouter.createOrder(params);
        queue.requestKey = requestKey;
        queue.isSettle = true;
        return requestKey;
    }

    /**
     * @notice
     *  GMX keepers would not always execute orders in a reasonable amount of time.
     *  This function is called when the requested Order is not executed in GMX side.
     */
    function cancelOrder() external {
        require(msg.sender == perpVault, "invalid caller");
        require(queue.requestKey != bytes32(0), "zero value");
        gExchangeRouter.cancelOrder(queue.requestKey);
    }

    function claimCollateralRebates(
        address[] memory markets,
        address[] memory tokens,
        uint256[] memory timeKeys,
        address receiver
    ) external {
        require(msg.sender == perpVault, "invalid caller");
        gExchangeRouter.claimCollateral(markets, tokens, timeKeys, receiver);
    }

    /**
     * @notice Withdraws all ETH from the contract to the owner's address.
     * @dev This function can only be called by the owner of the contract.
     * @return The balance of ETH withdrawn from the contract.
     */
    function withdrawEth() external onlyOwner returns (uint256) {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        return balance;
    }

    function updateGmxAddresses(
        address _orderHandler,
        address _liquidationHandler,
        address _adlHandler,
        address _gExchangeRouter,
        address _gmxRouter,
        address _dataStore,
        address _orderVault,
        address _reader,
        address _referralStorage
    ) external onlyOwner {
        orderHandler = _orderHandler;
        liquidationHandler = _liquidationHandler;
        adlHandler = _adlHandler;
        gExchangeRouter = IExchangeRouter(_gExchangeRouter);
        gmxRouter = _gmxRouter;
        dataStore = IDataStore(_dataStore);
        orderVault = _orderVault;
        gmxReader = IGmxReader(_reader);
        referralStorage = _referralStorage;
    }
}
