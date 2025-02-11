// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IAugustusSwapper {
  function getTokenTransferProxy() external view returns (address);
}

library ParaSwapUtils {
  using SafeERC20 for IERC20;

  function swap(address to, bytes memory callData) external {
    _validateCallData(to, callData);
    address approvalAddress = IAugustusSwapper(to).getTokenTransferProxy();
    address fromToken;
    uint256 fromAmount;
    assembly {
      fromToken := mload(add(callData, 68))
      fromAmount := mload(add(callData, 100))
    }
    IERC20(fromToken).safeApprove(approvalAddress, fromAmount);
    (bool success, ) = to.call(callData);
    require(success, "paraswap call reverted");
  }

  function _validateCallData(address to, bytes memory callData) internal view {
    require(to == address(0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57), "invalid paraswap callee");
    address receiver;
    assembly {
      receiver := mload(add(callData, 196))
    }
    require(receiver == address(this), "invalid paraswap calldata");
  }
}
