// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../properties/BeforeAfter.sol";

contract DepositCoverage is BeforeAfter {
    //       /\_/\           ___
    //    = o_o =_______    \ \  CREATE DEPOSIT COVERAGE
    //     __^      __(  \.__) )
    // (@)<_____>__(_____)____/

    function _checkCreateDepositCoverage(
        address market,
        address longToken,
        address shortToken,
        TokenPrices memory tokenPrices,
        address user,
        uint longAmount,
        uint shortAmount
    ) internal {
        _logMarketCoverage_CreateDeposit(market);
        _logTokenCoverage_Long_CreateDeposit(
            longToken,
            "LongToken",
            _getTokenPrice(longToken, tokenPrices)
        );
        _logTokenCoverage_Short_CreateDeposit(
            shortToken,
            "ShortToken",
            _getTokenPrice(shortToken, tokenPrices)
        );
        _logUserCoverage_CreateDeposit(user);
        _logLongAmountCoverage_CreateDeposit(longAmount);
        _logShortAmountCoverage_CreateDeposit(shortAmount);
    }

    function _logUserCoverage_CreateDeposit(address user) internal {
        if (user == USER0) {
            fl.log("User USER0 hit");
        }
        if (user == USER1) {
            fl.log("User USER1 hit");
        }
        if (user == USER2) {
            fl.log("User USER2 hit");
        }
        if (user == USER3) {
            fl.log("User USER3 hit");
        }
        if (user == USER4) {
            fl.log("User USER4 hit");
        }
        if (user == USER5) {
            fl.log("User USER5 hit");
        }
        if (user == USER6) {
            fl.log("User USER6 hit");
        }
        if (user == USER7) {
            fl.log("User USER7 hit");
        }
        if (user == USER8) {
            fl.log("User USER8 hit");
        }
        if (user == USER9) {
            fl.log("User USER9 hit");
        }
        if (user == USER10) {
            fl.log("User USER10 hit");
        }
        if (user == USER11) {
            fl.log("User USER11 hit");
        }
        if (user == USER12) {
            fl.log("User USER12 hit");
        }
        if (user == USER13) {
            fl.log("User USER13 hit");
        }
    }

    function _logMarketCoverage_CreateDeposit(address market) internal {
        if (market == market_0_WETH_USDC) {
            fl.log("Market market_0_WETH_USDC hit");
        }

        if (market == market_WBTC_WBTC_USDC) {
            fl.log("Market market_WBTC_WBTC_USDC hit");
        }
        if (market == market_WETH_WETH_USDC) {
            fl.log("Market market_WETH_WETH_USDC hit");
        }
        if (market == market_WETH_WETH_USDT) {
            fl.log("Market market_WETH_WETH_USDT hit");
        }
    }

    //  /\_/\
    // ( o.o )
    //  > ^ < CREATE DEPOSIT: LONGS

    function _logTokenCoverage_Long_CreateDeposit(
        address token,
        string memory tokenType,
        uint256 price
    ) internal {
        if (token == address(WETH)) {
            fl.log(string(abi.encodePacked(tokenType, " WETH hit")));

            _logWETHPriceBucket_Long_CreateDeposit(price, token);
        }
        if (token == address(WBTC)) {
            fl.log(string(abi.encodePacked(tokenType, " WBTC hit")));

            _logWBTCPriceBucket_Long_CreateDeposit(price, token);
        }
        if (token == address(USDC)) {
            fl.log(string(abi.encodePacked(tokenType, " USDC hit")));
        }
        if (token == address(USDT)) {
            fl.log(string(abi.encodePacked(tokenType, " USDT hit")));
        }
    }
    function _logLongAmountCoverage_CreateDeposit(uint256 amount) internal {
        if (amount >= 0 && amount < 1e6) {
            fl.log("LongAmount bucket: 0 to 1e6");
        }
        if (amount >= 1e6 && amount < 1e12) {
            fl.log("LongAmount bucket: 1e6 to 1e12");
        }
        if (amount >= 1e12 && amount < 1e18) {
            fl.log("LongAmount bucket: 1e12 to 1e18");
        }
        if (amount >= 1e18 && amount < 1e24) {
            fl.log("LongAmount bucket: 1e18 to 1e24)");
        }
        if (amount >= 1e24) {
            fl.log("LongAmount bucket: 1e4) and  above");
        }
    }

    function _logWETHPriceBucket_Long_CreateDeposit(
        uint256 price,
        address token
    ) internal {
        if (
            price >= WETH_MIN_PRICE &&
            price < 10_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 1k to 10k was hit");
        }
        if (
            price >= 10_000e4 * (10 ** _getPrecision(token)) &&
            price < 100_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 10k to 100k was hit");
        }
        if (
            price >= 100_000e4 * (10 ** _getPrecision(token)) &&
            price < 300_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 100k to 300k was hit");
        }
        if (
            price >= 300_000e4 * (10 ** _getPrecision(token)) &&
            price < 400_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 300k to 400k was hit");
        }
        if (
            price >= 400_000e4 * (10 ** _getPrecision(token)) &&
            price < 500_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 400k to 500k was hit");
        }
        if (
            price >= 500_000e4 * (10 ** _getPrecision(token)) &&
            price < 600_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 500k to 600k was hit");
        }
        if (
            price >= 600_000e4 * (10 ** _getPrecision(token)) &&
            price < 700_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 600k to 700k was hit");
        }
        if (
            price >= 700_000e4 * (10 ** _getPrecision(token)) &&
            price < 800_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 700k to 800k was hit");
        }
        if (
            price >= 800_000e4 * (10 ** _getPrecision(token)) &&
            price < 900_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 800k to 900k was hit");
        }
        if (
            price >= 900_000e4 * (10 ** _getPrecision(token)) &&
            price < WETH_MAX_PRICE * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 900k to 1m was hit");
        }
    }

    function _logWBTCPriceBucket_Long_CreateDeposit(
        uint256 price,
        address token
    ) internal {
        if (
            price >= WBTC_MIN_PRICE &&
            price < 10_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 1k to 10k was hit");
        }
        if (
            price >= 10_000e2 * (10 ** _getPrecision(token)) &&
            price < 100_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 10k to 100k was hit");
        }
        if (
            price >= 100_000e2 * (10 ** _getPrecision(token)) &&
            price < 300_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 100k to 300k was hit");
        }
        if (
            price >= 300_000e2 * (10 ** _getPrecision(token)) &&
            price < 400_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 300k to 400k was hit");
        }
        if (
            price >= 400_000e2 * (10 ** _getPrecision(token)) &&
            price < 500_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 400k to 500k was hit");
        }
        if (
            price >= 500_000e2 * (10 ** _getPrecision(token)) &&
            price < 600_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 500k to 600k was hit");
        }
        if (
            price >= 600_000e2 * (10 ** _getPrecision(token)) &&
            price < 700_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 600k to 700k was hit");
        }
        if (
            price >= 700_000e2 * (10 ** _getPrecision(token)) &&
            price < 800_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 700k to 800k was hit");
        }
        if (
            price >= 800_000e2 * (10 ** _getPrecision(token)) &&
            price < 900_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 800k to 900k was hit");
        }
        if (
            price >= 900_000e2 * (10 ** _getPrecision(token)) &&
            price < WBTC_MAX_PRICE * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 900k to 1m was hit");
        }
    }

    //  /\_/\
    // ( o.o )
    //  > ^ < CREATE DEPOSIT: SHORTS

    function _logTokenCoverage_Short_CreateDeposit(
        address token,
        string memory tokenType,
        uint256 price
    ) internal {
        if (token == address(WETH)) {
            fl.log(string(abi.encodePacked(tokenType, " WETH hit")));
            _logWETHPriceBucket_Short_CreateDeposit(price, token);
        }
        if (token == address(WBTC)) {
            fl.log(string(abi.encodePacked(tokenType, " WBTC hit")));
            _logWBTCPriceBucket_Short_CreateDeposit(price, token);
        }
        if (token == address(USDC)) {
            fl.log(string(abi.encodePacked(tokenType, " USDC hit")));
        }
        if (token == address(USDT)) {
            fl.log(string(abi.encodePacked(tokenType, " USDT hit")));
        }
        if (token == address(SOL)) {
            fl.log(string(abi.encodePacked(tokenType, " SOL hit")));
        }
    }

    function _logShortAmountCoverage_CreateDeposit(uint256 amount) internal {
        if (amount >= 0 && amount < 1e6) {
            fl.log("ShortAmount bucket: 0 to 1e6");
        }
        if (amount >= 1e6 && amount < 1e12) {
            fl.log("ShortAmount bucket: 1e6 to 1e12");
        }
        if (amount >= 1e12 && amount < 1e18) {
            fl.log("ShortAmount bucket: 1e12 to 1e18");
        }
        if (amount >= 1e18 && amount < 1e24) {
            fl.log("ShortAmount bucket: 1e18 to 1e24");
        }
        if (amount >= 1e24) {
            fl.log("ShortAmount bucket: 1e24 and above");
        }
    }

    function _logWETHPriceBucket_Short_CreateDeposit(
        uint256 price,
        address token
    ) internal {
        if (
            price >= WETH_MIN_PRICE &&
            price < 10_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 1k to 10k was hit");
        }
        if (
            price >= 10_000e4 * (10 ** _getPrecision(token)) &&
            price < 100_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 10k to 100k was hit");
        }
        if (
            price >= 100_000e4 * (10 ** _getPrecision(token)) &&
            price < 300_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 100k to 300k was hit");
        }
        if (
            price >= 300_000e4 * (10 ** _getPrecision(token)) &&
            price < 400_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 300k to 400k was hit");
        }
        if (
            price >= 400_000e4 * (10 ** _getPrecision(token)) &&
            price < 500_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 400k to 500k was hit");
        }
        if (
            price >= 500_000e4 * (10 ** _getPrecision(token)) &&
            price < 600_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 500k to 600k was hit");
        }
        if (
            price >= 600_000e4 * (10 ** _getPrecision(token)) &&
            price < 700_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 600k to 700k was hit");
        }
        if (
            price >= 700_000e4 * (10 ** _getPrecision(token)) &&
            price < 800_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 700k to 800k was hit");
        }
        if (
            price >= 800_000e4 * (10 ** _getPrecision(token)) &&
            price < 900_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 800k to 900k was hit");
        }
        if (
            price >= 900_000e4 * (10 ** _getPrecision(token)) &&
            price < WETH_MAX_PRICE * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 900k to 1m was hit");
        }
    }
    function _logWBTCPriceBucket_Short_CreateDeposit(
        uint256 price,
        address token
    ) internal {
        if (
            price >= WBTC_MIN_PRICE &&
            price < 10_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 1k to 10k was hit");
        }
        if (
            price >= 10_000e2 * (10 ** _getPrecision(token)) &&
            price < 100_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 10k to 100k was hit");
        }
        if (
            price >= 100_000e2 * (10 ** _getPrecision(token)) &&
            price < 300_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 100k to 300k was hit");
        }
        if (
            price >= 300_000e2 * (10 ** _getPrecision(token)) &&
            price < 400_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 300k to 400k was hit");
        }
        if (
            price >= 400_000e2 * (10 ** _getPrecision(token)) &&
            price < 500_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 400k to 500k was hit");
        }
        if (
            price >= 500_000e2 * (10 ** _getPrecision(token)) &&
            price < 600_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 500k to 600k was hit");
        }
        if (
            price >= 600_000e2 * (10 ** _getPrecision(token)) &&
            price < 700_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 600k to 700k was hit");
        }
        if (
            price >= 700_000e2 * (10 ** _getPrecision(token)) &&
            price < 800_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 700k to 800k was hit");
        }
        if (
            price >= 800_000e2 * (10 ** _getPrecision(token)) &&
            price < 900_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 800k to 900k was hit");
        }
        if (
            price >= 900_000e2 * (10 ** _getPrecision(token)) &&
            price < WBTC_MAX_PRICE * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 900k to 1m was hit");
        }
    }

    function _logSOLPriceBucket_Short_CreateDeposit(
        uint256 price,
        address token
    ) internal {
        if (
            price >= SOL_MIN_PRICE &&
            price < 100e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 1 to 100 was hit");
        }
        if (
            price >= 1000e4 * (10 ** _getPrecision(token)) &&
            price < 10_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 1k to 10k was hit");
        }
        if (
            price >= 10_000e4 * (10 ** _getPrecision(token)) &&
            price < 100_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 10k to 100k was hit");
        }
        if (
            price >= 100_000e4 * (10 ** _getPrecision(token)) &&
            price < 200_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 100k to 200k was hit");
        }
        if (
            price >= 200_000e4 * (10 ** _getPrecision(token)) &&
            price < 500_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 200k to 500k was hit");
        }
        if (
            price >= 500_000e4 * (10 ** _getPrecision(token)) &&
            price < 600_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 500k to 600k was hit");
        }
        if (
            price >= 600_000e4 * (10 ** _getPrecision(token)) &&
            price < 700_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 600k to 700k was hit");
        }
        if (
            price >= 700_000e4 * (10 ** _getPrecision(token)) &&
            price < 800_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 700k to 800k was hit");
        }
        if (
            price >= 800_000e4 * (10 ** _getPrecision(token)) &&
            price < 900_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 800k to 900k was hit");
        }
        if (
            price >= 900_000e4 * (10 ** _getPrecision(token)) &&
            price < SOL_MAX_PRICE * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 900k to 1m was hit");
        }
    }

    //       /\_/\           ___
    //    = o_o =_______    \ \  CANCEL DEPOSIT COVERAGE
    //     __^      __(  \.__) )
    // (@)<_____>__(_____)____/

    function _checkCancelDepositCoverage(
        address market,
        address longToken,
        address shortToken,
        TokenPrices memory tokenPrices,
        address user,
        uint longAmount,
        uint shortAmount
    ) internal {
        _logMarketCoverage_CancelDeposit(market);
        _logTokenCoverage_Long_CancelDeposit(
            longToken,
            "LongToken",
            _getTokenPrice(longToken, tokenPrices)
        );
        _logTokenCoverage_Short_CancelDeposit(
            shortToken,
            "ShortToken",
            _getTokenPrice(shortToken, tokenPrices)
        );
        _logUserCoverage_CancelDeposit(user);
        _logLongAmountCoverage_CancelDeposit(longAmount);
        _logShortAmountCoverage_CancelDeposit(shortAmount);
    }

    function _logUserCoverage_CancelDeposit(address user) internal {
        if (user == USER0) {
            fl.log("User USER0 hit");
        }
        if (user == USER1) {
            fl.log("User USER1 hit");
        }
        if (user == USER2) {
            fl.log("User USER2 hit");
        }
        if (user == USER3) {
            fl.log("User USER3 hit");
        }
        if (user == USER4) {
            fl.log("User USER4 hit");
        }
        if (user == USER5) {
            fl.log("User USER5 hit");
        }
        if (user == USER6) {
            fl.log("User USER6 hit");
        }
        if (user == USER7) {
            fl.log("User USER7 hit");
        }
        if (user == USER8) {
            fl.log("User USER8 hit");
        }
        if (user == USER9) {
            fl.log("User USER9 hit");
        }
        if (user == USER10) {
            fl.log("User USER10 hit");
        }
        if (user == USER11) {
            fl.log("User USER11 hit");
        }
        if (user == USER12) {
            fl.log("User USER12 hit");
        }
        if (user == USER13) {
            fl.log("User USER13 hit");
        }
    }

    function _logMarketCoverage_CancelDeposit(address market) internal {
        if (market == market_0_WETH_USDC) {
            fl.log("Market market_0_WETH_USDC hit");
        }

        if (market == market_WBTC_WBTC_USDC) {
            fl.log("Market market_WBTC_WBTC_USDC hit");
        }
        if (market == market_WETH_WETH_USDC) {
            fl.log("Market market_WETH_WETH_USDC hit");
        }
        if (market == market_WETH_WETH_USDT) {
            fl.log("Market market_WETH_WETH_USDT hit");
        }
    }

    //  /\_/\
    // ( o.o )
    //  > ^ < CANCEL DEPOSIT: LONGS

    function _logTokenCoverage_Long_CancelDeposit(
        address token,
        string memory tokenType,
        uint256 price
    ) internal {
        if (token == address(WETH)) {
            fl.log(string(abi.encodePacked(tokenType, " WETH hit")));
            _logWETHPriceBucket_Long_CancelDeposit(price, token);
        }
        if (token == address(WBTC)) {
            fl.log(string(abi.encodePacked(tokenType, " WBTC hit")));
            _logWBTCPriceBucket_Long_CancelDeposit(price, token);
        }
        if (token == address(USDC)) {
            fl.log(string(abi.encodePacked(tokenType, " USDC hit")));
        }
        if (token == address(USDT)) {
            fl.log(string(abi.encodePacked(tokenType, " USDT hit")));
        }

        if (token == address(SOL)) {
            fl.log(string(abi.encodePacked(tokenType, " SOL hit")));
            _logSOLPriceBucket_Long_CancelDeposit(price, token);
        }
    }

    function _logLongAmountCoverage_CancelDeposit(uint256 amount) internal {
        if (amount >= 0 && amount < 1e6) {
            fl.log("LongAmount bucket: 0 to 1e6");
        }
        if (amount >= 1e6 && amount < 1e12) {
            fl.log("LongAmount bucket: 1e6 to 1e12");
        }
        if (amount >= 1e12 && amount < 1e18) {
            fl.log("LongAmount bucket: 1e12 to 1e18");
        }
        if (amount >= 1e18 && amount < 1e24) {
            fl.log("LongAmount bucket: 1e18 to 1e24)");
        }
        if (amount >= 1e24) {
            fl.log("LongAmount bucket: 1e4) and  above");
        }
    }

    function _logWETHPriceBucket_Long_CancelDeposit(
        uint256 price,
        address token
    ) internal {
        if (
            price >= WETH_MIN_PRICE &&
            price < 10_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 1k to 10k was hit");
        }
        if (
            price >= 10_000e4 * (10 ** _getPrecision(token)) &&
            price < 100_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 10k to 100k was hit");
        }
        if (
            price >= 100_000e4 * (10 ** _getPrecision(token)) &&
            price < 300_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 100k to 300k was hit");
        }
        if (
            price >= 300_000e4 * (10 ** _getPrecision(token)) &&
            price < 400_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 300k to 400k was hit");
        }
        if (
            price >= 400_000e4 * (10 ** _getPrecision(token)) &&
            price < 500_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 400k to 500k was hit");
        }
        if (
            price >= 500_000e4 * (10 ** _getPrecision(token)) &&
            price < 600_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 500k to 600k was hit");
        }
        if (
            price >= 600_000e4 * (10 ** _getPrecision(token)) &&
            price < 700_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 600k to 700k was hit");
        }
        if (
            price >= 700_000e4 * (10 ** _getPrecision(token)) &&
            price < 800_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 700k to 800k was hit");
        }
        if (
            price >= 800_000e4 * (10 ** _getPrecision(token)) &&
            price < 900_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 800k to 900k was hit");
        }
        if (
            price >= 900_000e4 * (10 ** _getPrecision(token)) &&
            price < WETH_MAX_PRICE * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 900k to 1m was hit");
        }
    }
    function _logWBTCPriceBucket_Long_CancelDeposit(
        uint256 price,
        address token
    ) internal {
        if (
            price >= WBTC_MIN_PRICE &&
            price < 10_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 1k to 10k was hit");
        }
        if (
            price >= 10_000e2 * (10 ** _getPrecision(token)) &&
            price < 100_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 10k to 100k was hit");
        }
        if (
            price >= 100_000e2 * (10 ** _getPrecision(token)) &&
            price < 300_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 100k to 300k was hit");
        }
        if (
            price >= 300_000e2 * (10 ** _getPrecision(token)) &&
            price < 400_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 300k to 400k was hit");
        }
        if (
            price >= 400_000e2 * (10 ** _getPrecision(token)) &&
            price < 500_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 400k to 500k was hit");
        }
        if (
            price >= 500_000e2 * (10 ** _getPrecision(token)) &&
            price < 600_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 500k to 600k was hit");
        }
        if (
            price >= 600_000e2 * (10 ** _getPrecision(token)) &&
            price < 700_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 600k to 700k was hit");
        }
        if (
            price >= 700_000e2 * (10 ** _getPrecision(token)) &&
            price < 800_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 700k to 800k was hit");
        }
        if (
            price >= 800_000e2 * (10 ** _getPrecision(token)) &&
            price < 900_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 800k to 900k was hit");
        }
        if (
            price >= 900_000e2 * (10 ** _getPrecision(token)) &&
            price < WBTC_MAX_PRICE * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 900k to 1m was hit");
        }
    }
    function _logSOLPriceBucket_Long_CancelDeposit(
        uint256 price,
        address token
    ) internal {
        if (
            price >= SOL_MIN_PRICE &&
            price < 100e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 1 to 100 was hit");
        }
        if (
            price >= 1000e4 * (10 ** _getPrecision(token)) &&
            price < 10_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 1k to 10k was hit");
        }
        if (
            price >= 10_000e4 * (10 ** _getPrecision(token)) &&
            price < 100_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 10k to 100k was hit");
        }
        if (
            price >= 100_000e4 * (10 ** _getPrecision(token)) &&
            price < 200_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 100k to 200k was hit");
        }
        if (
            price >= 200_000e4 * (10 ** _getPrecision(token)) &&
            price < 500_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 200k to 500k was hit");
        }
        if (
            price >= 500_000e4 * (10 ** _getPrecision(token)) &&
            price < 600_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 500k to 600k was hit");
        }
        if (
            price >= 600_000e4 * (10 ** _getPrecision(token)) &&
            price < 700_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 600k to 700k was hit");
        }
        if (
            price >= 700_000e4 * (10 ** _getPrecision(token)) &&
            price < 800_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 700k to 800k was hit");
        }
        if (
            price >= 800_000e4 * (10 ** _getPrecision(token)) &&
            price < 900_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 800k to 900k was hit");
        }
        if (
            price >= 900_000e4 * (10 ** _getPrecision(token)) &&
            price < SOL_MAX_PRICE * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 900k to 1m was hit");
        }
    }

    //  /\_/\
    // ( o.o )
    //  > ^ < CANCEL DEPOSIT: SHORTS

    function _logTokenCoverage_Short_CancelDeposit(
        address token,
        string memory tokenType,
        uint256 price
    ) internal {
        if (token == address(WETH)) {
            fl.log(string(abi.encodePacked(tokenType, " WETH hit")));
            _logWETHPriceBucket_Short_CancelDeposit(price, token);
        }
        if (token == address(WBTC)) {
            fl.log(string(abi.encodePacked(tokenType, " WBTC hit")));
            _logWBTCPriceBucket_Short_CancelDeposit(price, token);
        }
        if (token == address(USDC)) {
            fl.log(string(abi.encodePacked(tokenType, " USDC hit")));
        }
        if (token == address(USDT)) {
            fl.log(string(abi.encodePacked(tokenType, " USDT hit")));
        }
        if (token == address(SOL)) {
            fl.log(string(abi.encodePacked(tokenType, " SOL hit")));
            _logSOLPriceBucket_Short_CancelDeposit(price, token);
        }
    }

    function _logShortAmountCoverage_CancelDeposit(uint256 amount) internal {
        if (amount >= 0 && amount < 1e6) {
            fl.log("ShortAmount bucket: 0 to 1e6");
        }
        if (amount >= 1e6 && amount < 1e12) {
            fl.log("ShortAmount bucket: 1e6 to 1e12");
        }
        if (amount >= 1e12 && amount < 1e18) {
            fl.log("ShortAmount bucket: 1e12 to 1e18");
        }
        if (amount >= 1e18 && amount < 1e24) {
            fl.log("ShortAmount bucket: 1e18 to 1e24");
        }
        if (amount >= 1e24) {
            fl.log("ShortAmount bucket: 1e24 and above");
        }
    }

    function _logWETHPriceBucket_Short_CancelDeposit(
        uint256 price,
        address token
    ) internal {
        if (
            price >= WETH_MIN_PRICE &&
            price < 10_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 1k to 10k was hit");
        }
        if (
            price >= 10_000e4 * (10 ** _getPrecision(token)) &&
            price < 100_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 10k to 100k was hit");
        }
        if (
            price >= 100_000e4 * (10 ** _getPrecision(token)) &&
            price < 300_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 100k to 300k was hit");
        }
        if (
            price >= 300_000e4 * (10 ** _getPrecision(token)) &&
            price < 400_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 300k to 400k was hit");
        }
        if (
            price >= 400_000e4 * (10 ** _getPrecision(token)) &&
            price < 500_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 400k to 500k was hit");
        }
        if (
            price >= 500_000e4 * (10 ** _getPrecision(token)) &&
            price < 600_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 500k to 600k was hit");
        }
        if (
            price >= 600_000e4 * (10 ** _getPrecision(token)) &&
            price < 700_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 600k to 700k was hit");
        }
        if (
            price >= 700_000e4 * (10 ** _getPrecision(token)) &&
            price < 800_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 700k to 800k was hit");
        }
        if (
            price >= 800_000e4 * (10 ** _getPrecision(token)) &&
            price < 900_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 800k to 900k was hit");
        }
        if (
            price >= 900_000e4 * (10 ** _getPrecision(token)) &&
            price < WETH_MAX_PRICE * (10 ** _getPrecision(token))
        ) {
            fl.log("WETH price from 900k to 1m was hit");
        }
    }
    function _logWBTCPriceBucket_Short_CancelDeposit(
        uint256 price,
        address token
    ) internal {
        if (
            price >= WBTC_MIN_PRICE &&
            price < 10_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 1k to 10k was hit");
        }
        if (
            price >= 10_000e2 * (10 ** _getPrecision(token)) &&
            price < 100_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 10k to 100k was hit");
        }
        if (
            price >= 100_000e2 * (10 ** _getPrecision(token)) &&
            price < 300_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 100k to 300k was hit");
        }
        if (
            price >= 300_000e2 * (10 ** _getPrecision(token)) &&
            price < 400_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 300k to 400k was hit");
        }
        if (
            price >= 400_000e2 * (10 ** _getPrecision(token)) &&
            price < 500_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 400k to 500k was hit");
        }
        if (
            price >= 500_000e2 * (10 ** _getPrecision(token)) &&
            price < 600_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 500k to 600k was hit");
        }
        if (
            price >= 600_000e2 * (10 ** _getPrecision(token)) &&
            price < 700_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 600k to 700k was hit");
        }
        if (
            price >= 700_000e2 * (10 ** _getPrecision(token)) &&
            price < 800_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 700k to 800k was hit");
        }
        if (
            price >= 800_000e2 * (10 ** _getPrecision(token)) &&
            price < 900_000e2 * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 800k to 900k was hit");
        }
        if (
            price >= 900_000e2 * (10 ** _getPrecision(token)) &&
            price < WBTC_MAX_PRICE * (10 ** _getPrecision(token))
        ) {
            fl.log("WBTC price from 900k to 1m was hit");
        }
    }

    function _logSOLPriceBucket_Short_CancelDeposit(
        uint256 price,
        address token
    ) internal {
        if (
            price >= SOL_MIN_PRICE &&
            price < 100e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 1 to 100 was hit");
        }
        if (
            price >= 1000e4 * (10 ** _getPrecision(token)) &&
            price < 10_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 1k to 10k was hit");
        }
        if (
            price >= 10_000e4 * (10 ** _getPrecision(token)) &&
            price < 100_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 10k to 100k was hit");
        }
        if (
            price >= 100_000e4 * (10 ** _getPrecision(token)) &&
            price < 200_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 100k to 200k was hit");
        }
        if (
            price >= 200_000e4 * (10 ** _getPrecision(token)) &&
            price < 500_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 200k to 500k was hit");
        }
        if (
            price >= 500_000e4 * (10 ** _getPrecision(token)) &&
            price < 600_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 500k to 600k was hit");
        }
        if (
            price >= 600_000e4 * (10 ** _getPrecision(token)) &&
            price < 700_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 600k to 700k was hit");
        }
        if (
            price >= 700_000e4 * (10 ** _getPrecision(token)) &&
            price < 800_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 700k to 800k was hit");
        }
        if (
            price >= 800_000e4 * (10 ** _getPrecision(token)) &&
            price < 900_000e4 * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 800k to 900k was hit");
        }
        if (
            price >= 900_000e4 * (10 ** _getPrecision(token)) &&
            price < SOL_MAX_PRICE * (10 ** _getPrecision(token))
        ) {
            fl.log("SOL price from 900k to 1m was hit");
        }
    }

    //       /\_/\           ___
    //    = o_o =_______    \ \  EXECUTE DEPOSIT COVERAGE
    //     __^      __(  \.__) )
    // (@)<_____>__(_____)____/

    function _checkCoverageAfterDepositExecution(
        address market,
        uint userBalance,
        uint marketTotalSupply
    ) internal {
        _logMarketTokenBySupplyCoverage_ExecuteDeposit(
            market,
            marketTotalSupply
        );
        _logMarketAmountByUser(userBalance);
    }

    function _logMarketTokenBySupplyCoverage_ExecuteDeposit(
        address token,
        uint256 totalSupply
    ) internal {
        if (token == address(market_0_WETH_USDC)) {
            if (totalSupply >= 0 && totalSupply < 1e6) {
                fl.log("TotalSupply bucket: 0 to 1e6");
            }
            if (totalSupply >= 1e6 && totalSupply < 1e12) {
                fl.log("TotalSupply bucket: 1e6 to 1e12");
            }
            if (totalSupply >= 1e12 && totalSupply < 1e18) {
                fl.log("TotalSupply bucket: 1e12 to 1e18");
            }
            if (totalSupply >= 1e18 && totalSupply < 1e24) {
                fl.log("TotalSupply bucket: 1e18 to 1e24");
            }
            if (totalSupply >= 1e24) {
                fl.log("TotalSupply bucket: 1e24 and above");
            }
        }

        if (token == address(market_WBTC_WBTC_USDC)) {
            if (totalSupply >= 0 && totalSupply < 1e6) {
                fl.log("TotalSupply bucket: 0 to 1e6");
            }
            if (totalSupply >= 1e6 && totalSupply < 1e12) {
                fl.log("TotalSupply bucket: 1e6 to 1e12");
            }
            if (totalSupply >= 1e12 && totalSupply < 1e18) {
                fl.log("TotalSupply bucket: 1e12 to 1e18");
            }
            if (totalSupply >= 1e18 && totalSupply < 1e24) {
                fl.log("TotalSupply bucket: 1e18 to 1e24");
            }
            if (totalSupply >= 1e24) {
                fl.log("TotalSupply bucket: 1e24 and above");
            }
        }
        if (token == address(market_WETH_WETH_USDC)) {
            if (totalSupply >= 0 && totalSupply < 1e6) {
                fl.log("TotalSupply bucket: 0 to 1e6");
            }
            if (totalSupply >= 1e6 && totalSupply < 1e12) {
                fl.log("TotalSupply bucket: 1e6 to 1e12");
            }
            if (totalSupply >= 1e12 && totalSupply < 1e18) {
                fl.log("TotalSupply bucket: 1e12 to 1e18");
            }
            if (totalSupply >= 1e18 && totalSupply < 1e24) {
                fl.log("TotalSupply bucket: 1e18 to 1e24");
            }
            if (totalSupply >= 1e24) {
                fl.log("TotalSupply bucket: 1e24 and above");
            }
        }
        if (token == address(market_WETH_WETH_USDT)) {
            if (totalSupply >= 0 && totalSupply < 1e6) {
                fl.log("TotalSupply bucket: 0 to 1e6");
            }
            if (totalSupply >= 1e6 && totalSupply < 1e12) {
                fl.log("TotalSupply bucket: 1e6 to 1e12");
            }
            if (totalSupply >= 1e12 && totalSupply < 1e18) {
                fl.log("TotalSupply bucket: 1e12 to 1e18");
            }
            if (totalSupply >= 1e18 && totalSupply < 1e24) {
                fl.log("TotalSupply bucket: 1e18 to 1e24");
            }
            if (totalSupply >= 1e24) {
                fl.log("TotalSupply bucket: 1e24 and above");
            }
        }
    }

    function _logMarketAmountByUser(uint256 amount) internal {
        if (amount >= 0 && amount < 1e6) {
            fl.log("Amount bucket: 0 to 1e6");
        }
        if (amount >= 1e6 && amount < 1e12) {
            fl.log("Amount bucket: 1e6 to 1e12");
        }
        if (amount >= 1e12 && amount < 1e18) {
            fl.log("Amount bucket: 1e12 to 1e18");
        }
        if (amount >= 1e18 && amount < 1e24) {
            fl.log("Amount bucket: 1e18 to 1e24");
        }
        if (amount >= 1e24) {
            fl.log("Amount bucket: 1e24 and above");
        }
    }
}
