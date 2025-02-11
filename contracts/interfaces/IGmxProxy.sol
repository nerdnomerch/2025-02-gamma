// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "../interfaces/gmx/IGmxReader.sol";

interface IGmxProxy {
  // struct PositionData {
  //   uint256 sizeInUsd;
  //   uint256 sizeInTokens;
  //   uint256 collateralAmount;
  //   uint256 netValue;
  //   bool isLong;
  // }

  struct OrderData {
    address market;
    address indexToken;
    address initialCollateralToken;
    address[] swapPath;
    bool isLong;
    uint256 sizeDeltaUsd;
    uint256 initialCollateralDeltaAmount;
    uint256 amountIn;
    uint256 callbackGasLimit;
    uint256 acceptablePrice;
    uint256 minOutputAmount;
  }

  struct OrderResultData {
    Order.OrderType orderType;
    bool isLong;
    uint256 sizeDeltaUsd;
    address outputToken;
    uint256 outputAmount;
    bool isSettle;
  }

  // function getMarket(address market) external view returns (MarketProps memory);
  // function getPositionInfo(bytes32 key, MarketPrices memory prices) external view returns (PositionData memory);
  // function getPnl(bytes32 key, MarketPrices memory prices, uint256 sizeDeltaUsd) external view returns (int256);
  // function getPositionFeeUsd(address market, uint256 sizeDeltaUsd, bool forPositiveImpact) external view returns (uint256);
  // function getMarketPrices(address market) external view returns (MarketPrices memory);
  // function getPositionSizeInUsd(bytes32 key) external view returns (uint256 sizeInUsd);
  // function getPositionSizeInTokens(bytes32 key) external view returns (uint256 sizeInTokens);
  function getExecutionGasLimit(Order.OrderType orderType, uint256 callbackGasLimit) external view returns (uint256 executionGasLimit);
  function setPerpVault(address perpVault, address market) external;
  function createOrder(Order.OrderType orderType, OrderData memory orderData) external returns (bytes32);
  function settle(OrderData memory orderData) external returns (bytes32);
  function cancelOrder() external;
  function claimCollateralRebates(address[] memory, address[] memory, uint256[] memory, address) external;
  function refundExecutionFee(address caller, uint256 amount) external;
  function withdrawEth() external returns (uint256);
  function lowerThanMinEth() external view returns (bool);
  // function willPositionCollateralBeInsufficient(
  //   MarketPrices memory prices,
  //   bytes32 positionKey,
  //   address market,
  //   bool isLong,
  //   uint256 sizeDeltaUsd,
  //   uint256 collateralDeltaAmount
  // ) external view returns (bool);
  // function getPriceImpactInCollateral(
  //   bytes32 positionKey,
  //   uint256 sizeDeltaInUsd,
  //   uint256 prevSizeInTokens,
  //   MarketPrices memory prices
  // ) external view returns (int256);
  function queue()
        external
        view
        returns (bytes32, bool); //NOTE: added by fuzzer
}
