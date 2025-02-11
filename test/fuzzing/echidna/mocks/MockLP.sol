// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract MockLP is ERC20 {
    using SafeERC20 for IERC20;

    uint256 public feePercentage;
    uint256 public maxSwapPercentage;

    IERC20 public tokenA;
    IERC20 public tokenB;

    event Mint(
        address sender,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
    event Burn(
        address sender,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    constructor(
        IERC20 _tokenA,
        IERC20 _tokenB,
        uint256 _feePercentage,
        uint256 _maxSwapPercentage,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        feePercentage = _feePercentage;
        maxSwapPercentage = _maxSwapPercentage;
    }

    function addLiquidity(
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 minLiquidity
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        if (totalSupply() == 0) {
            amountA = amountADesired;
            amountB = amountBDesired;
            liquidity = Math.sqrt(amountA * amountB);
        } else {
            uint256 reserveA = tokenA.balanceOf(address(this));
            uint256 reserveB = tokenB.balanceOf(address(this));

            amountA = amountADesired;
            amountB = (amountADesired * reserveB) / reserveA;

            if (amountB > amountBDesired) {
                amountB = amountBDesired;
                amountA = (amountB * reserveA) / reserveB;
            }

            liquidity = (amountA * totalSupply()) / reserveA;
        }

        require(liquidity >= minLiquidity, "Insufficient liquidity");

        tokenA.safeTransferFrom(msg.sender, address(this), amountA);
        tokenB.safeTransferFrom(msg.sender, address(this), amountB);

        _mint(msg.sender, liquidity);

        emit Mint(msg.sender, amountA, amountB, liquidity);
    }

    function removeLiquidity(
        uint256 liquidity,
        uint256 minAmountA,
        uint256 minAmountB
    ) external returns (uint256 amountA, uint256 amountB) {
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));

        amountA = (liquidity * reserveA) / totalSupply();
        amountB = (liquidity * reserveB) / totalSupply();

        require(amountA >= minAmountA, "Insufficient amountA");
        require(amountB >= minAmountB, "Insufficient amountB");

        _burn(msg.sender, liquidity);

        tokenA.safeTransfer(msg.sender, amountA);
        tokenB.safeTransfer(msg.sender, amountB);

        emit Burn(msg.sender, amountA, amountB, liquidity);
    }

    function swapExactTokensForTokens(
        IERC20 tokenIn,
        IERC20 tokenOut,
        uint256 amountIn,
        uint256 amountOutMin
    ) external returns (uint256 amountOut) {
        uint256 reserveIn = tokenIn.balanceOf(address(this));
        uint256 reserveOut = tokenOut.balanceOf(address(this));

        require(
            amountIn <= (reserveIn * maxSwapPercentage) / 100,
            "Exceeds max swap percentage"
        );

        uint256 amountInWithFee = (amountIn * (100 - feePercentage)) / 100;

        amountOut = (amountInWithFee * reserveOut) / reserveIn;

        require(amountOut >= amountOutMin, "Insufficient output amount");

        tokenIn.safeTransferFrom(msg.sender, address(this), amountIn);
        tokenOut.safeTransfer(msg.sender, amountOut);
    }

    function swapTokensForExactTokens(
        IERC20 tokenIn,
        IERC20 tokenOut,
        uint256 amountInMax,
        uint256 amountOut
    ) external returns (uint256 amountIn) {
        uint256 reserveIn = tokenIn.balanceOf(address(this));
        uint256 reserveOut = tokenOut.balanceOf(address(this));

        require(
            amountOut <= (reserveOut * maxSwapPercentage) / 100,
            "Exceeds max swap percentage"
        );

        amountIn = (amountOut * reserveIn) / reserveOut;

        amountIn = (amountIn * 100) / (100 - feePercentage);

        require(amountIn <= amountInMax, "Excessive input amount");

        tokenIn.safeTransferFrom(msg.sender, address(this), amountIn);
        tokenOut.safeTransfer(msg.sender, amountOut);
    }
}
