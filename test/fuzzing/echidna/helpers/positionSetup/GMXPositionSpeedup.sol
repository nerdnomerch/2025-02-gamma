pragma solidity ^0.8.0;

import "./GMXPositionSetup.sol";

contract GMXPositionSpeedup is GMXPositionSetup {
    function IncreaseAndCancelOrder(
        uint8 marketIndex,
        uint8 userIndex,
        uint leverageSeed,
        uint priceSeed,
        uint amount,
        bool isLong,
        uint8 swapPathSeed,
        uint executionFee
    ) public {
        IncreaseOrder(
            marketIndex,
            userIndex,
            leverageSeed,
            priceSeed,
            amount,
            false,
            isLong,
            swapPathSeed,
            executionFee
        );
        (
            PositionState memory _before,
            PositionState memory _after,
            OrderCreated memory orderToCancel
        ) = CancelOrder(priceSeed, true);

        _cancelOrderAssertions(_before, _after, orderToCancel);
    }

    function DecreaseCloseLongShortOrder(
        uint8 marketIndex,
        uint8 userIndex,
        uint leverageSeed,
        uint priceSeed,
        uint amount,
        uint collateralDeltaSeed,
        bool isLong,
        bool isStopLoss,
        bool closePosition,
        uint8 swapPathSeed,
        uint executionFee
    ) public {
        IncreaseOrder(
            marketIndex,
            userIndex,
            leverageSeed,
            priceSeed,
            amount,
            false,
            isLong,
            swapPathSeed,
            executionFee
        );

        ExecuteOrder(priceSeed, true); //last item

        DecreasePosition(
            marketIndex,
            userIndex,
            priceSeed,
            collateralDeltaSeed,
            closePosition,
            false, //isLimit
            isLong,
            isStopLoss,
            swapPathSeed,
            executionFee
        );
        ExecuteOrder(priceSeed, true); //last item
    }

    function IncreaseExecuteLimitOrder(
        uint8 marketIndex,
        uint8 userIndex,
        uint leverageSeed,
        uint priceSeed,
        uint amount,
        bool isLong,
        uint8 swapPathSeed,
        uint executionFee
    ) public {
        IncreaseOrder(
            marketIndex,
            userIndex,
            leverageSeed,
            priceSeed,
            amount,
            true,
            isLong,
            swapPathSeed,
            executionFee
        ); //7 is emply swap path
        ExecuteOrder(priceSeed, true); //last item
    }

    function DecreaseExecuteLimitOrderLong(
        uint8 marketIndex,
        uint8 userIndex,
        uint leverageSeed,
        uint priceSeed,
        uint amount,
        uint collateralDeltaSeed,
        bool isStopLoss,
        bool closePosition,
        uint8 swapPathSeed,
        uint executionFee
    ) public {
        IncreaseOrder(
            marketIndex,
            userIndex,
            leverageSeed,
            priceSeed,
            amount,
            false,
            true,
            swapPathSeed,
            executionFee
        ); //7 is emply swap path
        ExecuteOrder(priceSeed, true); //last item

        vm.warp(block.timestamp + REQUEST_EXPIRATION_TIME);

        DecreasePosition(
            marketIndex,
            userIndex,
            priceSeed,
            collateralDeltaSeed,
            closePosition,
            true,
            true,
            isStopLoss,
            swapPathSeed, //7 is emply swap path
            executionFee
        );

        ExecuteOrder(priceSeed, true); //last item
    }
    function DecreaseExecuteLimitOrderShort(
        uint8 marketIndex,
        uint8 userIndex,
        uint leverageSeed,
        uint priceSeed,
        uint amount,
        uint collateralDeltaSeed,
        bool isStopLoss,
        bool closePosition,
        uint8 swapPathSeed,
        uint executionFee
    ) public {
        IncreaseOrder(
            marketIndex,
            userIndex,
            leverageSeed,
            priceSeed,
            amount,
            true,
            false,
            swapPathSeed,
            executionFee
        ); //7 is emply swap path
        ExecuteOrder(priceSeed, true); //last item

        vm.warp(block.timestamp + REQUEST_EXPIRATION_TIME);

        DecreasePosition(
            marketIndex,
            userIndex,
            priceSeed,
            collateralDeltaSeed,
            closePosition,
            true,
            false,
            isStopLoss,
            swapPathSeed, //7 is emply swap path
            executionFee
        );
        ExecuteOrder(priceSeed, true); //last item
    }

    function DecreaseExecuteLimitOrderShortWithSwap(
        uint8 marketIndex,
        uint8 userIndex,
        uint leverageSeed,
        uint priceSeed,
        uint amount,
        uint collateralDeltaSeed,
        bool closePosition,
        bool isStopLoss,
        uint8 swapPathSeed,
        uint executionFee
    ) public {
        IncreaseOrder(
            marketIndex,
            userIndex,
            leverageSeed,
            priceSeed,
            amount,
            true,
            false,
            swapPathSeed,
            executionFee
        );
        ExecuteOrder(priceSeed, true); //last item

        vm.warp(block.timestamp + REQUEST_EXPIRATION_TIME);

        DecreasePosition(
            marketIndex,
            userIndex,
            priceSeed,
            collateralDeltaSeed,
            closePosition,
            true,
            false,
            isStopLoss,
            swapPathSeed,
            executionFee
        );
        ExecuteOrder(priceSeed, true); //last item
    }

    function OrderAndADL(
        uint8 marketIndex,
        uint8 userIndex,
        uint leverageSeed,
        uint priceSeed,
        uint amount,
        bool isLong,
        uint8 swapPathSeed,
        uint executionFee
    ) public {
        //Here we creating specific conditions to cover ADL once, later we check if fuzzer reached this conditions itself
        IncreaseExecuteLimitOrder(
            0,
            0,
            10,
            1000e4,
            249e17, //49.99% of weth/weth/usdc market
            true,
            swapPathSeed,
            executionFee
        );
        ExecuteADL(0, 999999e4);
    }
}
