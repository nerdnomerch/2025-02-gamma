// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../logicalCoverage/LiquidationCoverage.sol";

contract LiquidationProperties is LiquidationCoverage {
    function invariantPositionCountShouldDecrease(
        uint positionCountAfter,
        uint positionCountBefore
    ) internal {
        fl.lt(
            positionCountAfter,
            positionCountBefore,
            "LIQ-01: Position count not decreased post-liquidation"
        );
    }

    function invariantAutoCancelListShouldBeEmptyAfterLiquidation(
        uint autoCancelOrderKeysLength
    ) internal {
        fl.eq(
            autoCancelOrderKeysLength,
            0,
            "LIQ-02: Auto cancel order list non-empty post-liquidation"
        );
    }

    function invariantPositionCountDecreasesByOne(
        uint positionCountAfter,
        uint positionCountBefore
    ) internal {
        fl.eq(
            positionCountAfter + 1,
            positionCountBefore,
            "LIQ-03: Position count should be decreased by 1"
        );
    }
}
