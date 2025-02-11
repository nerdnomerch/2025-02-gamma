// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "../libraries/StructData.sol";

interface IVaultReader {
  struct PositionData {
    uint256 sizeInUsd;
    uint256 sizeInTokens;
    uint256 collateralAmount;
    uint256 netValue;
    int256 pnl;
    bool isLong;
  }

  function getPositionInfo(
    bytes32 key,
    MarketPrices memory prices
  ) external view returns (PositionData memory);
  function getNegativeFundingFeeAmount(
    bytes32 key,
    MarketPrices memory prices
  ) external view returns (uint256);
  function willPositionCollateralBeInsufficient(
    MarketPrices memory prices,
    bytes32 positionKey,
    address market,
    bool isLong,
    uint256 sizeDeltaUsd,
    uint256 collateralDeltaAmount
  ) external view returns (bool);
  function getPriceImpactInCollateral(
    bytes32 positionKey,
    uint256 sizeDeltaInUsd,
    uint256 prevSizeInTokens,
    MarketPrices memory prices
  ) external view returns (int256);
  function getPnl(
    bytes32 key,
    MarketPrices memory prices,
    uint256 sizeDeltaUsd
  ) external view returns (int256);
  function getPositionSizeInUsd(bytes32 key) external view returns (uint256 sizeInUsd);
  function getPositionSizeInTokens(bytes32 key) external view returns (uint256 sizeInTokens);
  function getMarket(address market) external view returns (MarketProps memory);
  function getPositionFeeUsd(
    address market,
    uint256 sizeDeltaUsd,
    bool forPositiveImpact
  ) external view returns (uint256 positionFeeAmount);
}
