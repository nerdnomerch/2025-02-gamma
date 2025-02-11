// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {MockLP} from "./MockLP.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockDex {
    bool DEBUG = true;

    mapping(address => mapping(address => address)) public getPair;

    event PairCreated(address tokenA, address tokenB, address pair);
    event LiquidityAdded(
        address sender,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
    event LiquidityRemoved(
        address sender,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
    event Swap(
        address sender,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    function getTokenTransferProxy() public view returns (address) {
        return address(this);
    }

    function createPair(
        address tokenA,
        address tokenB,
        uint256 feePercentage,
        uint256 maxSwapPercentage,
        string memory name,
        string memory symbol
    ) public returns (address pair) {
        require(tokenA != tokenB, "DEX: IDENTICAL_ADDRESSES");
        require(getPair[tokenA][tokenB] == address(0), "DEX: PAIR_EXISTS");

        pair = address(
            new MockLP(
                IERC20(tokenA),
                IERC20(tokenB),
                feePercentage,
                maxSwapPercentage,
                name,
                symbol
            )
        );

        getPair[tokenA][tokenB] = pair;
        getPair[tokenB][tokenA] = pair;

        IERC20(tokenA).approve(pair, type(uint256).max);
        IERC20(tokenB).approve(pair, type(uint256).max);

        emit PairCreated(tokenA, tokenB, pair);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) public {
        address pair = getPair[tokenA][tokenB];
        require(pair != address(0), "DEX: PAIR_DOES_NOT_EXIST");

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);

        (uint256 amountA, uint256 amountB, uint256 liquidity) = MockLP(pair)
            .addLiquidity(amountADesired, amountBDesired, amountAMin);

        IERC20(tokenA).transfer(msg.sender, amountADesired - amountA);
        IERC20(tokenB).transfer(msg.sender, amountBDesired - amountB);
        IERC20(pair).transfer(msg.sender, liquidity);

        emit LiquidityAdded(
            msg.sender,
            tokenA,
            tokenB,
            amountA,
            amountB,
            liquidity
        );
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin
    ) public {
        address pair = getPair[tokenA][tokenB];
        require(pair != address(0), "DEX: PAIR_DOES_NOT_EXIST");

        IERC20(pair).transferFrom(msg.sender, address(this), liquidity);

        (uint256 amountA, uint256 amountB) = MockLP(pair).removeLiquidity(
            liquidity,
            amountAMin,
            amountBMin
        );

        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        emit LiquidityRemoved(
            msg.sender,
            tokenA,
            tokenB,
            amountA,
            amountB,
            liquidity
        );
    }

    function swapExactTokensForTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin
    ) public {
        address pair = getPair[tokenIn][tokenOut];
        require(pair != address(0), "DEX: PAIR_DOES_NOT_EXIST");

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        uint256 amountOut = MockLP(pair).swapExactTokensForTokens(
            IERC20(tokenIn),
            IERC20(tokenOut),
            amountIn,
            amountOutMin
        );

        IERC20(tokenOut).transfer(msg.sender, amountOut);

        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }

    function swapTokensForExactTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountInMax,
        uint256 amountOut
    ) public {
        address pair = getPair[tokenIn][tokenOut];
        require(pair != address(0), "DEX: PAIR_DOES_NOT_EXIST");

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountInMax);

        uint256 amountIn = MockLP(pair).swapTokensForExactTokens(
            IERC20(tokenIn),
            IERC20(tokenOut),
            amountInMax,
            amountOut
        );

        IERC20(tokenOut).transfer(msg.sender, amountOut);
        IERC20(tokenIn).transfer(msg.sender, amountInMax - amountIn);

        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }
}
