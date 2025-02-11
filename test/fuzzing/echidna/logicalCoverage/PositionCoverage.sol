// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./positionCoverage/CreateOrderCoverage.sol";
import "./positionCoverage/CancelOrderCoverage.sol";
import "./positionCoverage/IncreasePositionInfoCoverage.sol";
import "./positionCoverage/IncreasePositionMarketCoverage.sol";
import "./positionCoverage/DecreasePositionInfoCoverage.sol";
import "./positionCoverage/DecreasePositionMarketCoverage.sol";

contract PositionCoverage is
    CreateOrderCoverage,
    CancelOrderCoverage,
    IncreasePositionInfoCoverage,
    IncreasePositionMarketCoverage,
    DecreasePositionInfoCoverage,
    DecreasePositionMarketCoverage
{}
