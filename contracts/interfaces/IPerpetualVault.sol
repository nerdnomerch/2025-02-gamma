// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IGmxProxy.sol";
import "./IVaultReader.sol";
// import "../libraries/Order.sol";

interface IPerpetualVault {
  // enum NextActionSelector {
  //   NO_ACTION,                        // state where no action is required
  //   INCREASE_ACTION,                  // represents increasing actions such as increasing a GMX perps position or increasing a spot position
  //   SWAP_ACTION,                      // represents swapping a token, either collateral to index or vice versa
  //   WITHDRAW_ACTION,                  // represents withdrawing funds
  //   COMPOUND_ACTION,                  // whenver claiming positive funding fee, we could have idle funds in the vault.
  //                                     //  If it's enough to deposit more into GMX, triggers `COMPOUND_ACTION`.
  //   SETTLE_ACTION,                    // settle fees and ensure state is up-to-date prior to withdrawals
  //   FINALIZE
  // }

  // function name() external view returns (string memory);
  function indexToken() external view returns (address);
  function collateralToken() external view returns (IERC20);
  // function isNextAction() external view returns (uint256);
  function isLock() external view returns (bool);
  // function isBusy() external view returns (bool);
  function curPositionKey() external view returns (bytes32);
  function gmxProxy() external view returns (IGmxProxy);
  function market() external view returns (address);
  function vaultReader() external view returns (IVaultReader);
  function run(
    bool isOpen,
    bool isLong,
    MarketPrices memory prices,
    bytes[] memory metadata
  ) external;
  function runNextAction(MarketPrices memory prices, bytes[] memory metadata) external;
  function cancelFlow() external;
  function cancelOrder() external;
  function claimCollateralRebates(uint256[] memory) external;
  function afterOrderExecution(
    bytes32 requestKey,
    bytes32 positionKey,
    IGmxProxy.OrderResultData memory,
    MarketPrices memory
  ) external;
  function afterLiquidationExecution() external;
  function afterOrderCancellation(bytes32 key, Order.OrderType, IGmxProxy.OrderResultData memory) external;
}
