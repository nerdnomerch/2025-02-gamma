// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {console} from "forge-std/Test.sol";
interface IAugustusSwapper {
    function getTokenTransferProxy() external view returns (address);
}

contract MockParaSwapUtils {
    using SafeERC20 for IERC20;

    address PARASWAP_ROUTER;
    bool routerSet;

    function setRouter(address _paraswapRouter) public {
        require(!routerSet);
        PARASWAP_ROUTER = _paraswapRouter;
        routerSet = true;
    }

    function swap(address to, bytes memory callData) public {
        _validateCallData(to, callData);
        address approvalAddress = IAugustusSwapper(to).getTokenTransferProxy();
        address fromToken;
        uint256 fromAmount;
        assembly {
            fromToken := mload(add(callData, 36)) //@audit replaced 68th byte by fuzzer
            fromAmount := mload(add(callData, 100))
        }
        IERC20(fromToken).safeApprove(approvalAddress, fromAmount);
        (bool success, ) = to.call(callData);
        require(success, "paraswap call reverted");
    }

    function _validateCallData(
        address to,
        bytes memory callData
    ) internal view {
        assert(PARASWAP_ROUTER != address(0));
        require(to == PARASWAP_ROUTER, "invalid paraswap callee");

        address receiver;
        assembly {
            receiver := mload(add(callData, 196))
        }
        require(receiver == address(this), "invalid paraswap calldata");
    }
}
