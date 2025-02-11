// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../logicalCoverage/PositionCoverage.sol";

contract PositionProperties is PositionCoverage {
    function _increaseAssertions(
        PositionState memory _before,
        PositionState memory _after,
        OrderCreated memory order
    ) internal {
        uint sizeDelta = order.createOrderParams.numbers.sizeDeltaUsd;
        uint collateralDelta = order
            .createOrderParams
            .numbers
            .initialCollateralDeltaAmount;

        if (sizeDelta > 0)
            require(
                _after.sizeInUsd > _before.sizeInUsd,
                "INC-01: Position size usd did not increase"
            );
        if (collateralDelta > 0)
            require(
                _after.collateralAmount > _before.collateralAmount,
                "INC-03: Collateral amount did not increase"
            );
    }

    function _decreaseAssertions(
        PositionState memory _before,
        PositionState memory _after,
        OrderCreated memory order
    ) internal {
        uint sizeDelta = order.createOrderParams.numbers.sizeDeltaUsd;
        uint collateralDelta = order
            .createOrderParams
            .numbers
            .initialCollateralDeltaAmount;

        if (sizeDelta > 0)
            require(
                _after.sizeInUsd < _before.sizeInUsd,
                "DEC-01: Position size usd did not decrease"
            );
        if (collateralDelta > 0)
            require(
                _after.collateralAmount < _before.collateralAmount,
                "DEC-02: Collateral amount did not decrease"
            );
        if (_after.sizeInUsd == 0) {
            bytes32 positionKey = Position.getPositionKey(
                order.createOrderParams.addresses.receiver,
                order.createOrderParams.addresses.market,
                order.createOrderParams.addresses.initialCollateralToken,
                order.createOrderParams.isLong
            );
            Position.Props memory positionAfter = PositionStoreUtils.get(
                dataStore,
                positionKey
            );
            bytes32[] memory autoCancelOrderKeys = AutoCancelUtils
                .getAutoCancelOrderKeys(dataStore, positionKey);
            fl.eq(
                positionAfter.numbers.sizeInUsd,
                0,
                "CLOSE-01: Position still has size in USD after closing"
            );
            fl.eq(
                positionAfter.numbers.sizeInTokens,
                0,
                "CLOSE-02: Position still has size in tokens after closing"
            );
            fl.eq(
                positionAfter.numbers.collateralAmount,
                0,
                "CLOSE-03: Position still has collateral after closing"
            );
            fl.eq(
                autoCancelOrderKeys.length,
                0,
                "CLOSE-04: Auto cancel order list non-empty after closing position"
            );
        }
        if (order.createOrderParams.isLong) {
            fl.lte(
                _after.OILong,
                _before.OILong - sizeDelta,
                "DEC-03: Long OI did not decrease"
            );
            fl.lte(
                _after.collateralSumLong,
                _before.collateralSumLong - collateralDelta,
                "DEC-04: Collateral sum long did not decrease"
            );
        } else {
            fl.lte(
                _after.OIShort,
                _before.OIShort - sizeDelta,
                "DEC-03: Short OI did not decrease"
            );

            fl.lte(
                _after.collateralSumShort,
                _before.collateralSumShort - collateralDelta,
                "DEC-04: Collateral sum short did not decrease"
            );
        }
    }

    function _cancelOrderAssertions(
        PositionState memory _before,
        PositionState memory _after,
        OrderCreated memory order
    ) internal {
        if (order.createOrderParams.isLong) {
            eqPercentageDiff(
                _after.balanceOfLongToken,
                _before.balanceOfLongToken + order.amountSent,
                1e28, //1%
                "CNCL-ORD-1: User should receive the same amount of long tokens he sent to create an order"
            );
        } else {
            eqPercentageDiff(
                _after.balanceOfShortToken,
                _before.balanceOfShortToken + order.amountSent,
                1e28, //1%
                "CNCL-ORD-2: User should receive the same amount of short tokens he sent to create an order"
            );
        }
    }
    //NOTE: excluded in GAMMA, require next level of intergration with GMX source code changes
    function _swapAssertions(
        SwapState memory _before,
        SwapState memory _after,
        OrderCreated memory order
    ) internal {
        // eqPercentageDiff(
        //     _after.balanceOfOutputToken,
        //     _before.balanceOfOutputToken + _before.swapResult.amountOut,
        //     1e27,
        //     "SWP-01 Received token balance after swap should be equal to simulated amounts before swap."
        // );
    }
}
