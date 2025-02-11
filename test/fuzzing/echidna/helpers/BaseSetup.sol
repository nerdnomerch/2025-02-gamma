// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../config/FuzzConfig.sol";
import "../interfaces/IMockDex.sol";

contract BaseSetup is FuzzConfig {
    mapping(address => uint256) internal tokenMinAmounts;
    mapping(address => uint256) internal tokenMaxAmounts;
    mapping(address => uint256) internal tokenMinPrice;
    mapping(address => uint256) internal tokenMaxPrice;

    /**
      .-",
     `~ ||
        ||___ GAMMA Structs
        (':.)`
        || ||
        || ||
       ^^ ^^	
 */
    struct DepositInfo {
        uint256 amount;
        uint256 shares;
        address owner;
        uint256 timestamp;
        address recipient;
    }
    enum PROTOCOL {
        DEX,
        GMX
    }

    struct SwapProgress {
        // swap process involves asynchronous operation so store swap progress data
        bool isCollateralToIndex; // if swap `collateralToken` to `indexToken`, true and vice versa.
        uint256 swapped; // the amount of output token that has already been swapped.
        uint256 remaining; // the amount of input token that remains to be swapped
    }

    enum NextActionSelector {
        NO_ACTION, // state where no action is required
        INCREASE_ACTION, // represents increasing actions such as increasing a GMX perps position or increasing a spot position
        SWAP_ACTION, // represents swapping a token, either collateral to index or vice versa
        WITHDRAW_ACTION, // represents withdrawing funds
        COMPOUND_ACTION, // whenver claiming positive funding fee, we could have idle funds in the vault.
        //  If it's enough to deposit more into GMX, triggers `COMPOUND_ACTION`.
        SETTLE_ACTION, // settle fees and ensure state is up-to-date prior to withdrawals
        FINALIZE
    }

    enum FLOW {
        NONE,
        DEPOSIT,
        SIGNAL_CHANGE,
        WITHDRAW,
        COMPOUND
    }

    struct UserState {
        uint USDCBalance;
        uint256 totalAmount;
        uint256 totalShares;
        uint256[] depositIds;
        mapping(uint256 => uint) deposits; //depositID => deposit amount
        uint256 lastDepositTimestamp;
        uint256 shareValue;
    }
    struct Action {
        NextActionSelector selector;
        bytes data;
    }
    struct VaultInfo {
        mapping(address => UserState) userStates;
        uint256 totalAmount;
        uint256 vaultUSDCBalance;
        uint256 totalSharesCalculated;
        uint256 oldestDepositTimestamp;
        uint256 newestDepositTimestamp;
        uint256 totalShares;
        uint256 counter;
        bytes32 curPositionKey;
        uint256 totalDepositAmount;
        bool beenLong;
        bool positionIsClosed;
        bool gmxLock;
        bool isBusy;
        bool isLocked;
        NextActionSelector nextActionSelector;
        uint treasuryBalance;
        uint256 shareValue;
        uint256 totalFees;
        uint256 collateralAmount;
    }
    struct State {
        mapping(address => VaultInfo) vaultInfos;
    }

    mapping(uint8 => State) internal states;

    struct gammaWithdrawal {
        address user;
        address vault;
        uint256 depositId;
    }

    gammaWithdrawal internal withdrawalAssertionInputs;

    /**
      .-",
     `~ ||
        ||___ DEPOSIT Structs
        (':.)`
        || ||
        || ||
       ^^ ^^	
 */

    struct DepositorParams {
        address user;
        uint256 longAmount;
        uint256 shortAmount;
        bool isWETH;
    }

    struct DepositParams {
        address receiver;
        address callbackContract;
        address uiFeeReceiver;
        address[] longTokenSwapPath;
        address[] shortTokenSwapPath;
        uint256 minMarketTokens;
        bool shouldUnwrapNativeToken;
        uint256 executionFee;
        uint256 callbackGasLimit;
    }

    struct DepositCreated {
        DepositState beforeDepositExec;
        DepositParams depositParams;
        DepositorParams depositorParams;
        DepositUtils.CreateDepositParams createDepositParams;
        address[] longSwapPath;
        address[] shortSwapPath;
        bytes32 key;
        TokenPrices tokenPrices;
    }

    struct DepositState {
        address market;
        address user;
        uint marketTotalSupply;
        uint userBalanceMarket;
        uint userBalanceLong;
        uint userBalanceShort;
        uint vaultBalanceLong;
        uint vaultBalanceShort;
        uint simulateDepositAmountOut;
        uint longAmountFromParams;
        uint shortAmountFromParams;
    }

    /**
      .-",
     `~ ||
        ||___ SHIFT Structs
        (':.)`
        || ||
        || ||
       ^^ ^^	
 */

    struct ShiftCreated {
        ShiftState beforeExec;
        ShiftUtils.CreateShiftParams createShiftParams;
        uint marketTokenAmount;
        bytes32 key;
    }

    struct ShiftMarketData {
        int marketTokenPriceFrom;
        int marketTokenPriceTo;
        uint simulateLongTokenAmountWithdrawal;
        uint simulateShortTokenAmountWithdrawal;
    }

    struct ShiftState {
        ShiftUtils.CreateShiftParams createShiftParams;
        ShiftMarketData marketDataBefore;
        ShiftMarketData marketDataAfter;
        uint marketTokenAmount;
        TokenPrices tokenPrices;
        address user;
        uint marketFromBalance;
        uint marketToBalance;
        uint longTokenPoolAmountMarketFrom;
        uint shortTokenPoolAmountMarketFrom;
        uint longTokenPoolAmountMarketTo;
        uint shortTokenPoolAmountMarketTo;
        uint longTokenMarketFeeAmountMarketFrom;
        uint shortTokenMarketFeeAmountMarketFrom;
    }

    /**
      .-",
     `~ ||
        ||___ POSITION Structs
        (':.)`
        || ||
        || ||
       ^^ ^^	
 */

    struct OrderCreated {
        IBaseOrderUtils.CreateOrderParams createOrderParams;
        bytes32 key;
        uint256 updatedAt;
        address user;
        bytes32 handlerType;
        uint amountSent;
        bool isClose;
        uint8 swapPathSeed;
        TokenPrices tokenPrices;
        uint executionFee;
    }

    struct PositionState {
        uint sizeInUsd;
        uint sizeInTokens;
        uint collateralAmount;
        bool isLong;
        uint OILong;
        uint OILongLatestMarket;
        uint OIShort;
        uint collateralSumLong;
        uint collateralSumShort;
        uint balanceOfLongToken;
        uint balanceOfShortToken;
    }

    struct SwapState {
        uint balanceOfOutputToken;
        uint balanceOfInputToken;
        address outputToken;
        SwapResult swapResult;
    }

    struct SwapResult {
        uint256 amountOut;
        uint256 amountAfterFees;
        int256 totalImpactAmount;
        SwapPricingUtils.SwapFees totalFees;
    }

    struct GetAmountsOutCache {
        Market.Props market;
        MarketUtils.MarketPrices prices;
        address currentToken;
        uint currentAmount;
        address uiFeeReceiver;
    }
    /**
      .-",
     `~ ||
        ||___ WITHDRAWAL Structs
        (':.)`
        || ||
        || ||
       ^^ ^^	
 */

    struct WithdrawalCreated {
        WithdrawalUtils.CreateWithdrawalParams withdrawalParams;
        uint amount;
        bytes32 withdrawalKey;
    }

    struct WithdrawalState {
        uint userBalance;
        uint vaultBalance;
        uint marketTokenTotalSupply;
        uint longTokenBalanceMarketVault;
        uint shortTokenBalanceMarketVault;
        uint longTokenBalanceUser;
        uint shortTokenBalanceUser;
        uint simulateLongTokenAmountWithdrawal;
        uint simulateShortTokenAmountWithdrawal;
        uint nativeTokenBalanceUser;
    }

    struct MarketData {
        Market.Props marketFromProps;
        Market.Props marketToProps;
        Market.Props marketToUpdate;
    }

    struct TokenPrices {
        address[] tokens;
        uint[] maxPrices;
        uint[] minPrices;
    }

    // GAMMA Fuzzing helpers

    function _logFlow(address vault) internal {
        PerpetualVault.FLOW currentFlow = PerpetualVault(vault).flow();
        uint flowValue = uint(currentFlow);

        if (flowValue == 0) {
            fl.log("EXECUTE ORDER: FLOW NONE");
        } else if (flowValue == 1) {
            fl.log("EXECUTE ORDER: DEPOSIT");
        } else if (flowValue == 2) {
            fl.log("EXECUTE ORDER: SIGNAL_CHANGE");
        } else if (flowValue == 3) {
            fl.log("EXECUTE ORDER: WITHDRAW");
        } else if (flowValue == 4) {
            fl.log("EXECUTE ORDER: COMPOUND");
        } else {
            fl.log("EXECUTE ORDER: UNKNOWN FLOW");
        }
    }
    function logNextAction(address vault) internal {
        PerpetualVault perpetualVault = PerpetualVault(vault);

        (
            PerpetualVault.NextActionSelector selector,
            bytes memory data
        ) = perpetualVault.nextAction();

        if (selector == PerpetualVault.NextActionSelector.NO_ACTION) {
            fl.log("Next action is NO_ACTION");
        } else if (
            selector == PerpetualVault.NextActionSelector.INCREASE_ACTION
        ) {
            fl.log("Next action is INCREASE_ACTION");
        } else if (selector == PerpetualVault.NextActionSelector.SWAP_ACTION) {
            fl.log("Next action is SWAP_ACTION");
        } else if (
            selector == PerpetualVault.NextActionSelector.WITHDRAW_ACTION
        ) {
            fl.log("Next action is WITHDRAW_ACTION");
        } else if (
            selector == PerpetualVault.NextActionSelector.COMPOUND_ACTION
        ) {
            fl.log("Next action is COMPOUND_ACTION");
        } else if (
            selector == PerpetualVault.NextActionSelector.SETTLE_ACTION
        ) {
            fl.log("Next action is SETTLE_ACTION");
        } else if (selector == PerpetualVault.NextActionSelector.FINALIZE) {
            fl.log("Next action is FINALIZE");
        } else {
            fl.log("Unknown next action");
        }
    }

    function _gamma_getVault(
        uint8 seed
    ) internal returns (address, uint, address, address) {
        uint256 vaultIndex = seed % 6;
        if (vaultIndex == 0) {
            return (
                vault_GammaVault1x_WETHUSDC,
                1,
                market_WETH_WETH_USDC,
                gmxUtils_GammaVault1x_WETHUSDC
            );
        } else if (vaultIndex == 1) {
            return (
                vault_GammaVault2x_WETHUSDC,
                2,
                market_WETH_WETH_USDC,
                gmxUtils_GammaVault2x_WETHUSDC
            );
        } else if (vaultIndex == 2) {
            return (
                vault_GammaVault3x_WETHUSDC,
                3,
                market_WETH_WETH_USDC,
                gmxUtils_GammaVault3x_WETHUSDC
            );
        } else if (vaultIndex == 3) {
            return (
                vault_GammaVault1x_WBTCUSDC,
                1,
                market_WBTC_WBTC_USDC,
                gmxUtils_GammaVault1x_WBTCUSDC
            );
        } else if (vaultIndex == 4) {
            return (
                vault_GammaVault2x_WBTCUSDC,
                2,
                market_WBTC_WBTC_USDC,
                gmxUtils_GammaVault2x_WBTCUSDC
            );
        } else {
            return (
                vault_GammaVault3x_WBTCUSDC,
                3,
                market_WBTC_WBTC_USDC,
                gmxUtils_GammaVault3x_WBTCUSDC
            );
        }
    }
    function getConvertedMarketPrices(
        address market,
        uint256 priceSeed
    ) internal returns (MarketPrices memory) {
        MarketUtils.MarketPrices memory prices = _getMarketPrices(
            market,
            _setTokenPrices(priceSeed)
        );

        MarketPrices memory convertedPrices = MarketPrices({
            indexTokenPrice: PriceProps({
                min: prices.indexTokenPrice.min,
                max: prices.indexTokenPrice.max
            }),
            longTokenPrice: PriceProps({
                min: prices.longTokenPrice.min,
                max: prices.longTokenPrice.max
            }),
            shortTokenPrice: PriceProps({
                min: prices.shortTokenPrice.min,
                max: prices.shortTokenPrice.max
            })
        });

        return convertedPrices;
    }
    function _getRandomDepositId(
        uint8 seed,
        address user,
        address vault
    ) internal view returns (uint256) {
        uint256[] memory depositIds = PerpetualVault(vault).getUserDeposits(
            user
        );

        require(depositIds.length > 0, "No deposits found for the user");

        if (depositIds.length == 1) {
            return depositIds[0];
        }

        uint256 randomIndex = seed % depositIds.length;
        return depositIds[randomIndex];
    }

    function constructSwapCalldata(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address vault
    ) public returns (bytes memory) {
        // Allocate memory for swapCalldata (4 + 7 * 32 = 228 bytes)
        bytes memory swapCalldata = new bytes(228);
        bytes4 selector = 0x89fe039b;

        assembly {
            // Get the pointer to the free memory
            let ptr := add(swapCalldata, 32)
            // Store the function selector in the first 4 bytes
            mstore(ptr, selector)
            // Store tokenIn
            mstore(add(ptr, 4), tokenIn) //from token
            // Store tokenOut
            mstore(add(ptr, 36), tokenOut) //to token
            // Store amountIn
            mstore(add(ptr, 68), amountIn)
            // Store amountOutMin
            mstore(add(ptr, 100), amountOutMin)
            // Store placeholder address(0)
            mstore(add(ptr, 132), 0)
            // Store placeholder address(0)
            mstore(add(ptr, 164), vault) //to 196
        }

        // Construct the data for _doDexSwap
        bytes memory dexSwapData = abi.encode(
            PARASWAP_ROUTER,
            amountIn,
            swapCalldata
        );

        // Construct the final calldata for _runSwap
        bytes memory finalCalldata = abi.encode(PROTOCOL.DEX, dexSwapData);

        address valueAt196;
        assembly {
            valueAt196 := mload(add(swapCalldata, 196))
        }

        return finalCalldata;
    }

    function constructGMXCalldata(
        uint8 seed,
        uint256 amountIn
    ) internal returns (bytes memory finalCalldata) {
        address[] memory gmxpath = _getSwapPath(seed);
        bytes memory dexSwapData = abi.encode(gmxpath, amountIn, 0); //min output amount hardcoded at 0
        finalCalldata = abi.encode(PROTOCOL.GMX, dexSwapData);
    }

    function getPositionCollateral(
        address vault
    ) public returns (uint collateralAmount) {
        if (PerpetualVault(vault).curPositionKey() != bytes32(0)) {
            ReaderPositionUtils.PositionInfo memory positionInfo = reader
                .getPositionInfo(
                    dataStore,
                    referralStorage,
                    PerpetualVault(vault).curPositionKey(),
                    _getMarketPrices(
                        vaultToMarket[vault],
                        _setTokenPrices(5000e4)
                    ), //any price, checking for collateral
                    uint256(0),
                    address(0),
                    true
                );

            collateralAmount = positionInfo.position.numbers.collateralAmount;
        }
    }

    function checkNextAction(address vault) public view returns (bool isLong) {
        PerpetualVault perpetualVault = PerpetualVault(vault);

        (, bytes memory data) = perpetualVault.nextAction();

        (isLong) = abi.decode(data, (bool));
    }

    function isNextNoAction(
        address vault
    ) public view returns (bool isNoAction) {
        PerpetualVault perpetualVault = PerpetualVault(vault);

        (PerpetualVault.NextActionSelector selector, ) = perpetualVault
            .nextAction();

        if (selector == PerpetualVault.NextActionSelector.NO_ACTION) {
            return true;
        }
        return false;
    }

    function isNextFinalize(
        address vault
    ) public view returns (bool isFinalize) {
        PerpetualVault perpetualVault = PerpetualVault(vault);

        (PerpetualVault.NextActionSelector selector, ) = perpetualVault
            .nextAction();

        if (selector == PerpetualVault.NextActionSelector.FINALIZE) {
            return true;
        }
        return false;
    }
    function isNextSettle(address vault) public view returns (bool isSettle) {
        PerpetualVault perpetualVault = PerpetualVault(vault);

        (PerpetualVault.NextActionSelector selector, ) = perpetualVault
            .nextAction();

        if (selector == PerpetualVault.NextActionSelector.SETTLE_ACTION) {
            return true;
        }
        return false;
    }

    function isNextWithdraw(
        address vault
    ) public view returns (bool isFinalize) {
        PerpetualVault perpetualVault = PerpetualVault(vault);

        (PerpetualVault.NextActionSelector selector, ) = perpetualVault
            .nextAction();

        if (selector == PerpetualVault.NextActionSelector.WITHDRAW_ACTION) {
            return true;
        }
        return false;
    }
    function isNextSwap(address vault) public view returns (bool isSwap) {
        PerpetualVault perpetualVault = PerpetualVault(vault);

        (PerpetualVault.NextActionSelector selector, ) = perpetualVault
            .nextAction();

        if (selector == PerpetualVault.NextActionSelector.SWAP_ACTION) {
            return true;
        }
        return false;
    }
    // GMX Fuzzing helpers

    // Percentage diff inspired by EBTC suite
    //https://github.com/ebtc-protocol/ebtc/blob/3406f0d88ac9935da53f7371fb078d11c066802e/packages/contracts/contracts/TestContracts/invariants/Asserts.sol#L31
    function eqPercentageDiff(
        uint256 a,
        uint256 b,
        uint256 maxPercentDiff,
        string memory reason
    ) internal {
        uint256 percentDiff;

        if (a == b) return;

        if (a > b) {
            percentDiff = ((a - b) * 1e30) / ((a + b) / 2);
        } else {
            percentDiff = ((b - a) * 1e30) / ((a + b) / 2);
        }

        if (percentDiff > maxPercentDiff) {
            fl.log("a>b, a: ", a);
            fl.log("a>b, b:", b);
            fl.log(
                "Percentage difference is bigger than expected",
                percentDiff
            );
            fl.t(false, reason);
        } else {
            fl.t(true, "Invariant ok, ckeched for: ");
            fl.log(reason);
            fl.log("Percentage difference: ", percentDiff);
        }
    }

    //General utils

    function _setTokenPrices(
        uint priceSeed
    ) internal returns (TokenPrices memory) {
        address[] memory tokens = new address[](5);
        uint[] memory maxPrices = new uint[](5);
        uint[] memory minPrices = new uint[](5);

        tokens[0] = address(WETH);
        tokens[1] = address(WBTC);
        tokens[2] = address(USDT);
        tokens[3] = address(USDC);
        tokens[4] = address(SOL);

        for (uint i = 0; i < tokens.length; i++) {
            (minPrices[i], maxPrices[i]) = _getTokenPrices(
                tokens[i],
                priceSeed
            );
        }

        TokenPrices memory tokenPrices = TokenPrices({
            tokens: tokens,
            maxPrices: maxPrices,
            minPrices: minPrices
        });

        return tokenPrices;
    }
    function _getTokenPrices(
        address token,
        uint256 price
    ) internal returns (uint256 minPrice, uint256 maxPrice) {
        tokenMinPrice[address(WETH)] = WETH_MIN_PRICE;
        tokenMinPrice[address(WBTC)] = WBTC_MIN_PRICE;
        tokenMinPrice[address(USDT)] = USDT_MIN_PRICE;
        tokenMinPrice[address(USDC)] = USDC_MIN_PRICE;
        tokenMinPrice[address(SOL)] = SOL_MIN_PRICE;

        tokenMaxPrice[address(WETH)] = WETH_MAX_PRICE;
        tokenMaxPrice[address(WBTC)] = WBTC_MAX_PRICE;
        tokenMaxPrice[address(USDT)] = USDT_MAX_PRICE;
        tokenMaxPrice[address(USDC)] = USDC_MAX_PRICE;
        tokenMaxPrice[address(SOL)] = SOL_MAX_PRICE;

        minPrice = clampBetween(
            price,
            tokenMinPrice[token],
            tokenMaxPrice[token]
        );

        maxPrice = clampBetween(
            price,
            tokenMinPrice[token],
            tokenMaxPrice[token]
        );

        if (minPrice > maxPrice) {
            (minPrice, maxPrice) = (maxPrice, minPrice);
        }
    }

    function _getTokenPrice(
        address token,
        TokenPrices memory tokenPrices
    ) internal returns (uint) {
        //RETURNS MAX PRICE
        for (uint i = 0; i < tokenPrices.tokens.length; i++) {
            if (tokenPrices.tokens[i] == token) {
                return tokenPrices.maxPrices[i] * (10 ** _getPrecision(token));
            }
        }

        revert("Token was not found");
    }

    function _getTokenAmounts(
        uint longAmount,
        uint shortAmount,
        address longToken,
        address shortToken,
        address user
    ) internal returns (uint longAmountClamped, uint shortAmountClamped) {
        tokenMaxAmounts[address(WETH)] = address(user).balance;
        tokenMaxAmounts[address(WBTC)] = WBTC_MAX_AMOUNT;
        tokenMaxAmounts[address(USDT)] = USDT_MAX_AMOUNT;
        tokenMaxAmounts[address(USDC)] = USDC_MAX_AMOUNT;
        tokenMaxAmounts[address(SOL)] = SOL_MAX_AMOUNT;

        tokenMinAmounts[address(WETH)] = WETH_MIN_AMOUNT;
        tokenMinAmounts[address(WBTC)] = WBTC_MIN_AMOUNT;
        tokenMinAmounts[address(USDT)] = USDT_MIN_AMOUNT;
        tokenMinAmounts[address(USDC)] = USDC_MIN_AMOUNT;
        tokenMinAmounts[address(SOL)] = SOL_MIN_AMOUNT;

        longAmountClamped = clampBetween(
            longAmount,
            tokenMinAmounts[longToken],
            tokenMaxAmounts[longToken]
        );
        shortAmountClamped = clampBetween(
            shortAmount,
            tokenMinAmounts[shortToken],
            tokenMaxAmounts[shortToken]
        );
    }

    /**Lib functions */

    function _getPoolAmount(
        DataStore dataStore,
        Market.Props memory market,
        address token
    ) internal view returns (uint256) {
        uint256 divisor = getPoolDivisor(market.longToken, market.shortToken);
        return
            dataStore.getUint(Keys.poolAmountKey(market.marketToken, token)) /
            divisor;
    }
    function getPoolDivisor(
        address longToken,
        address shortToken
    ) internal pure returns (uint256) {
        return longToken == shortToken ? 2 : 1;
    }
    /*
     *HELPERS
     *
     */

    function _getClaimableFeeAmount(
        address market,
        address token
    ) internal returns (uint) {
        bytes32 CLAIMABLE_FEE_AMOUNT = keccak256(
            abi.encode("CLAIMABLE_FEE_AMOUNT")
        );
        bytes32 key = keccak256(
            abi.encode(CLAIMABLE_FEE_AMOUNT, market, token)
        );
        uint256 feeAmount = dataStore.getUint(key);
    }

    function _getRandomUser(uint8 input) internal returns (address) {
        uint256 randomIndex = input % USERS.length;
        return USERS[randomIndex];
    }

    function _getMarketAddress(uint8 index) internal view returns (address) {
        uint256 marketIndex = index % 6;

        if (marketIndex == 0) {
            return market_WETH_WETH_USDC;
        } else if (marketIndex == 1) {
            return market_WETH_WETH_USDT;
        } else if (marketIndex == 2) {
            return market_0_WETH_USDC;
        } else {
            return market_WBTC_WBTC_USDC;
        }
    }

    function _getRandomToken(uint8 index) internal view returns (address) {
        uint tokenIndex = index % 4;

        if (tokenIndex == 0) {
            return address(USDC);
        } else if (tokenIndex == 1) {
            return address(WBTC);
        } else if (tokenIndex == 2) {
            return address(USDT);
        } else {
            return address(WETH);
        }
    }

    function _getMarketPrices(
        address marketToUpdate,
        TokenPrices memory tokenPrices
    ) internal returns (MarketUtils.MarketPrices memory prices) {
        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            marketToUpdate
        );

        Price.Props memory indexTokenPrice;
        Price.Props memory longTokenPrice;
        Price.Props memory shortTokenPrice;

        for (uint256 i = 0; i < tokenPrices.tokens.length; i++) {
            if (tokenPrices.tokens[i] == marketProps.indexToken) {
                indexTokenPrice = Price.Props({
                    min: tokenPrices.minPrices[i] *
                        (10 ** _getPrecision(marketProps.indexToken)),
                    max: tokenPrices.maxPrices[i] *
                        (10 ** _getPrecision(marketProps.indexToken))
                });
            }

            if (tokenPrices.tokens[i] == marketProps.longToken) {
                longTokenPrice = Price.Props({
                    min: tokenPrices.minPrices[i] *
                        (10 ** _getPrecision(marketProps.longToken)),
                    max: tokenPrices.maxPrices[i] *
                        (10 ** _getPrecision(marketProps.longToken))
                });
            }

            if (tokenPrices.tokens[i] == marketProps.shortToken) {
                shortTokenPrice = Price.Props({
                    min: tokenPrices.minPrices[i] *
                        (10 ** _getPrecision(marketProps.shortToken)),
                    max: tokenPrices.maxPrices[i] *
                        (10 ** _getPrecision(marketProps.shortToken))
                });
            }
        }

        return
            MarketUtils.MarketPrices({
                indexTokenPrice: indexTokenPrice,
                longTokenPrice: longTokenPrice,
                shortTokenPrice: shortTokenPrice
            });
    }

    function _getPrecision(address token) internal view returns (uint256) {
        if (token == address(WETH)) {
            return 8;
        } else if (token == address(WBTC)) {
            return 20;
        } else if (token == address(USDC) || token == address(USDT)) {
            return 18;
        } else if (token == address(SOL)) {
            return 17;
        }
        revert("Unsupported token");
    }

    function _getMarketDataBeforeAfter(
        ShiftUtils.CreateShiftParams memory createShiftParams,
        TokenPrices memory tokenPrices,
        bool isAfterShift,
        uint marketTokenAmountToShift
    ) internal returns (ShiftMarketData memory data) {
        Market.Props memory marketFrom = MarketStoreUtils.get(
            dataStore,
            createShiftParams.fromMarket
        );
        Market.Props memory marketToUpdate = MarketStoreUtils.get(
            dataStore,
            createShiftParams.toMarket
        );

        (data.marketTokenPriceFrom, ) = MarketUtils.getMarketTokenPrice(
            dataStore,
            marketFrom,
            _getMarketPrices(marketFrom.marketToken, tokenPrices)
                .indexTokenPrice,
            _getMarketPrices(marketFrom.marketToken, tokenPrices)
                .longTokenPrice,
            _getMarketPrices(marketFrom.marketToken, tokenPrices)
                .shortTokenPrice,
            keccak256(abi.encode("MAX_PNL_FACTOR_FOR_TRADERS")),
            false
        );

        (data.marketTokenPriceTo, ) = MarketUtils.getMarketTokenPrice(
            dataStore,
            marketToUpdate,
            _getMarketPrices(marketToUpdate.marketToken, tokenPrices)
                .indexTokenPrice,
            _getMarketPrices(marketToUpdate.marketToken, tokenPrices)
                .longTokenPrice,
            _getMarketPrices(marketToUpdate.marketToken, tokenPrices)
                .shortTokenPrice,
            keccak256(abi.encode("MAX_PNL_FACTOR_FOR_TRADERS")),
            false
        );

        Market.Props memory marketForWithdrawal = isAfterShift
            ? marketToUpdate
            : marketFrom;

        if (!isAfterShift) {
            (
                data.simulateLongTokenAmountWithdrawal,
                data.simulateShortTokenAmountWithdrawal
            ) = ReaderWithdrawalUtils.getWithdrawalAmountOut(
                dataStore,
                marketForWithdrawal,
                _getMarketPrices(marketForWithdrawal.marketToken, tokenPrices),
                marketTokenAmountToShift,
                address(0),
                ISwapPricingUtils.SwapPricingType.Shift
            );
        } else {
            (
                data.simulateLongTokenAmountWithdrawal,
                data.simulateShortTokenAmountWithdrawal
            ) = ReaderWithdrawalUtils.getWithdrawalAmountOut(
                dataStore,
                marketForWithdrawal,
                _getMarketPrices(marketForWithdrawal.marketToken, tokenPrices),
                ERC20(marketForWithdrawal.marketToken).balanceOf(
                    address(createShiftParams.receiver)
                ),
                address(0),
                ISwapPricingUtils.SwapPricingType.Shift
            );
        }
    }

    function _getSwapPath(uint8 seed) internal returns (address[] memory) {
        address[] memory markets = new address[](4);
        markets[0] = address(market_0_WETH_USDC);
        markets[1] = address(market_WBTC_WBTC_USDC);
        markets[2] = address(market_WETH_WETH_USDC);
        markets[3] = address(market_WETH_WETH_USDT);

        if (seed == 0) {
            //get some valid path
            address[] memory path = new address[](2);
            path[0] = address(market_WETH_WETH_USDC);
            path[1] = address(market_0_WETH_USDC);
            return path;
        } else if (seed == 7) {
            return new address[](0); //return empty array on specific seed
        } else {
            uint numMarkets = seed % (markets.length + 1);
            address[] memory path = new address[](numMarkets);
            for (uint i = 0; i < numMarkets; i++) {
                uint index = (seed + i) % (markets.length - i);
                path[i] = markets[index];

                markets[index] = markets[markets.length - 1 - i];
            }
            return path;
        }
    }

    function _getTokenOut(
        address[] memory swapPath,
        address inputToken
    ) internal returns (address[] memory, address) {
        if (swapPath.length == 0) {
            return (new address[](0), inputToken);
        }

        address currentToken = inputToken;
        bool isValidPath = true;

        for (uint i = 0; i < swapPath.length; i++) {
            Market.Props memory market = MarketStoreUtils.get(
                dataStore,
                swapPath[i]
            );

            if (currentToken == market.longToken) {
                currentToken = market.shortToken;
            } else if (currentToken == market.shortToken) {
                currentToken = market.longToken;
            } else {
                // Invalid market for the current token
                isValidPath = false;
                break;
            }
        }

        if (!isValidPath) {
            return (new address[](0), address(0));
        }

        return (swapPath, currentToken);
    }

    function _getAmountsOut(
        address[] memory marketPath,
        address inputToken,
        uint256 amountIn,
        address uiFeeReceiver,
        TokenPrices memory tokenPrices
    ) internal returns (SwapResult memory) {
        GetAmountsOutCache memory cache;
        SwapResult memory result;

        if (marketPath.length == 0) {
            result.amountOut = amountIn;
            return result;
        }

        cache.currentToken = inputToken;
        cache.currentAmount = amountIn;

        for (uint256 i = 0; i < marketPath.length; i++) {
            cache.market = MarketStoreUtils.get(dataStore, marketPath[i]);
            cache.prices = _getMarketPrices(marketPath[i], tokenPrices);

            (
                uint256 stepAmountOut,
                int256 stepImpactAmount,
                SwapPricingUtils.SwapFees memory stepFees
            ) = reader.getSwapAmountOut(
                    dataStore, // DataStore dataStore,
                    cache.market, //         Market.Props memory market,
                    cache.prices, //         MarketUtils.MarketPrices memory prices,
                    cache.currentToken, //         address tokenIn,
                    cache.currentAmount, //         uint256 amountIn,
                    cache.uiFeeReceiver //         address uiFeeReceiver
                );

            cache.currentToken = (cache.currentToken == cache.market.longToken)
                ? cache.market.shortToken
                : cache.market.longToken;
            cache.currentAmount = stepAmountOut;

            result.totalImpactAmount += stepImpactAmount;
            result.totalFees.feeAmountForPool += stepFees.feeAmountForPool;
            result.totalFees.feeReceiverAmount += stepFees.feeReceiverAmount;
            result.totalFees.uiFeeAmount += stepFees.uiFeeAmount;
            result.amountOut = cache.currentAmount;
        }

        // result.amountAfterFees = stepFees.amountAfterFees;
        return result;
    }

    function _getRandomTokenPair(
        uint seed,
        address addressTo
    ) internal view returns (address, address) {
        if (
            addressTo == market_0_WETH_USDC ||
            addressTo == market_WETH_WETH_USDC
        ) {
            return (address(WETH), address(USDC));
        } else if (addressTo == market_WBTC_WBTC_USDC) {
            return (address(WBTC), address(USDC));
        } else if (addressTo == market_WETH_WETH_USDC) {
            return (address(WETH), address(USDC));
        } else if (addressTo == market_WETH_WETH_USDT) {
            return (address(WETH), address(USDT));
        } else {
            address[4] memory tokens = [
                address(WETH),
                address(WBTC),
                address(USDC),
                address(USDT)
            ];
            uint randomLongToken = seed % tokens.length;
            uint randomShortToken = seed % tokens.length;
            return (tokens[randomLongToken], tokens[randomShortToken]);
        }
    }

    //@author Rappie from Perimetersec
    function clampBetween(
        uint256 value,
        uint256 low,
        uint256 high
    ) internal returns (uint256) {
        if (value < low || value > high) {
            uint256 ans = low + (value % (high - low + 1));

            return ans;
        }
        return value;
    }

    //@author Rappie from Perimetersec
    bytes16 internal constant HEX_DIGITS = "0123456789abcdef";

    function toHexString(
        bytes memory value
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * value.length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 0; i < value.length; i++) {
            uint8 valueByte = uint8(value[i]);
            buffer[2 * i + 2] = HEX_DIGITS[valueByte >> 4];
            buffer[2 * i + 3] = HEX_DIGITS[valueByte & 0xf];
        }
        return string(buffer);
    }
    function abs(int256 x) internal pure returns (uint256) {
        return x >= 0 ? uint256(x) : uint256(-x);
    }
}
