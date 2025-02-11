// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../setup/FuzzSetup.sol";

contract FuzzConfig is FuzzSetup {
    //GMX CONFIG
    uint256 constant DECREASE_POSITION_DELTA_MIN = 1e30;
    uint256 constant RANDOMIZER_DIVISOR = 4545242;
    uint256 constant DECREASE_POSITION_TOLERABLE_PRICE_SUB = 1e10; //FROM 1e30

    uint256 constant WETH_MIN_PRICE = 1000e4;
    uint256 constant WBTC_MIN_PRICE = 1000e2;
    uint256 constant USDT_MIN_PRICE = 1e6;
    uint256 constant USDC_MIN_PRICE = 1e6;
    uint256 constant SOL_MIN_PRICE = 1e4;

    uint256 constant WETH_MAX_PRICE = 1_000_000e4;
    uint256 constant WBTC_MAX_PRICE = 1_000_000e2;
    uint256 constant USDT_MAX_PRICE = 1e6;
    uint256 constant USDC_MAX_PRICE = 1e6;
    uint256 constant SOL_MAX_PRICE = 1_000_000e4;

    //uint256 constant WETH_MAX_AMOUNT is a balance of native ETH or user
    uint256 constant WBTC_MAX_AMOUNT = 15_000e8;
    uint256 constant USDT_MAX_AMOUNT = 1000_000_000e6;
    uint256 constant USDC_MAX_AMOUNT = 1000_000_000e6;
    uint256 constant SOL_MAX_AMOUNT = 1000000e9;

    uint256 constant WETH_MIN_AMOUNT = 1e16;
    uint256 constant WBTC_MIN_AMOUNT = 1e6;
    uint256 constant USDT_MIN_AMOUNT = 1e6;
    uint256 constant USDC_MIN_AMOUNT = 1e6;
    uint256 constant SOL_MIN_AMOUNT = 1e8;

    uint256 constant FIXED_EXECUTION_FEE_AMOUNT = 1e10;
    bool constant SWAPS_ENABLED = false;
    uint constant MIN_AMOUNT_TO_SHIFT = 1e16;
}
