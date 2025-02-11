// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.4;

import "../../libraries/StructData.sol";

interface IExchangeRouter {
  function sendWnt(address receiver, uint256 amount) external payable;
  function sendTokens(address token, address receiver, uint256 amount) external payable;
  function createOrder(
    CreateOrderParams calldata params
  ) external payable returns (bytes32);
  function createOrderFUZZ(
    CreateOrderParams calldata params
  ) external payable returns (bool, bytes32);
  function cancelOrder(bytes32 key) external payable;
  function claimFundingFees(address[] memory markets, address[] memory tokens, address receiver) external returns (uint256[] memory);
  function claimCollateral(
    address[] memory markets,
    address[] memory tokens,
    uint256[] memory timeKeys,
    address receiver
  ) external returns (uint256[] memory);
  function setSavedCallbackContract(
    address market,
    address callbackContract
  ) external payable;
}
