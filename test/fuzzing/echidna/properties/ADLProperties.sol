// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../logicalCoverage/ADLCoverage.sol";

contract ADLProperties is ADLCoverage {
    function invariantPositionSizeUSDShouldDecrease(
        uint positionSizeBefore,
        uint positionSizeAfter,
        uint reducedByDelta
    ) internal {
        fl.eq(
            positionSizeBefore,
            positionSizeAfter + reducedByDelta,
            "ADL-01 Position size shoud be reduced exactly by delta"
        );
    }
}
