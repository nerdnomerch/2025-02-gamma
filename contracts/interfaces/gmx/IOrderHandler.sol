// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.4;

import "../../libraries/StructData.sol";

interface IOrderHandler {
  function oracle() external view returns (address);
}

interface IOracle {
  function getPrimaryPrice(address token) external view returns (PriceProps memory);
}
