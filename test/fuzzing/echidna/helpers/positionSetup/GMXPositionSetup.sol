// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./OrderSetup.sol";
import "../ADLSetup.sol";

contract GMXPositionSetup is OrderSetup, ADLSetup {
    using Price for Price.Props;
    OrderCreated[] internal orderCreatedArray;

    struct OrderCache {
        address[] longSwapPath;
        address[] swapPath;
        address market;
        address user;
        address token;
        uint decreaseSize;
        uint collateralDeltaAmount;
        bool isLimit;
        bool isLong;
        bool isStopLoss;
        uint priceSeed;
        uint amount;
        uint leverage;
    }

    function SwapOrder(
        uint8 tokenIndex,
        uint8 userIndex,
        uint priceSeed,
        uint amount,
        uint8 swapPathSeed,
        bool isLimit,
        uint executionFee
    ) public {
        //Introducing high execution fee, so we can judge by refunded amount after
        executionFee = FIXED_EXECUTION_FEE_AMOUNT;

        OrderCache memory cache;

        cache.user = _getRandomUser(userIndex);
        cache.swapPath = _getSwapPath(swapPathSeed);
        cache.token = _getRandomToken(tokenIndex);

        TokenPrices memory tokenPrices = _setTokenPrices(priceSeed);
        (amount, ) = _getTokenAmounts(
            amount,
            0,
            cache.token,
            address(0),
            cache.user
        );

        IBaseOrderUtils.CreateOrderParamsAddresses
            memory addresses = _setCreateOrderParamsAddresses(
                cache.user, //receiver,
                address(callback), //callbackContract
                address(0), //uiFeeReceiver
                cache.market,
                cache.token,
                cache.swapPath
            );

        IBaseOrderUtils.CreateOrderParamsNumbers
            memory numbers = _setCreateOrderParamsNumbers(
                _getUSDAmount(amount, cache.token, 1, tokenPrices), //sizeDeltaUsd
                amount, // initialCollateralDeltaAmount, native decimals
                _getTokenPrice(cache.token, tokenPrices), //triggerPrice
                1, //acceptablePrice
                executionFee,
                200 * 1000, //callbackGasLimit
                1, // minOutputAmount,
                0 // validFromTime
            );

        IBaseOrderUtils.CreateOrderParams
            memory orderParams = _setCreateOrderParams(
                addresses,
                numbers,
                isLimit
                    ? Order.OrderType.LimitSwap
                    : Order.OrderType.MarketSwap,
                Order.DecreasePositionSwapType.NoSwap, //hardcoded
                true, //isLong, any
                false, //no wrap to simplify assertions
                true, //auto cancel
                bytes32(0) //refferal code
            );

        _order(
            orderParams,
            swapPathSeed,
            tokenPrices,
            executionFee,
            keccak256(abi.encode(isLimit ? "SWAP_LIMIT" : "SWAP_MARKET"))
        );

        ExecuteOrder(priceSeed, true);
    }

    function IncreaseOrder(
        uint8 marketIndex,
        uint8 userIndex,
        uint leverageSeed,
        uint priceSeed,
        uint amount,
        bool isLimit,
        bool isLong,
        uint8 swapPathSeed,
        uint executionFee
    ) public {
        if (!SWAPS_ENABLED) {
            swapPathSeed = 7;
        }

        //Swaps disabled
        executionFee = FIXED_EXECUTION_FEE_AMOUNT;

        OrderCache memory cache;
        cache.user = _getRandomUser(userIndex);
        cache.longSwapPath = _getSwapPath(swapPathSeed);
        cache.market = _getMarketAddress(marketIndex);
        cache.leverage = clampBetween(leverageSeed, 1, 100);

        if (!_checkMarketForOrders(cache.market)) {
            return;
        }

        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            cache.market
        );
        TokenPrices memory tokenPrices = _setTokenPrices(priceSeed);

        cache.token = isLong ? marketProps.longToken : marketProps.shortToken;

        if (isLong) {
            (cache.amount, ) = _getTokenAmounts(
                amount,
                0,
                marketProps.longToken,
                marketProps.shortToken,
                cache.user
            );
        } else {
            (, cache.amount) = _getTokenAmounts(
                0,
                amount,
                marketProps.longToken,
                marketProps.shortToken,
                cache.user
            );
        }

        IBaseOrderUtils.CreateOrderParamsAddresses
            memory addresses = _setCreateOrderParamsAddresses(
                cache.user,
                address(callback),
                address(0), //uiFeeReceiver
                cache.market,
                cache.token,
                cache.longSwapPath
            );

        IBaseOrderUtils.CreateOrderParamsNumbers
            memory numbers = _setCreateOrderParamsNumbers(
                _getUSDAmount(
                    cache.amount,
                    cache.token,
                    cache.leverage,
                    tokenPrices
                ),
                cache.amount, // initialCollateralDeltaAmount, native decimals
                _getTokenPrice(marketProps.indexToken, tokenPrices), //triggerPrice
                isLong ? type(uint256).max : 1, //acceptable price
                executionFee,
                200 * 1000, //'callbackGasLimit
                1, // minOutputAmount
                0 // validFromTime
            );

        IBaseOrderUtils.CreateOrderParams
            memory orderParams = _setCreateOrderParams(
                addresses,
                numbers,
                isLimit
                    ? Order.OrderType.LimitIncrease
                    : Order.OrderType.MarketIncrease,
                Order.DecreasePositionSwapType.NoSwap, //hardcoded
                isLong, //isLong
                false, //no wrap to simplify assertions
                true, //auto cancel
                bytes32(0) //refferal code
            );

        _order(
            orderParams,
            swapPathSeed,
            tokenPrices,
            executionFee,
            keccak256(abi.encode(isLong ? "INCREASE_LONG" : "INCREASE_SHORT"))
        );
    }

    function DecreasePosition(
        uint8 marketIndex,
        uint8 userIndex,
        uint priceSeed,
        uint collateralDeltaSeed,
        bool closePosition,
        bool isLimit,
        bool isLong,
        bool isStopLoss,
        uint8 swapPathSeed,
        uint executionFee
    ) public {
        if (!SWAPS_ENABLED) {
            swapPathSeed = 7;
        }

        executionFee = FIXED_EXECUTION_FEE_AMOUNT;

        OrderCache memory cache;
        cache.isLong = isLong;
        cache.isLimit = isLimit;
        cache.isStopLoss = isStopLoss;
        cache.priceSeed = priceSeed;
        cache.longSwapPath = _getSwapPath(swapPathSeed);
        cache.market = _getMarketAddress(marketIndex);
        cache.user = _getRandomUser(userIndex);

        if (!_checkMarketForOrders(cache.market)) {
            return;
        }

        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            cache.market
        );
        TokenPrices memory tokenPrices = _setTokenPrices(cache.priceSeed);

        cache.token = cache.isLong
            ? marketProps.longToken
            : marketProps.shortToken;

        bytes32 positionKey = Position.getPositionKey(
            cache.user,
            cache.market,
            cache.token,
            cache.isLong
        );

        Position.Props memory position = PositionStoreUtils.get(
            dataStore,
            positionKey
        );

        if (
            position.numbers.sizeInUsd == 0 &&
            position.numbers.sizeInTokens == 0 &&
            position.numbers.collateralAmount == 0
        ) {
            return;
        }

        IBaseOrderUtils.CreateOrderParamsAddresses
            memory addresses = _setCreateOrderParamsAddresses(
                cache.user,
                address(callback),
                address(0), //uiFeeReceiver
                cache.market,
                cache.token,
                cache.longSwapPath
            );

        if (closePosition) {
            cache.decreaseSize = position.numbers.sizeInUsd;
            cache.collateralDeltaAmount = 0;
        } else {
            cache.decreaseSize = clampBetween(
                collateralDeltaSeed,
                1,
                position.numbers.sizeInUsd -
                    DECREASE_POSITION_TOLERABLE_PRICE_SUB
            );
            cache.collateralDeltaAmount = clampBetween(
                collateralDeltaSeed / RANDOMIZER_DIVISOR,
                1,
                position.numbers.collateralAmount
            );

            require( //The idea is to prevent 0 out if size decrease delta is too small
                cache.decreaseSize > DECREASE_POSITION_DELTA_MIN,
                "DecreasePosition only by delta amount min"
            );
        }

        IBaseOrderUtils.CreateOrderParamsNumbers
            memory numbers = _setCreateOrderParamsNumbers(
                cache.decreaseSize,
                cache.collateralDeltaAmount,
                _getTokenPrice(marketProps.indexToken, tokenPrices), //triggerPrice
                cache.isLong ? 0 : type(uint256).max, // acceptable price
                0, // execution fee
                200 * 1000, //'callbackGasLimit
                1, // minOutput
                0 // validFromTime
            );

        IBaseOrderUtils.CreateOrderParams
            memory orderParams = _setCreateOrderParams(
                addresses,
                numbers,
                cache.isStopLoss
                    ? Order.OrderType.StopLossDecrease
                    : cache.isLimit
                        ? Order.OrderType.LimitDecrease
                        : Order.OrderType.MarketDecrease,
                Order.DecreasePositionSwapType.NoSwap, //hadrcoded
                cache.isLong,
                false, //no wrap to simplify assertions
                true, //auto cancel
                bytes32(0) //refferal code
            );

        if (closePosition) {
            _order(
                orderParams,
                swapPathSeed,
                tokenPrices,
                0,
                keccak256(abi.encode("CLOSE"))
            );
        } else {
            _order(
                orderParams,
                swapPathSeed,
                tokenPrices,
                0,
                keccak256(abi.encode("DECREASE"))
            );
            //Not doing separate handler for stop losses because technically its also a decrease
        }
    }

    function _order(
        IBaseOrderUtils.CreateOrderParams memory params,
        uint8 swapPathSeed,
        TokenPrices memory tokenPrices,
        uint executionFee,
        bytes32 handlerType
    ) internal returns (OrderCreated memory orderCreated) {
        if (
            //Swap Order
            handlerType == keccak256(abi.encode("SWAP_LIMIT")) ||
            handlerType == keccak256(abi.encode("SWAP_MARKET"))
        ) {
            _mintAndSendTokensTo(
                params.addresses.receiver,
                address(orderVault), //to
                params.numbers.initialCollateralDeltaAmount, //longTokenAmount
                0, //shortTokenAmount
                params.addresses.initialCollateralToken, //longTokenAddress
                address(0), //shortTokenAddress
                executionFee,
                false //isWETH
            );
        } else {
            //Increase and Decrease Order
            Market.Props memory marketProps = MarketStoreUtils.get(
                dataStore,
                params.addresses.market
            );

            bool isWeth = marketProps.longToken == address(WETH) ||
                marketProps.shortToken == address(WETH);

            uint256 longAmount = params.isLong
                ? params.numbers.initialCollateralDeltaAmount
                : 0;
            uint256 shortAmount = params.isLong
                ? 0
                : params.numbers.initialCollateralDeltaAmount;

            //Transfer only if Increasing
            if (
                handlerType ==
                keccak256(
                    abi.encode(
                        params.isLong ? "INCREASE_LONG" : "INCREASE_SHORT"
                    )
                )
            ) {
                if (params.isLong) {
                    _mintAndSendTokensTo(
                        params.addresses.receiver,
                        address(orderVault),
                        longAmount,
                        shortAmount,
                        marketProps.longToken,
                        address(0), //shortTokenAddress
                        executionFee,
                        isWeth
                    );
                } else {
                    _mintAndSendTokensTo(
                        params.addresses.receiver,
                        address(orderVault),
                        longAmount,
                        shortAmount,
                        address(0), //longTokenAddress
                        marketProps.shortToken,
                        executionFee,
                        isWeth
                    );
                }
            }
        }

        bytes memory callData_CreateOrder = abi.encodeWithSelector(
            exchangeRouter.createOrder.selector,
            params
        );

        vm.prank(params.addresses.receiver);

        (
            bool success_CreateOrder,
            bytes memory returnData_CreateOrder
        ) = address(exchangeRouter).call{gas: 30_000_000}(callData_CreateOrder);

        if (!success_CreateOrder) {
            invariantDoesNotSilentRevert(returnData_CreateOrder);
        } else {
            orderCreated.key = abi.decode(returnData_CreateOrder, (bytes32));
        }

        orderCreated.createOrderParams = params;
        orderCreated.updatedAt = block.timestamp;
        orderCreated.user = params.addresses.receiver;
        orderCreated.handlerType = handlerType;
        orderCreated.amountSent = params.numbers.initialCollateralDeltaAmount;
        orderCreated.isClose = handlerType == keccak256(abi.encode("CLOSE"));
        orderCreated.swapPathSeed = swapPathSeed;
        orderCreated.tokenPrices = tokenPrices;
        orderCreated.executionFee = executionFee;
        orderCreatedArray.push(orderCreated);

        _checkOrderCreatedCoverage(orderCreated);
    }

    function CancelOrder(
        uint seed,
        bool isAtomicExec
    )
        public
        returns (
            PositionState memory _before,
            PositionState memory _after,
            OrderCreated memory orderToCancel
        )
    {
        require(orderCreatedArray.length > 0, "No orders available to cancel");

        uint256 randomIndex = isAtomicExec
            ? orderCreatedArray.length - 1
            : clampBetween(seed, 0, orderCreatedArray.length - 1);
        orderToCancel = orderCreatedArray[randomIndex];

        fl.neq(
            uint(orderToCancel.key),
            uint(0),
            "Order key is zero and orderToCancel exists"
        );

        _before = _snapPositionState(orderToCancel.key, orderToCancel);

        bytes memory callData_CancelOrder = abi.encodeWithSelector(
            exchangeRouter.cancelOrder.selector,
            orderToCancel.key
        );

        vm.warp(block.timestamp + REQUEST_EXPIRATION_TIME);
        vm.prank(orderToCancel.user);

        (
            bool success_CancelOrder,
            bytes memory returnData_CancelOrder
        ) = address(exchangeRouter).call{gas: 30_000_000}(callData_CancelOrder);

        if (!success_CancelOrder) {
            invariantDoesNotSilentRevert(returnData_CancelOrder);
        }

        _after = _snapPositionState(orderToCancel.key, orderToCancel);

        _checkOrderCancelCoverage(orderToCancel);
    }

    function ExecuteOrder(uint priceSeed, bool isAtomicExec) public {
        callback.cleanETHBalance(address(0));

        require(orderCreatedArray.length > 0, "No orders available to execute");

        uint256 randomIndex = isAtomicExec
            ? orderCreatedArray.length - 1
            : clampBetween(priceSeed, 0, orderCreatedArray.length - 1);

        OrderCreated memory orderToExecute = orderCreatedArray[randomIndex];

        Market.Props memory marketProps;
        bytes32 positionKey;

        if (orderToExecute.createOrderParams.addresses.market != address(0)) {
            marketProps = MarketStoreUtils.get(
                dataStore,
                orderToExecute.createOrderParams.addresses.market
            );
            positionKey = Position.getPositionKey(
                orderToExecute.user,
                marketProps.marketToken,
                orderToExecute.createOrderParams.isLong
                    ? marketProps.longToken
                    : marketProps.shortToken,
                orderToExecute.createOrderParams.isLong
            );
        }

        TokenPrices memory tokenPrices = _setTokenPrices(priceSeed);

        OracleUtils.SetPricesParams memory oracleParams = SetOraclePrices(
            tokenPrices.tokens,
            tokenPrices.maxPrices,
            tokenPrices.minPrices
        );

        uint before_callbackBalance_GEN2 = address(callback).balance;

        if (positionKey != 0) {
            /*
             __
            <(o )___
             ( ._> /
              `---'   Increase and Decrease Order 
              */

            PositionState memory _before = _snapPositionState(
                positionKey,
                orderToExecute
            );
            _executeOrderGMX(orderToExecute.key, oracleParams);
            PositionState memory _after = _snapPositionState(
                positionKey,
                orderToExecute
            );

            Position.Props memory position = PositionStoreUtils.get(
                dataStore,
                positionKey
            );

            if (
                orderToExecute.createOrderParams.orderType ==
                Order.OrderType.MarketIncrease ||
                orderToExecute.createOrderParams.orderType ==
                Order.OrderType.LimitIncrease
            ) {
                if (position.numbers.sizeInUsd != 0) {
                    //if position opened
                    checkOrderAndGetCoverage(
                        positionKey,
                        marketProps,
                        tokenPrices,
                        true // isIncreaseOrder
                    );
                    _increaseAssertions(_before, _after, orderToExecute);
                    if (isAtomicExec) {
                        // InvariantExecutionFeeIsAlwaysCovered( //NOTE: this execution fee is checked by callback contract which is not used in GAMMA version
                        //     address(0),
                        //     before_callbackBalance_GEN2,
                        //     address(callback).balance, //after
                        //     orderToExecute
                        //         .createOrderParams
                        //         .numbers
                        //         .executionFee
                        // );
                    }
                }
            }

            if (
                orderToExecute.createOrderParams.orderType ==
                Order.OrderType.MarketDecrease ||
                orderToExecute.createOrderParams.orderType ==
                Order.OrderType.LimitDecrease
            ) {
                if (position.numbers.sizeInUsd != 0) {
                    //if not closed
                    checkOrderAndGetCoverage(
                        positionKey,
                        marketProps,
                        tokenPrices,
                        false // isIncreaseOrder
                    );
                }
                _decreaseAssertions(_before, _after, orderToExecute);

                if (isAtomicExec) {
                    // InvariantExecutionFeeIsAlwaysCovered( //NOTE: this execution fee is checked by callback contract which is not used in GAMMA version
                    //     address(0),
                    //     before_callbackBalance_GEN2,
                    //     address(callback).balance, //after
                    //     orderToExecute.createOrderParams.numbers.executionFee
                    // );
                }
            }
        } else {
            /*
             __
            <(o )___
             ( ._> /
              `---'   Swap Order 
              */

            SwapState memory _before = _snapSwapState(false, orderToExecute);
            _executeOrderGMX(orderToExecute.key, oracleParams);
            SwapState memory _after = _snapSwapState(true, orderToExecute);

            require(
                _after.balanceOfOutputToken > _before.balanceOfOutputToken,
                "Swap: state was not changed"
            );

            _swapAssertions(_before, _after, orderToExecute);
            if (isAtomicExec) {
                // InvariantExecutionFeeIsAlwaysCovered( //NOTE: this execution fee is checked by callback contract which is not used in GAMMA version
                //     address(0),
                //     before_callbackBalance_GEN2,
                //     address(callback).balance, //after
                //     orderToExecute.createOrderParams.numbers.executionFee
                // );
            }
        }

        orderCreatedArray[randomIndex] = orderCreatedArray[
            orderCreatedArray.length - 1
        ];
        orderCreatedArray.pop();
    }
    function _executeOrderGMX(
        bytes32 orderKey,
        OracleUtils.SetPricesParams memory oracleParams
    ) internal {
        bytes memory callData_ExecuteOrder = abi.encodeWithSelector(
            orderHandler.executeOrder.selector,
            orderKey,
            oracleParams
        );
        vm.prank(DEPLOYER);

        (
            bool success_ExecuteOrder,
            bytes memory returnData_ExecuteOrder
        ) = address(orderHandler).call{gas: 30_000_000}(callData_ExecuteOrder);

        if (!success_ExecuteOrder) {
            invariantDoesNotSilentRevert(returnData_ExecuteOrder);
        }
    }

    function getOrderKeys(
        uint256 start,
        uint256 end
    ) internal view returns (bytes32[] memory) {
        bytes32 ORDER_LIST_KEY = keccak256(abi.encode("ORDER_LIST"));
        return dataStore.getBytes32ValuesAt(ORDER_LIST_KEY, start, end);
    }
    function _checkMarketForOrders(address market) internal returns (bool) {
        return market == market_0_WETH_USDC ? false : true;
    }

    function checkOrderAndGetCoverage(
        bytes32 positionKey,
        Market.Props memory marketProps,
        TokenPrices memory tokenPrices,
        bool isIncreaseOrder
    ) internal {
        Position.Props memory position = PositionStoreUtils.get(
            dataStore,
            positionKey
        );

        if (position.numbers.sizeInUsd != 0) {
            ReaderPositionUtils.PositionInfo memory positionInfo = reader
                .getPositionInfo(
                    dataStore,
                    referralStorage,
                    positionKey,
                    _getMarketPrices(marketProps.marketToken, tokenPrices),
                    0, // size delta usd = 0 because usePositionSizeAsSizeDeltaUsd is true
                    address(0),
                    true // usePositionSizeAsSizeDeltaUsd
                );
            ReaderUtils.MarketInfo memory marketInfo = reader.getMarketInfo(
                dataStore,
                _getMarketPrices(marketProps.marketToken, tokenPrices),
                marketProps.marketToken
            );
            if (isIncreaseOrder) {
                _checkIncreaseOrderAndGetPositionCoverage(position); //position info checked separately
                _checkIncreaseOrderAndGetPositionInfoCoverage(positionInfo);
                _checkIncreaseOrderAndGetMarketInfoCoverage(marketInfo);
            } else {
                _checkDecreaseOrderAndGetPositionCoverage(position);
                _checkDecreaseOrderAndGetPositionInfoCoverage(positionInfo);
                _checkDecreaseOrderAndGetMarketInfoCoverage(marketInfo);
            }
        }
    }
    function _getUSDAmount(
        uint amount,
        address token,
        uint leverage,
        TokenPrices memory tokenPrices
    ) internal returns (uint result) {
        if (token == address(USDT) || token == address(USDC)) {
            result = amount * leverage * 1e24; //NOTE: hardcoded precision
        } else {
            uint tokenPrice = _getTokenPrice(token, tokenPrices);
            result = amount * leverage * tokenPrice;
        }
    }
}
