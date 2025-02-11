// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./BaseSetup.sol";

contract MintSetup is BaseSetup {
    function _mintAndSendTokensTo(
        address user,
        address to,
        uint256 longTokenAmount,
        uint256 shortTokenAmount,
        address longTokenAddress,
        address shortTokenAddress,
        uint executionFee,
        bool isWETH
    ) internal {
        if (longTokenAddress != address(0)) {
            _handleTokenMintAndTransfer(
                user,
                to,
                longTokenAmount,
                longTokenAddress,
                executionFee,
                isWETH
            );
        }

        if (shortTokenAddress != address(0)) {
            _handleTokenMintAndTransfer(
                user,
                to,
                shortTokenAmount,
                shortTokenAddress,
                executionFee,
                isWETH
            );
        }

        vm.prank(user);
        WETH.deposit{value: executionFee}();
        vm.prank(user);
        WETH.transfer(to, executionFee);
    }

    function _handleTokenMintAndTransfer(
        address user,
        address to,
        uint256 amount,
        address tokenAddress,
        uint executionFee,
        bool isWETH
    ) private {
        if (isWETH && tokenAddress == address(WETH)) {
            //mint happens in FuzzSetup
            vm.prank(user);
            WETH.transfer(to, amount);
        } else {
            vm.prank(user);
            MintableToken(tokenAddress).transfer(to, amount);
        }
    }
}
