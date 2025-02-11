// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../properties/BeforeAfter.sol";

contract LiquidationCoverage is BeforeAfter {
    //       /\_/\           ___
    //    = o_o =_______    \ \    LIQUIDATION COVERAGE
    //     __^      __(  \.__) )
    // (@)<_____>__(_____)____/

    function _checkPositionLiquitatableCoverage(
        address account,
        address market,
        address collateralToken,
        bool isLong,
        PositionUtils.IsPositionLiquidatableInfo
            memory isPositionLiquidatableInfo
    ) internal {
        _logLiquidationAccountCoverage(account);
        _logLiquidationMarketCoverage(market);
        _logLiquidationCollateralTokenCoverage(collateralToken);
        _logLiquidationIsLongCoverage(isLong);
        _logRemainingCollateralUsdCoverage(
            isPositionLiquidatableInfo.remainingCollateralUsd
        );
        _logMinCollateralUsdCoverage(
            isPositionLiquidatableInfo.minCollateralUsd
        );
        _logMinCollateralUsdForLeverageCoverage(
            isPositionLiquidatableInfo.minCollateralUsdForLeverage
        );
    }

    function _logLiquidationIsLongCoverage(bool isLong) internal {
        if (isLong) {
            fl.log("Liquidation isLong is true");
        } else {
            fl.log("Liquidation isLong is false");
        }
    }

    function _logLiquidationAccountCoverage(address account) internal {
        if (account == USER0) {
            fl.log("Account USER0 hit");
        }
        if (account == USER1) {
            fl.log("Account USER1 hit");
        }
        if (account == USER2) {
            fl.log("Account USER2 hit");
        }
        if (account == USER3) {
            fl.log("Account USER3 hit");
        }
        if (account == USER4) {
            fl.log("Account USER4 hit");
        }
        if (account == USER5) {
            fl.log("Account USER5 hit");
        }
        if (account == USER6) {
            fl.log("Account USER6 hit");
        }
        if (account == USER7) {
            fl.log("Account USER7 hit");
        }
        if (account == USER8) {
            fl.log("Account USER8 hit");
        }
        if (account == USER9) {
            fl.log("Account USER9 hit");
        }
        if (account == USER10) {
            fl.log("Account USER10 hit");
        }
        if (account == USER11) {
            fl.log("Account USER11 hit");
        }
        if (account == USER12) {
            fl.log("Account USER12 hit");
        }
        if (account == USER13) {
            fl.log("Account USER13 hit");
        }
    }

    function _logLiquidationMarketCoverage(address market) internal {
        if (market == address(market_0_WETH_USDC)) {
            fl.log("Market market_0_WETH_USDC hit");
        }

        if (market == address(market_WBTC_WBTC_USDC)) {
            fl.log("Market market_WBTC_WBTC_USDC hit");
        }
        if (market == address(market_WETH_WETH_USDC)) {
            fl.log("Market market_WETH_WETH_USDC hit");
        }
        if (market == address(market_WETH_WETH_USDT)) {
            fl.log("Market market_WETH_WETH_USDT hit");
        }
    }

    function _logLiquidationCollateralTokenCoverage(
        address collateralToken
    ) internal {
        if (collateralToken == address(WETH)) {
            fl.log("CollateralToken is WETH");
        }
        if (collateralToken == address(WBTC)) {
            fl.log("CollateralToken is WBTC");
        }
        if (collateralToken == address(USDC)) {
            fl.log("CollateralToken is USDC");
        }
        if (collateralToken == address(USDT)) {
            fl.log("CollateralToken is USDT");
        }
        if (collateralToken == address(SOL)) {
            fl.log("CollateralToken is SOL");
        }
    }
    function _logRemainingCollateralUsdCoverage(
        int256 remainingCollateralUsd
    ) internal {
        if (remainingCollateralUsd == 0) {
            fl.log("RemainingCollateralUsd is 0");
        }
        if (remainingCollateralUsd > 0 && remainingCollateralUsd <= 1e6) {
            fl.log("RemainingCollateralUsd is between 0 and 1e6");
        }
        if (remainingCollateralUsd > 1e6 && remainingCollateralUsd <= 1e12) {
            fl.log("RemainingCollateralUsd is between 1e6 and 1e12");
        }
        if (remainingCollateralUsd > 1e12 && remainingCollateralUsd <= 1e18) {
            fl.log("RemainingCollateralUsd is between 1e12 and 1e18");
        }
        if (remainingCollateralUsd > 1e18 && remainingCollateralUsd <= 1e24) {
            fl.log("RemainingCollateralUsd is between 1e18 and 1e24");
        }
        if (remainingCollateralUsd > 1e24) {
            fl.log("RemainingCollateralUsd is greater than 1e24");
        }
        if (remainingCollateralUsd < 0 && remainingCollateralUsd >= -1e6) {
            fl.log("RemainingCollateralUsd is between 0 and -1e6");
        }
        if (remainingCollateralUsd < -1e6 && remainingCollateralUsd >= -1e12) {
            fl.log("RemainingCollateralUsd is between -1e6 and -1e12");
        }
        if (remainingCollateralUsd < -1e12 && remainingCollateralUsd >= -1e18) {
            fl.log("RemainingCollateralUsd is between -1e12 and -1e18");
        }
        if (remainingCollateralUsd < -1e18 && remainingCollateralUsd >= -1e24) {
            fl.log("RemainingCollateralUsd is between -1e18 and -1e24");
        }
        if (remainingCollateralUsd < -1e24) {
            fl.log("RemainingCollateralUsd is less than -1e24");
        }
    }

    function _logMinCollateralUsdCoverage(int256 minCollateralUsd) internal {
        if (minCollateralUsd == 0) {
            fl.log("MinCollateralUsd is 0");
        }
        if (minCollateralUsd > 0 && minCollateralUsd <= 1e6) {
            fl.log("MinCollateralUsd is between 0 and 1e6");
        }
        if (minCollateralUsd > 1e6 && minCollateralUsd <= 1e12) {
            fl.log("MinCollateralUsd is between 1e6 and 1e12");
        }
        if (minCollateralUsd > 1e12 && minCollateralUsd <= 1e18) {
            fl.log("MinCollateralUsd is between 1e12 and 1e18");
        }
        if (minCollateralUsd > 1e18 && minCollateralUsd <= 1e24) {
            fl.log("MinCollateralUsd is between 1e18 and 1e24");
        }
        if (minCollateralUsd > 1e24) {
            fl.log("MinCollateralUsd is greater than 1e24");
        }
        if (minCollateralUsd < 0 && minCollateralUsd >= -1e6) {
            fl.log("MinCollateralUsd is between 0 and -1e6");
        }
        if (minCollateralUsd < -1e6 && minCollateralUsd >= -1e12) {
            fl.log("MinCollateralUsd is between -1e6 and -1e12");
        }
        if (minCollateralUsd < -1e12 && minCollateralUsd >= -1e18) {
            fl.log("MinCollateralUsd is between -1e12 and -1e18");
        }
        if (minCollateralUsd < -1e18 && minCollateralUsd >= -1e24) {
            fl.log("MinCollateralUsd is between -1e18 and -1e24");
        }
        if (minCollateralUsd < -1e24) {
            fl.log("MinCollateralUsd is less than -1e24");
        }
    }

    function _logMinCollateralUsdForLeverageCoverage(
        int256 minCollateralUsdForLeverage
    ) internal {
        if (minCollateralUsdForLeverage == 0) {
            fl.log("MinCollateralUsdForLeverage is 0");
        }
        if (
            minCollateralUsdForLeverage > 0 &&
            minCollateralUsdForLeverage <= 1e6
        ) {
            fl.log("MinCollateralUsdForLeverage is between 0 and 1e6");
        }
        if (
            minCollateralUsdForLeverage > 1e6 &&
            minCollateralUsdForLeverage <= 1e12
        ) {
            fl.log("MinCollateralUsdForLeverage is between 1e6 and 1e12");
        }
        if (
            minCollateralUsdForLeverage > 1e12 &&
            minCollateralUsdForLeverage <= 1e18
        ) {
            fl.log("MinCollateralUsdForLeverage is between 1e12 and 1e18");
        }
        if (
            minCollateralUsdForLeverage > 1e18 &&
            minCollateralUsdForLeverage <= 1e24
        ) {
            fl.log("MinCollateralUsdForLeverage is between 1e18 and 1e24");
        }
        if (minCollateralUsdForLeverage > 1e24) {
            fl.log("MinCollateralUsdForLeverage is greater than 1e24");
        }
        if (
            minCollateralUsdForLeverage < 0 &&
            minCollateralUsdForLeverage >= -1e6
        ) {
            fl.log("MinCollateralUsdForLeverage is between 0 and -1e6");
        }
        if (
            minCollateralUsdForLeverage < -1e6 &&
            minCollateralUsdForLeverage >= -1e12
        ) {
            fl.log("MinCollateralUsdForLeverage is between -1e6 and -1e12");
        }
        if (
            minCollateralUsdForLeverage < -1e12 &&
            minCollateralUsdForLeverage >= -1e18
        ) {
            fl.log("MinCollateralUsdForLeverage is between -1e12 and -1e18");
        }
        if (
            minCollateralUsdForLeverage < -1e18 &&
            minCollateralUsdForLeverage >= -1e24
        ) {
            fl.log("MinCollateralUsdForLeverage is between -1e18 and -1e24");
        }
        if (minCollateralUsdForLeverage < -1e24) {
            fl.log("MinCollateralUsdForLeverage is less than -1e24");
        }
    }
}
