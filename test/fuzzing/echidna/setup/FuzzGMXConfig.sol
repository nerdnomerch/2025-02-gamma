// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/FuzzUtils.sol";

/*
 * Percentage representation:
 * "50%" --> 5e29
 * "1%" --> 1e28
 * "0.1%" --> 1e27
 * "0.01%" --> 1e26
 */

contract FuzzGMXConfig is FuzzUtils {
    uint256 internal WETH_TOKEN_TRANSFER_GAS_LIMIT = 200 * 1000;
    uint256 internal WBTC_TOKEN_TRANSFER_GAS_LIMIT = 200 * 1000;
    uint256 internal USDC_TOKEN_TRANSFER_GAS_LIMIT = 200 * 1000;
    uint256 internal USDT_TOKEN_TRANSFER_GAS_LIMIT = 200 * 1000;

    address internal FEE_RECEIVER = address(0);
    address internal HOLDING_ADDRESS = address(0);

    uint256 internal MAX_UI_FEE_FACTOR = 50e24;
    uint256 internal MAX_AUTO_CANCEL_ORDERS = 10;
    uint256 internal MIN_HANDLE_EXECUTION_ERROR_GAS = 120 * 1000;
    uint256 internal MIN_HANDLE_EXECUTION_ERROR_GAS_TO_FORWARD = 1000 * 1000;
    uint256 internal MIN_ADDITIONAL_GAS_FOR_EXECUTION = 1000 * 1000;
    uint256 internal MAX_CALLBACK_GAS_LIMIT = 2000 * 1000;
    uint256 internal MAX_SWAP_PATH_LENGTH = 5;
    uint256 internal MIN_COLLATERAL_USD = 1000e27;
    uint256 internal MIN_POSITION_SIZE_USD = 1000e27;

    uint256 internal SWAP_FEE_RECEIVER_FACTOR = 37e28;
    uint256 internal POSITION_FEE_RECEIVER_FACTOR = 0;
    uint256 internal BORROWING_FEE_RECEIVER_FACTOR = 0;

    uint256 internal CLAIMABLE_COLLATERAL_TIME_DIVISOR = 3600;

    uint256 internal DEPOSIT_GAS_LIMIT = 0;
    uint256 internal WITHDRAWAL_GAS_LIMIT = 0;
    uint256 internal SINGLE_SWAP_GAS_LIMIT = 0;
    uint256 internal INCREASE_ORDER_GAS_LIMIT = 0;
    uint256 internal DECREASE_ORDER_GAS_LIMIT = 0;
    uint256 internal SWAP_ORDER_GAS_LIMIT = 0;

    uint256 internal NATIVE_TOKEN_TRANSFER_GAS_LIMIT = 50000;

    uint256 internal ESTIMATED_GAS_FEE_BASE_AMOUNT = 1000000;
    uint256 internal ESTIMATED_GAS_FEE_BASE_AMOUNT_V2_1 = 1000000;
    uint256 internal EXECUTION_GAS_FEE_PER_ORACLE_PRICE = 20000;
    uint256 internal EXECUTION_GAS_FEE_MULTIPLIER_FACTOR = 2e30;
    uint256 internal REFUND_EXECUTION_FEE_GAS_LIMIT = 1_000_000;

    bool internal SKIP_BORROWING_FEE_FOR_SMALLER_SIDE = false;
    uint256 internal REQUEST_EXPIRATION_TIME = 3600;

    uint256 internal MIN_ORACLE_SIGNERS = 0;

    int256 internal USDC_INIT_PRICE = 100000000;
    int256 internal USDT_INIT_PRICE = 100000000;

    bool internal IS_ORACLE_PROVIDER_ENABLED = true;
    bool internal IS_ATOMIC_ORACLE_PROVIDER = true;

    uint256 internal MIN_ORACLE_BLOCK_CONFIRMATIONS = 255;
    uint256 internal MAX_ORACLE_TIMESTAMP_RANGE = 60;
    uint256 internal MAX_ORACLE_REF_PRICE_DEVIATION_FACTOR = 5e29;
    address internal CHAINLINK_PAYMENT_TOKEN =
        0x99bbA657f2BbC93c02D617f8bA121cB8Fc104Acf;

    bytes32 internal ORACLE_TYPE_DEFAULT =
        keccak256(abi.encode("one-percent-per-minute"));
    address internal ORACLE_PROVIDER_FOR_TOKEN;
    uint256 internal PRICE_FEED_MULTIPLIER = 1e46;
    uint256 internal PRICE_FEED_HEARTBEAT_DURATION = 86400;

    address SOL = _getSyntheticTokenAddress("SOL");

    bytes32 internal DEFAULT_MARKET_TYPE = keccak256(abi.encode("basic-v1"));

    uint256 internal MAX_POOL_AMOUNT_WETH = 1_000_000_000e18;
    uint256 internal MAX_POOL_AMOUNT_USDC = 1_000_000_000e30;
    uint256 internal MAX_POOL_AMOUNT_USDT = 1_000_000_000e30;
    uint internal MAX_POOL_AMOUNT_WBTC = 1_000_000_000e18;

    uint256 internal MAX_POOL_USD_FOR_DEPOSIT_WETH = 1_000_000_000_000_000e30;
    uint256 internal MAX_POOL_USD_FOR_DEPOSIT_WBTC = 1_000_000_000_000_000e30;
    uint256 internal MAX_POOL_USD_FOR_DEPOSIT_USDC = 1_000_000_000_000_000e30;

    uint256 internal MIN_COLLATERAL_FACTOR = 1e28;
    uint256 internal MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER_LONG =
        0;
    uint256 internal MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER_SHORT =
        0;
    uint256 internal MAX_OPEN_INTEREST_LONG = 1000_000_000e30;
    uint256 internal MAX_OPEN_INTEREST_SHORT = 1000_000_000e30;
    uint256 internal RESERVE_FACTOR_LONG = 5e29;
    uint256 internal RESERVE_FACTOR_SHORT = 5e29;
    uint256 internal OPEN_INTEREST_RESERVE_FACTOR_LONG = 5e29;
    uint256 internal OPEN_INTEREST_RESERVE_FACTOR_SHORT = 5e29;

    uint256 internal MAX_PNL_FACTOR_LONG = 5e29;
    uint256 internal MAX_PNL_FACTOR_SHORT = 5e29;
    uint256 internal MAX_PNL_FACTOR_FOR_TRADERS_LONG = 5e29;
    uint256 internal MAX_PNL_FACTOR_FOR_TRADERS_SHORT = 5e29;
    uint256 internal MAX_PNL_FACTOR_FOR_ADL_LONG = 45e28;
    uint256 internal MAX_PNL_FACTOR_FOR_ADL_SHORT = 45e28;
    uint256 internal MIN_PNL_FACTOR_AFTER_ADL_LONG = 40e28;
    uint256 internal MIN_PNL_FACTOR_AFTER_ADL_SHORT = 40e28;
    uint256 internal MAX_PNL_FACTOR_FOR_DEPOSITS_LONG = 60e28;
    uint256 internal MAX_PNL_FACTOR_FOR_DEPOSITS_SHORT = 60e28; //0.6
    uint256 internal MAX_PNL_FACTOR_FOR_WITHDRAWALS_LONG = 30e28;
    uint256 internal MAX_PNL_FACTOR_FOR_WITHDRAWALS_SHORT = 30e28;
    uint256 internal MARKET_TOKEN_TRANSFER_GAS_LIMIT = 200 * 1000;
    uint256 internal MAX_POSITION_IMPACT_FACTOR_FOR_LIQUIDATIONS = 1e28;
    uint256 internal POSITION_IMPACT_FACTOR_POSITIVE = 2e28;
    uint256 internal POSITION_IMPACT_FACTOR_NEGATIVE = 2e28;

    uint256 internal SWAP_FEE_FACTOR_POSITIVE_IMPACT = 5e26; //0.05%
    uint256 internal SWAP_FEE_FACTOR_NEGATIVE_IMPACT = 7e26; //0.07%
    uint256 internal SWAP_FEE_FACTOR_POSITIVE_IMPACT_SINGLE_TOKEN = 5e26; //0.05%
    uint256 internal SWAP_FEE_FACTOR_NEGATIVE_IMPACT_SINGLE_TOKEN = 7e26; //0.07%
    uint256 internal ATOMIC_SWAP_FEE_FACTOR = 2e28; //2%

    //--- funding

    uint256 internal FUNDING_FACTOR = 1e25;
    uint256 internal FUNDING_EXPONENT_FACTOR = 1e30;

    uint256 internal THRESHOLD_FOR_STABLE_FUNDING = 0; // 5e28;
    uint256 internal THRESHOLD_FOR_DECREASE_FUNDING = 0; //3e28;
    uint256 internal FUNDING_INCREASE_FACTOR_PER_SECOND = 0; // 1e24;
    uint256 internal FUNDING_DECREASE_FACTOR_PER_SECOND = 0; //2e22;
    uint256 internal MIN_FUNDING_FACTOR_PER_SECOND = 1e25; //3e20
    uint256 internal MAX_FUNDING_FACTOR_PER_SECOND = 1e30; //1e30;

    //--- v2.1 remediation

    uint256 internal EXECUTION_GAS_FEE_BASE_AMOUNT_V2_1 = 1_000_000;
    uint256 internal MAX_TOTAL_CALLBACK_GAS_LIMIT_FOR_AUTO_CANCEL_ORDERS =
        5_000_000;

    //---- GAMMA
    uint256 internal ESTIMATED_GAS_FEE_PER_ORACLE_PRICE = 0;
}
