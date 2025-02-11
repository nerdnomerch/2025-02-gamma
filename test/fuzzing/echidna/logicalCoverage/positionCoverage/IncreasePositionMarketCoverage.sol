// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../properties/BeforeAfter.sol";

contract IncreasePositionMarketCoverage is BeforeAfter {
    //       /\_/\           ___
    //    = o_o =_______    \ \  INCREASE POSITION
    //     __^      __(  \.__) )  GET MARKET INFO
    // (@)<_____>__(_____)____/    COVERAGE

    function _checkIncreaseOrderAndGetMarketInfoCoverage(
        ReaderUtils.MarketInfo memory marketInfo
    ) internal {
        _logMarketInfoMarketTokenCoverage(marketInfo.market.marketToken);
        _logMarketInfoIndexTokenCoverage(marketInfo.market.indexToken);
        _logMarketInfoLongTokenCoverage(marketInfo.market.longToken);
        _logMarketInfoShortTokenCoverage(marketInfo.market.shortToken);
        _logMarketInfoBorrowingFactorPerSecondForLongsCoverage(
            marketInfo.borrowingFactorPerSecondForLongs
        );
        _logMarketInfoBorrowingFactorPerSecondForShortsCoverage(
            marketInfo.borrowingFactorPerSecondForShorts
        );
        _logMarketInfoBaseFundingLongFundingFeeAmountPerSizeCoverage(
            marketInfo.baseFunding.fundingFeeAmountPerSize.long
        );
        _logMarketInfoBaseFundingShortFundingFeeAmountPerSizeCoverage(
            marketInfo.baseFunding.fundingFeeAmountPerSize.short
        );
        _logMarketInfoBaseFundingLongClaimableFundingAmountPerSizeCoverage(
            marketInfo.baseFunding.claimableFundingAmountPerSize.long
        );
        _logMarketInfoBaseFundingShortClaimableFundingAmountPerSizeCoverage(
            marketInfo.baseFunding.claimableFundingAmountPerSize.short
        );
        _logMarketInfoNextFundingLongsPayShortsCoverage(
            marketInfo.nextFunding.longsPayShorts
        );
        _logMarketInfoNextFundingFundingFactorPerSecondCoverage(
            marketInfo.nextFunding.fundingFactorPerSecond
        );
        _logMarketInfoNextFundingNextSavedFundingFactorPerSecondCoverage(
            marketInfo.nextFunding.nextSavedFundingFactorPerSecond
        );
        _logMarketInfoNextFundingLongFundingFeeAmountPerSizeDeltaCoverage(
            marketInfo.nextFunding.fundingFeeAmountPerSizeDelta.long
        );
        _logMarketInfoNextFundingShortFundingFeeAmountPerSizeDeltaCoverage(
            marketInfo.nextFunding.fundingFeeAmountPerSizeDelta.short
        );
        _logMarketInfoNextFundingLongClaimableFundingAmountPerSizeDeltaCoverage(
            marketInfo.nextFunding.claimableFundingAmountPerSizeDelta.long
        );
        _logMarketInfoNextFundingShortClaimableFundingAmountPerSizeDeltaCoverage(
            marketInfo.nextFunding.claimableFundingAmountPerSizeDelta.short
        );
        _logMarketInfoVirtualInventoryVirtualPoolAmountForLongTokenCoverage(
            marketInfo.virtualInventory.virtualPoolAmountForLongToken
        );
        _logMarketInfoVirtualInventoryVirtualPoolAmountForShortTokenCoverage(
            marketInfo.virtualInventory.virtualPoolAmountForShortToken
        );
        _logMarketInfoVirtualInventoryVirtualInventoryForPositionsCoverage(
            marketInfo.virtualInventory.virtualInventoryForPositions
        );
        _logMarketInfoIsDisabledCoverage(marketInfo.isDisabled);
    }

    function _logMarketInfoMarketTokenCoverage(address marketToken) internal {
        if (marketToken == address(market_0_WETH_USDC)) {
            fl.log("MarketInfo marketToken market_0_WETH_USDC hit");
        }

        if (marketToken == address(market_WBTC_WBTC_USDC)) {
            fl.log("MarketInfo marketToken market_WBTC_WBTC_USDC hit");
        }
        if (marketToken == address(market_WETH_WETH_USDC)) {
            fl.log("MarketInfo marketToken market_WETH_WETH_USDC hit");
        }
        if (marketToken == address(market_WETH_WETH_USDT)) {
            fl.log("MarketInfo marketToken market_WETH_WETH_USDT hit");
        }
    }

    function _logMarketInfoIndexTokenCoverage(address indexToken) internal {
        if (indexToken == address(0)) {
            fl.log("MarketInfo indexToken is address(0)");
        } else {
            fl.log("MarketInfo indexToken is non-zero address");
        }
    }

    function _logMarketInfoLongTokenCoverage(address longToken) internal {
        if (longToken == address(0)) {
            fl.log("MarketInfo longToken is address(0)");
        } else {
            fl.log("MarketInfo longToken is non-zero address");
        }
    }

    function _logMarketInfoShortTokenCoverage(address shortToken) internal {
        if (shortToken == address(0)) {
            fl.log("MarketInfo shortToken is address(0)");
        } else {
            fl.log("MarketInfo shortToken is non-zero address");
        }
    }

    function _logMarketInfoBorrowingFactorPerSecondForLongsCoverage(
        uint256 borrowingFactorPerSecondForLongs
    ) internal {
        if (borrowingFactorPerSecondForLongs == 0) {
            fl.log("MarketInfo borrowingFactorPerSecondForLongs is 0");
        }
        if (
            borrowingFactorPerSecondForLongs > 0 &&
            borrowingFactorPerSecondForLongs <= 1e6
        ) {
            fl.log(
                "MarketInfo borrowingFactorPerSecondForLongs is between 0 and 1e6"
            );
        }
        if (
            borrowingFactorPerSecondForLongs > 1e6 &&
            borrowingFactorPerSecondForLongs <= 1e12
        ) {
            fl.log(
                "MarketInfo borrowingFactorPerSecondForLongs is between 1e6 and 1e12"
            );
        }
        if (
            borrowingFactorPerSecondForLongs > 1e12 &&
            borrowingFactorPerSecondForLongs <= 1e18
        ) {
            fl.log(
                "MarketInfo borrowingFactorPerSecondForLongs is between 1e12 and 1e18"
            );
        }
        if (
            borrowingFactorPerSecondForLongs > 1e18 &&
            borrowingFactorPerSecondForLongs <= 1e24
        ) {
            fl.log(
                "MarketInfo borrowingFactorPerSecondForLongs is between 1e18 and 1e24"
            );
        }
        if (borrowingFactorPerSecondForLongs > 1e24) {
            fl.log(
                "MarketInfo borrowingFactorPerSecondForLongs is greater than 1e24"
            );
        }
    }

    function _logMarketInfoBorrowingFactorPerSecondForShortsCoverage(
        uint256 borrowingFactorPerSecondForShorts
    ) internal {
        if (borrowingFactorPerSecondForShorts == 0) {
            fl.log("MarketInfo borrowingFactorPerSecondForShorts is 0");
        }
        if (
            borrowingFactorPerSecondForShorts > 0 &&
            borrowingFactorPerSecondForShorts <= 1e6
        ) {
            fl.log(
                "MarketInfo borrowingFactorPerSecondForShorts is between 0 and 1e6"
            );
        }
        if (
            borrowingFactorPerSecondForShorts > 1e6 &&
            borrowingFactorPerSecondForShorts <= 1e12
        ) {
            fl.log(
                "MarketInfo borrowingFactorPerSecondForShorts is between 1e6 and 1e12"
            );
        }
        if (
            borrowingFactorPerSecondForShorts > 1e12 &&
            borrowingFactorPerSecondForShorts <= 1e18
        ) {
            fl.log(
                "MarketInfo borrowingFactorPerSecondForShorts is between 1e12 and 1e18"
            );
        }
        if (
            borrowingFactorPerSecondForShorts > 1e18 &&
            borrowingFactorPerSecondForShorts <= 1e24
        ) {
            fl.log(
                "MarketInfo borrowingFactorPerSecondForShorts is between 1e18 and 1e24"
            );
        }
        if (borrowingFactorPerSecondForShorts > 1e24) {
            fl.log(
                "MarketInfo borrowingFactorPerSecondForShorts is greater than 1e24"
            );
        }
    }

    function _logMarketInfoBaseFundingLongFundingFeeAmountPerSizeCoverage(
        MarketUtils.CollateralType memory longFundingFeeAmountPerSize
    ) internal {
        if (
            longFundingFeeAmountPerSize.longToken == 0 &&
            longFundingFeeAmountPerSize.shortToken == 0
        ) {
            fl.log(
                "MarketInfo baseFunding longFundingFeeAmountPerSize is 0 for both longToken and shortToken"
            );
        }
        if (
            longFundingFeeAmountPerSize.longToken > 0 &&
            longFundingFeeAmountPerSize.longToken <= 1e6
        ) {
            fl.log(
                "MarketInfo baseFunding longFundingFeeAmountPerSize longToken is between 0 and 1e6"
            );
        }
        if (
            longFundingFeeAmountPerSize.longToken > 1e6 &&
            longFundingFeeAmountPerSize.longToken <= 1e12
        ) {
            fl.log(
                "MarketInfo baseFunding longFundingFeeAmountPerSize longToken is between 1e6 and 1e12"
            );
        }
        if (
            longFundingFeeAmountPerSize.longToken > 1e12 &&
            longFundingFeeAmountPerSize.longToken <= 1e18
        ) {
            fl.log(
                "MarketInfo baseFunding longFundingFeeAmountPerSize longToken is between 1e12 and 1e18"
            );
        }
        if (
            longFundingFeeAmountPerSize.longToken > 1e18 &&
            longFundingFeeAmountPerSize.longToken <= 1e24
        ) {
            fl.log(
                "MarketInfo baseFunding longFundingFeeAmountPerSize longToken is between 1e18 and 1e24"
            );
        }
        if (longFundingFeeAmountPerSize.longToken > 1e24) {
            fl.log(
                "MarketInfo baseFunding longFundingFeeAmountPerSize longToken is greater than 1e24"
            );
        }
        if (
            longFundingFeeAmountPerSize.shortToken > 0 &&
            longFundingFeeAmountPerSize.shortToken <= 1e6
        ) {
            fl.log(
                "MarketInfo baseFunding longFundingFeeAmountPerSize shortToken is between 0 and 1e6"
            );
        }
        if (
            longFundingFeeAmountPerSize.shortToken > 1e6 &&
            longFundingFeeAmountPerSize.shortToken <= 1e12
        ) {
            fl.log(
                "MarketInfo baseFunding longFundingFeeAmountPerSize shortToken is between 1e6 and 1e12"
            );
        }
        if (
            longFundingFeeAmountPerSize.shortToken > 1e12 &&
            longFundingFeeAmountPerSize.shortToken <= 1e18
        ) {
            fl.log(
                "MarketInfo baseFunding longFundingFeeAmountPerSize shortToken is between 1e12 and 1e18"
            );
        }
        if (
            longFundingFeeAmountPerSize.shortToken > 1e18 &&
            longFundingFeeAmountPerSize.shortToken <= 1e24
        ) {
            fl.log(
                "MarketInfo baseFunding longFundingFeeAmountPerSize shortToken is between 1e18 and 1e24"
            );
        }
        if (longFundingFeeAmountPerSize.shortToken > 1e24) {
            fl.log(
                "MarketInfo baseFunding longFundingFeeAmountPerSize shortToken is greater than 1e24"
            );
        }
    }

    function _logMarketInfoBaseFundingShortFundingFeeAmountPerSizeCoverage(
        MarketUtils.CollateralType memory shortFundingFeeAmountPerSize
    ) internal {
        if (
            shortFundingFeeAmountPerSize.longToken == 0 &&
            shortFundingFeeAmountPerSize.shortToken == 0
        ) {
            fl.log(
                "MarketInfo baseFunding shortFundingFeeAmountPerSize is 0 for both longToken and shortToken"
            );
        }
        if (
            shortFundingFeeAmountPerSize.longToken > 0 &&
            shortFundingFeeAmountPerSize.longToken <= 1e6
        ) {
            fl.log(
                "MarketInfo baseFunding shortFundingFeeAmountPerSize longToken is between 0 and 1e6"
            );
        }
        if (
            shortFundingFeeAmountPerSize.longToken > 1e6 &&
            shortFundingFeeAmountPerSize.longToken <= 1e12
        ) {
            fl.log(
                "MarketInfo baseFunding shortFundingFeeAmountPerSize longToken is between 1e6 and 1e12"
            );
        }
        if (
            shortFundingFeeAmountPerSize.longToken > 1e12 &&
            shortFundingFeeAmountPerSize.longToken <= 1e18
        ) {
            fl.log(
                "MarketInfo baseFunding shortFundingFeeAmountPerSize longToken is between 1e12 and 1e18"
            );
        }
        if (
            shortFundingFeeAmountPerSize.longToken > 1e18 &&
            shortFundingFeeAmountPerSize.longToken <= 1e24
        ) {
            fl.log(
                "MarketInfo baseFunding shortFundingFeeAmountPerSize longToken is between 1e18 and 1e24"
            );
        }
        if (shortFundingFeeAmountPerSize.longToken > 1e24) {
            fl.log(
                "MarketInfo baseFunding shortFundingFeeAmountPerSize longToken is greater than 1e24"
            );
        }
        if (
            shortFundingFeeAmountPerSize.shortToken > 0 &&
            shortFundingFeeAmountPerSize.shortToken <= 1e6
        ) {
            fl.log(
                "MarketInfo baseFunding shortFundingFeeAmountPerSize shortToken is between 0 and 1e6"
            );
        }
        if (
            shortFundingFeeAmountPerSize.shortToken > 1e6 &&
            shortFundingFeeAmountPerSize.shortToken <= 1e12
        ) {
            fl.log(
                "MarketInfo baseFunding shortFundingFeeAmountPerSize shortToken is between 1e6 and 1e12"
            );
        }
        if (
            shortFundingFeeAmountPerSize.shortToken > 1e12 &&
            shortFundingFeeAmountPerSize.shortToken <= 1e18
        ) {
            fl.log(
                "MarketInfo baseFunding shortFundingFeeAmountPerSize shortToken is between 1e12 and 1e18"
            );
        }
        if (
            shortFundingFeeAmountPerSize.shortToken > 1e18 &&
            shortFundingFeeAmountPerSize.shortToken <= 1e24
        ) {
            fl.log(
                "MarketInfo baseFunding shortFundingFeeAmountPerSize shortToken is between 1e18 and 1e24"
            );
        }
        if (shortFundingFeeAmountPerSize.shortToken > 1e24) {
            fl.log(
                "MarketInfo baseFunding shortFundingFeeAmountPerSize shortToken is greater than 1e24"
            );
        }
    }

    function _logMarketInfoBaseFundingLongClaimableFundingAmountPerSizeCoverage(
        MarketUtils.CollateralType memory longClaimableFundingAmountPerSize
    ) internal {
        if (
            longClaimableFundingAmountPerSize.longToken == 0 &&
            longClaimableFundingAmountPerSize.shortToken == 0
        ) {
            fl.log(
                "MarketInfo baseFunding longClaimableFundingAmountPerSize is 0 for both longToken and shortToken"
            );
        }
        if (
            longClaimableFundingAmountPerSize.longToken > 0 &&
            longClaimableFundingAmountPerSize.longToken <= 1e6
        ) {
            fl.log(
                "MarketInfo baseFunding longClaimableFundingAmountPerSize longToken is between 0 and 1e6"
            );
        }
        if (
            longClaimableFundingAmountPerSize.longToken > 1e6 &&
            longClaimableFundingAmountPerSize.longToken <= 1e12
        ) {
            fl.log(
                "MarketInfo baseFunding longClaimableFundingAmountPerSize longToken is between 1e6 and 1e12"
            );
        }
        if (
            longClaimableFundingAmountPerSize.longToken > 1e12 &&
            longClaimableFundingAmountPerSize.longToken <= 1e18
        ) {
            fl.log(
                "MarketInfo baseFunding longClaimableFundingAmountPerSize longToken is between 1e12 and 1e18"
            );
        }
        if (
            longClaimableFundingAmountPerSize.longToken > 1e18 &&
            longClaimableFundingAmountPerSize.longToken <= 1e24
        ) {
            fl.log(
                "MarketInfo baseFunding longClaimableFundingAmountPerSize longToken is between 1e18 and 1e24"
            );
        }
        if (longClaimableFundingAmountPerSize.longToken > 1e24) {
            fl.log(
                "MarketInfo baseFunding longClaimableFundingAmountPerSize longToken is greater than 1e24"
            );
        }
        if (
            longClaimableFundingAmountPerSize.shortToken > 0 &&
            longClaimableFundingAmountPerSize.shortToken <= 1e6
        ) {
            fl.log(
                "MarketInfo baseFunding longClaimableFundingAmountPerSize shortToken is between 0 and 1e6"
            );
        }
        if (
            longClaimableFundingAmountPerSize.shortToken > 1e6 &&
            longClaimableFundingAmountPerSize.shortToken <= 1e12
        ) {
            fl.log(
                "MarketInfo baseFunding longClaimableFundingAmountPerSize shortToken is between 1e6 and 1e12"
            );
        }
        if (
            longClaimableFundingAmountPerSize.shortToken > 1e12 &&
            longClaimableFundingAmountPerSize.shortToken <= 1e18
        ) {
            fl.log(
                "MarketInfo baseFunding longClaimableFundingAmountPerSize shortToken is between 1e12 and 1e18"
            );
        }
        if (
            longClaimableFundingAmountPerSize.shortToken > 1e18 &&
            longClaimableFundingAmountPerSize.shortToken <= 1e24
        ) {
            fl.log(
                "MarketInfo baseFunding longClaimableFundingAmountPerSize shortToken is between 1e18 and 1e24"
            );
        }
        if (longClaimableFundingAmountPerSize.shortToken > 1e24) {
            fl.log(
                "MarketInfo baseFunding longClaimableFundingAmountPerSize shortToken is greater than 1e24"
            );
        }
    }

    function _logMarketInfoBaseFundingShortClaimableFundingAmountPerSizeCoverage(
        MarketUtils.CollateralType memory shortClaimableFundingAmountPerSize
    ) internal {
        if (
            shortClaimableFundingAmountPerSize.longToken == 0 &&
            shortClaimableFundingAmountPerSize.shortToken == 0
        ) {
            fl.log(
                "MarketInfo baseFunding shortClaimableFundingAmountPerSize is 0 for both longToken and shortToken"
            );
        }
        if (
            shortClaimableFundingAmountPerSize.longToken > 0 &&
            shortClaimableFundingAmountPerSize.longToken <= 1e6
        ) {
            fl.log(
                "MarketInfo baseFunding shortClaimableFundingAmountPerSize longToken is between 0 and 1e6"
            );
        }
        if (
            shortClaimableFundingAmountPerSize.longToken > 1e6 &&
            shortClaimableFundingAmountPerSize.longToken <= 1e12
        ) {
            fl.log(
                "MarketInfo baseFunding shortClaimableFundingAmountPerSize longToken is between 1e6 and 1e12"
            );
        }
        if (
            shortClaimableFundingAmountPerSize.longToken > 1e12 &&
            shortClaimableFundingAmountPerSize.longToken <= 1e18
        ) {
            fl.log(
                "MarketInfo baseFunding shortClaimableFundingAmountPerSize longToken is between 1e12 and 1e18"
            );
        }
        if (
            shortClaimableFundingAmountPerSize.longToken > 1e18 &&
            shortClaimableFundingAmountPerSize.longToken <= 1e24
        ) {
            fl.log(
                "MarketInfo baseFunding shortClaimableFundingAmountPerSize longToken is between 1e18 and 1e24"
            );
        }
        if (shortClaimableFundingAmountPerSize.longToken > 1e24) {
            fl.log(
                "MarketInfo baseFunding shortClaimableFundingAmountPerSize longToken is greater than 1e24"
            );
        }
        if (
            shortClaimableFundingAmountPerSize.shortToken > 0 &&
            shortClaimableFundingAmountPerSize.shortToken <= 1e6
        ) {
            fl.log(
                "MarketInfo baseFunding shortClaimableFundingAmountPerSize shortToken is between 0 and 1e6"
            );
        }
        if (
            shortClaimableFundingAmountPerSize.shortToken > 1e6 &&
            shortClaimableFundingAmountPerSize.shortToken <= 1e12
        ) {
            fl.log(
                "MarketInfo baseFunding shortClaimableFundingAmountPerSize shortToken is between 1e6 and 1e12"
            );
        }
        if (
            shortClaimableFundingAmountPerSize.shortToken > 1e12 &&
            shortClaimableFundingAmountPerSize.shortToken <= 1e18
        ) {
            fl.log(
                "MarketInfo baseFunding shortClaimableFundingAmountPerSize shortToken is between 1e12 and 1e18"
            );
        }
        if (
            shortClaimableFundingAmountPerSize.shortToken > 1e18 &&
            shortClaimableFundingAmountPerSize.shortToken <= 1e24
        ) {
            fl.log(
                "MarketInfo baseFunding shortClaimableFundingAmountPerSize shortToken is between 1e18 and 1e24"
            );
        }
        if (shortClaimableFundingAmountPerSize.shortToken > 1e24) {
            fl.log(
                "MarketInfo baseFunding shortClaimableFundingAmountPerSize shortToken is greater than 1e24"
            );
        }
    }

    function _logMarketInfoNextFundingLongsPayShortsCoverage(
        bool longsPayShorts
    ) internal {
        if (longsPayShorts) {
            fl.log("MarketInfo nextFunding longsPayShorts is true");
        } else {
            fl.log("MarketInfo nextFunding longsPayShorts is false");
        }
    }

    function _logMarketInfoNextFundingFundingFactorPerSecondCoverage(
        uint256 fundingFactorPerSecond
    ) internal {
        if (fundingFactorPerSecond == 0) {
            fl.log("MarketInfo nextFunding fundingFactorPerSecond is 0");
        }
        if (fundingFactorPerSecond > 0 && fundingFactorPerSecond <= 1e6) {
            fl.log(
                "MarketInfo nextFunding fundingFactorPerSecond is between 0 and 1e6"
            );
        }
        if (fundingFactorPerSecond > 1e6 && fundingFactorPerSecond <= 1e12) {
            fl.log(
                "MarketInfo nextFunding fundingFactorPerSecond is between 1e6 and 1e12"
            );
        }
        if (fundingFactorPerSecond > 1e12 && fundingFactorPerSecond <= 1e18) {
            fl.log(
                "MarketInfo nextFunding fundingFactorPerSecond is between 1e12 and 1e18"
            );
        }
        if (fundingFactorPerSecond > 1e18 && fundingFactorPerSecond <= 1e24) {
            fl.log(
                "MarketInfo nextFunding fundingFactorPerSecond is between 1e18 and 1e24"
            );
        }
        if (fundingFactorPerSecond > 1e24) {
            fl.log(
                "MarketInfo nextFunding fundingFactorPerSecond is greater than 1e24"
            );
        }
    }

    function _logMarketInfoNextFundingNextSavedFundingFactorPerSecondCoverage(
        int256 nextSavedFundingFactorPerSecond
    ) internal {
        if (nextSavedFundingFactorPerSecond == 0) {
            fl.log(
                "MarketInfo nextFunding nextSavedFundingFactorPerSecond is 0"
            );
        }
        if (
            nextSavedFundingFactorPerSecond > 0 &&
            nextSavedFundingFactorPerSecond <= 1e6
        ) {
            fl.log(
                "MarketInfo nextFunding nextSavedFundingFactorPerSecond is between 0 and 1e6"
            );
        }
        if (
            nextSavedFundingFactorPerSecond > 1e6 &&
            nextSavedFundingFactorPerSecond <= 1e12
        ) {
            fl.log(
                "MarketInfo nextFunding nextSavedFundingFactorPerSecond is between 1e6 and 1e12"
            );
        }
        if (
            nextSavedFundingFactorPerSecond > 1e12 &&
            nextSavedFundingFactorPerSecond <= 1e18
        ) {
            fl.log(
                "MarketInfo nextFunding nextSavedFundingFactorPerSecond is between 1e12 and 1e18"
            );
        }
        if (
            nextSavedFundingFactorPerSecond > 1e18 &&
            nextSavedFundingFactorPerSecond <= 1e24
        ) {
            fl.log(
                "MarketInfo nextFunding nextSavedFundingFactorPerSecond is between 1e18 and 1e24"
            );
        }
        if (nextSavedFundingFactorPerSecond > 1e24) {
            fl.log(
                "MarketInfo nextFunding nextSavedFundingFactorPerSecond is greater than 1e24"
            );
        }
        if (
            nextSavedFundingFactorPerSecond < 0 &&
            nextSavedFundingFactorPerSecond >= -1e6
        ) {
            fl.log(
                "MarketInfo nextFunding nextSavedFundingFactorPerSecond is between 0 and -1e6"
            );
        }
        if (
            nextSavedFundingFactorPerSecond < -1e6 &&
            nextSavedFundingFactorPerSecond >= -1e12
        ) {
            fl.log(
                "MarketInfo nextFunding nextSavedFundingFactorPerSecond is between -1e6 and -1e12"
            );
        }
        if (
            nextSavedFundingFactorPerSecond < -1e12 &&
            nextSavedFundingFactorPerSecond >= -1e18
        ) {
            fl.log(
                "MarketInfo nextFunding nextSavedFundingFactorPerSecond is between -1e12 and -1e18"
            );
        }
        if (
            nextSavedFundingFactorPerSecond < -1e18 &&
            nextSavedFundingFactorPerSecond >= -1e24
        ) {
            fl.log(
                "MarketInfo nextFunding nextSavedFundingFactorPerSecond is between -1e18 and -1e24"
            );
        }
        if (nextSavedFundingFactorPerSecond < -1e24) {
            fl.log(
                "MarketInfo nextFunding nextSavedFundingFactorPerSecond is less than -1e24"
            );
        }
    }

    function _logMarketInfoNextFundingLongFundingFeeAmountPerSizeDeltaCoverage(
        MarketUtils.CollateralType memory longFundingFeeAmountPerSizeDelta
    ) internal {
        if (
            longFundingFeeAmountPerSizeDelta.longToken == 0 &&
            longFundingFeeAmountPerSizeDelta.shortToken == 0
        ) {
            fl.log(
                "MarketInfo nextFund longFundingFeeAmountPerSizeDelta is 0 for both longToken and shortToken"
            );
        }
        if (
            longFundingFeeAmountPerSizeDelta.longToken > 0 &&
            longFundingFeeAmountPerSizeDelta.longToken <= 1e6
        ) {
            fl.log(
                "MarketInfo nextFund longFundingFeeAmountPerSizeDelta longToken is between 0 and 1e6"
            );
        }
        if (
            longFundingFeeAmountPerSizeDelta.longToken > 1e6 &&
            longFundingFeeAmountPerSizeDelta.longToken <= 1e12
        ) {
            fl.log(
                "MarketInfo nextFund longFundingFeeAmountPerSizeDelta longToken is between 1e6 and 1e12"
            );
        }
        if (
            longFundingFeeAmountPerSizeDelta.longToken > 1e12 &&
            longFundingFeeAmountPerSizeDelta.longToken <= 1e18
        ) {
            fl.log(
                "MarketInfo nextFund longFundingFeeAmountPerSizeDelta longToken is between 1e12 and 1e18"
            );
        }
        if (
            longFundingFeeAmountPerSizeDelta.longToken > 1e18 &&
            longFundingFeeAmountPerSizeDelta.longToken <= 1e24
        ) {
            fl.log(
                "MarketInfo nextFund longFundingFeeAmountPerSizeDelta longToken is between 1e18 and 1e24"
            );
        }
        if (longFundingFeeAmountPerSizeDelta.longToken > 1e24) {
            fl.log(
                "MarketInfo nextFund longFundingFeeAmountPerSizeDelta longToken is greater than 1e24"
            );
        }
        if (
            longFundingFeeAmountPerSizeDelta.shortToken > 0 &&
            longFundingFeeAmountPerSizeDelta.shortToken <= 1e6
        ) {
            fl.log(
                "MarketInfo nextFund longFundingFeeAmountPerSizeDelta shortToken is between 0 and 1e6"
            );
        }
        if (
            longFundingFeeAmountPerSizeDelta.shortToken > 1e6 &&
            longFundingFeeAmountPerSizeDelta.shortToken <= 1e12
        ) {
            fl.log(
                "MarketInfo nextFund longFundingFeeAmountPerSizeDelta shortToken is between 1e6 and 1e12"
            );
        }
        if (
            longFundingFeeAmountPerSizeDelta.shortToken > 1e12 &&
            longFundingFeeAmountPerSizeDelta.shortToken <= 1e18
        ) {
            fl.log(
                "MarketInfo nextFund longFundingFeeAmountPerSizeDelta shortToken is between 1e12 and 1e18"
            );
        }
        if (
            longFundingFeeAmountPerSizeDelta.shortToken > 1e18 &&
            longFundingFeeAmountPerSizeDelta.shortToken <= 1e24
        ) {
            fl.log(
                "MarketInfo nextFund longFundingFeeAmountPerSizeDelta shortToken is between 1e18 and 1e24"
            );
        }
        if (longFundingFeeAmountPerSizeDelta.shortToken > 1e24) {
            fl.log(
                "MarketInfo nextFund longFundingFeeAmountPerSizeDelta shortToken is greater than 1e24"
            );
        }
    }
    function _logMarketInfoNextFundingShortFundingFeeAmountPerSizeDeltaCoverage(
        MarketUtils.CollateralType memory shortFundingFeeAmountPerSizeDelta
    ) internal {
        if (
            shortFundingFeeAmountPerSizeDelta.longToken == 0 &&
            shortFundingFeeAmountPerSizeDelta.shortToken == 0
        ) {
            fl.log(
                "MarketInfo nextFunding shortFundingFeeAmountPerSizeDelta is 0 for both longToken and shortToken"
            );
        }
        if (
            shortFundingFeeAmountPerSizeDelta.longToken > 0 &&
            shortFundingFeeAmountPerSizeDelta.longToken <= 1e6
        ) {
            fl.log(
                "MarketInfo nextFunding shortFundingFeeAmountPerSizeDelta longToken is between 0 and 1e6"
            );
        }
        if (
            shortFundingFeeAmountPerSizeDelta.longToken > 1e6 &&
            shortFundingFeeAmountPerSizeDelta.longToken <= 1e12
        ) {
            fl.log(
                "MarketInfo nextFunding shortFundingFeeAmountPerSizeDelta longToken is between 1e6 and 1e12"
            );
        }
        if (
            shortFundingFeeAmountPerSizeDelta.longToken > 1e12 &&
            shortFundingFeeAmountPerSizeDelta.longToken <= 1e18
        ) {
            fl.log(
                "MarketInfo nextFunding shortFundingFeeAmountPerSizeDelta longToken is between 1e12 and 1e18"
            );
        }
        if (
            shortFundingFeeAmountPerSizeDelta.longToken > 1e18 &&
            shortFundingFeeAmountPerSizeDelta.longToken <= 1e24
        ) {
            fl.log(
                "MarketInfo nextFunding shortFundingFeeAmountPerSizeDelta longToken is between 1e18 and 1e24"
            );
        }
        if (shortFundingFeeAmountPerSizeDelta.longToken > 1e24) {
            fl.log(
                "MarketInfo nextFunding shortFundingFeeAmountPerSizeDelta longToken is greater than 1e24"
            );
        }
        if (
            shortFundingFeeAmountPerSizeDelta.shortToken > 0 &&
            shortFundingFeeAmountPerSizeDelta.shortToken <= 1e6
        ) {
            fl.log(
                "MarketInfo nextFunding shortFundingFeeAmountPerSizeDelta shortToken is between 0 and 1e6"
            );
        }
        if (
            shortFundingFeeAmountPerSizeDelta.shortToken > 1e6 &&
            shortFundingFeeAmountPerSizeDelta.shortToken <= 1e12
        ) {
            fl.log(
                "MarketInfo nextFunding shortFundingFeeAmountPerSizeDelta shortToken is between 1e6 and 1e12"
            );
        }
        if (
            shortFundingFeeAmountPerSizeDelta.shortToken > 1e12 &&
            shortFundingFeeAmountPerSizeDelta.shortToken <= 1e18
        ) {
            fl.log(
                "MarketInfo nextFunding shortFundingFeeAmountPerSizeDelta shortToken is between 1e12 and 1e18"
            );
        }
        if (
            shortFundingFeeAmountPerSizeDelta.shortToken > 1e18 &&
            shortFundingFeeAmountPerSizeDelta.shortToken <= 1e24
        ) {
            fl.log(
                "MarketInfo nextFunding shortFundingFeeAmountPerSizeDelta shortToken is between 1e18 and 1e24"
            );
        }
        if (shortFundingFeeAmountPerSizeDelta.shortToken > 1e24) {
            fl.log(
                "MarketInfo nextFunding shortFundingFeeAmountPerSizeDelta shortToken is greater than 1e24"
            );
        }
    }

    function _logMarketInfoNextFundingLongClaimableFundingAmountPerSizeDeltaCoverage(
        MarketUtils.CollateralType memory longClaimableFundingAmountPerSizeDelta
    ) internal {
        if (
            longClaimableFundingAmountPerSizeDelta.longToken == 0 &&
            longClaimableFundingAmountPerSizeDelta.shortToken == 0
        ) {
            fl.log(
                "MarketInfo nextFunding longClaimableFundingAmountPerSizeDelta is 0 for both longToken and shortToken"
            );
        }
        if (
            longClaimableFundingAmountPerSizeDelta.longToken > 0 &&
            longClaimableFundingAmountPerSizeDelta.longToken <= 1e6
        ) {
            fl.log(
                "MarketInfo nextFunding longClaimableFundingAmountPerSizeDelta longToken is between 0 and 1e6"
            );
        }
        if (
            longClaimableFundingAmountPerSizeDelta.longToken > 1e6 &&
            longClaimableFundingAmountPerSizeDelta.longToken <= 1e12
        ) {
            fl.log(
                "MarketInfo nextFunding longClaimableFundingAmountPerSizeDelta longToken is between 1e6 and 1e12"
            );
        }
        if (
            longClaimableFundingAmountPerSizeDelta.longToken > 1e12 &&
            longClaimableFundingAmountPerSizeDelta.longToken <= 1e18
        ) {
            fl.log(
                "MarketInfo nextFunding longClaimableFundingAmountPerSizeDelta longToken is between 1e12 and 1e18"
            );
        }
        if (
            longClaimableFundingAmountPerSizeDelta.longToken > 1e18 &&
            longClaimableFundingAmountPerSizeDelta.longToken <= 1e24
        ) {
            fl.log(
                "MarketInfo nextFunding longClaimableFundingAmountPerSizeDelta longToken is between 1e18 and 1e24"
            );
        }
        if (longClaimableFundingAmountPerSizeDelta.longToken > 1e24) {
            fl.log(
                "MarketInfo nextFunding longClaimableFundingAmountPerSizeDelta longToken is greater than 1e24"
            );
        }
        if (
            longClaimableFundingAmountPerSizeDelta.shortToken > 0 &&
            longClaimableFundingAmountPerSizeDelta.shortToken <= 1e6
        ) {
            fl.log(
                "MarketInfo nextFunding longClaimableFundingAmountPerSizeDelta shortToken is between 0 and 1e6"
            );
        }
        if (
            longClaimableFundingAmountPerSizeDelta.shortToken > 1e6 &&
            longClaimableFundingAmountPerSizeDelta.shortToken <= 1e12
        ) {
            fl.log(
                "MarketInfo nextFunding longClaimableFundingAmountPerSizeDelta shortToken is between 1e6 and 1e12"
            );
        }
        if (
            longClaimableFundingAmountPerSizeDelta.shortToken > 1e12 &&
            longClaimableFundingAmountPerSizeDelta.shortToken <= 1e18
        ) {
            fl.log(
                "MarketInfo nextFunding longClaimableFundingAmountPerSizeDelta shortToken is between 1e12 and 1e18"
            );
        }
        if (
            longClaimableFundingAmountPerSizeDelta.shortToken > 1e18 &&
            longClaimableFundingAmountPerSizeDelta.shortToken <= 1e24
        ) {
            fl.log(
                "MarketInfo nextFunding longClaimableFundingAmountPerSizeDelta shortToken is between 1e18 and 1e24"
            );
        }
        if (longClaimableFundingAmountPerSizeDelta.shortToken > 1e24) {
            fl.log(
                "MarketInfo nextFunding longClaimableFundingAmountPerSizeDelta shortToken is greater than 1e24"
            );
        }
    }

    function _logMarketInfoNextFundingShortClaimableFundingAmountPerSizeDeltaCoverage(
        MarketUtils.CollateralType
            memory shortClaimableFundingAmountPerSizeDelta
    ) internal {
        if (
            shortClaimableFundingAmountPerSizeDelta.longToken == 0 &&
            shortClaimableFundingAmountPerSizeDelta.shortToken == 0
        ) {
            fl.log(
                "MarketInfo nextFunding shortClaimableFundingAmountPerSizeDelta is 0 for both longToken and shortToken"
            );
        }
        if (
            shortClaimableFundingAmountPerSizeDelta.longToken > 0 &&
            shortClaimableFundingAmountPerSizeDelta.longToken <= 1e6
        ) {
            fl.log(
                "MarketInfo nextFunding shortClaimableFundingAmountPerSizeDelta longToken is between 0 and 1e6"
            );
        }
        if (
            shortClaimableFundingAmountPerSizeDelta.longToken > 1e6 &&
            shortClaimableFundingAmountPerSizeDelta.longToken <= 1e12
        ) {
            fl.log(
                "MarketInfo nextFunding shortClaimableFundingAmountPerSizeDelta longToken is between 1e6 and 1e12"
            );
        }
        if (
            shortClaimableFundingAmountPerSizeDelta.longToken > 1e12 &&
            shortClaimableFundingAmountPerSizeDelta.longToken <= 1e18
        ) {
            fl.log(
                "MarketInfo nextFunding shortClaimableFundingAmountPerSizeDelta longToken is between 1e12 and 1e18"
            );
        }
        if (
            shortClaimableFundingAmountPerSizeDelta.longToken > 1e18 &&
            shortClaimableFundingAmountPerSizeDelta.longToken <= 1e24
        ) {
            fl.log(
                "MarketInfo nextFunding shortClaimableFundingAmountPerSizeDelta longToken is between 1e18 and 1e24"
            );
        }
        if (shortClaimableFundingAmountPerSizeDelta.longToken > 1e24) {
            fl.log(
                "MarketInfo nextFunding shortClaimableFundingAmountPerSizeDelta longToken is greater than 1e24"
            );
        }
        if (
            shortClaimableFundingAmountPerSizeDelta.shortToken > 0 &&
            shortClaimableFundingAmountPerSizeDelta.shortToken <= 1e6
        ) {
            fl.log(
                "MarketInfo nextFunding shortClaimableFundingAmountPerSizeDelta shortToken is between 0 and 1e6"
            );
        }
        if (
            shortClaimableFundingAmountPerSizeDelta.shortToken > 1e6 &&
            shortClaimableFundingAmountPerSizeDelta.shortToken <= 1e12
        ) {
            fl.log(
                "MarketInfo nextFunding shortClaimableFundingAmountPerSizeDelta shortToken is between 1e6 and 1e12"
            );
        }
        if (
            shortClaimableFundingAmountPerSizeDelta.shortToken > 1e12 &&
            shortClaimableFundingAmountPerSizeDelta.shortToken <= 1e18
        ) {
            fl.log(
                "MarketInfo nextFunding shortClaimableFundingAmountPerSizeDelta shortToken is between 1e12 and 1e18"
            );
        }
        if (
            shortClaimableFundingAmountPerSizeDelta.shortToken > 1e18 &&
            shortClaimableFundingAmountPerSizeDelta.shortToken <= 1e24
        ) {
            fl.log(
                "MarketInfo nextFunding shortClaimableFundingAmountPerSizeDelta shortToken is between 1e18 and 1e24"
            );
        }
        if (shortClaimableFundingAmountPerSizeDelta.shortToken > 1e24) {
            fl.log(
                "MarketInfo nextFunding shortClaimableFundingAmountPerSizeDelta shortToken is greater than 1e24"
            );
        }
    }

    function _logMarketInfoVirtualInventoryVirtualPoolAmountForLongTokenCoverage(
        uint256 virtualPoolAmountForLongToken
    ) internal {
        if (virtualPoolAmountForLongToken == 0) {
            fl.log(
                "MarketInfo virtualInventory virtualPoolAmountForLongToken is 0"
            );
        }
        if (
            virtualPoolAmountForLongToken > 0 &&
            virtualPoolAmountForLongToken <= 1e6
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualPoolAmountForLongToken is between 0 and 1e6"
            );
        }
        if (
            virtualPoolAmountForLongToken > 1e6 &&
            virtualPoolAmountForLongToken <= 1e12
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualPoolAmountForLongToken is between 1e6 and 1e12"
            );
        }
        if (
            virtualPoolAmountForLongToken > 1e12 &&
            virtualPoolAmountForLongToken <= 1e18
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualPoolAmountForLongToken is between 1e12 and 1e18"
            );
        }
        if (
            virtualPoolAmountForLongToken > 1e18 &&
            virtualPoolAmountForLongToken <= 1e24
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualPoolAmountForLongToken is between 1e18 and 1e24"
            );
        }
        if (virtualPoolAmountForLongToken > 1e24) {
            fl.log(
                "MarketInfo virtualInventory virtualPoolAmountForLongToken is greater than 1e24"
            );
        }
    }

    function _logMarketInfoVirtualInventoryVirtualPoolAmountForShortTokenCoverage(
        uint256 virtualPoolAmountForShortToken
    ) internal {
        if (virtualPoolAmountForShortToken == 0) {
            fl.log(
                "MarketInfo virtualInventory virtualPoolAmountForShortToken is 0"
            );
        }
        if (
            virtualPoolAmountForShortToken > 0 &&
            virtualPoolAmountForShortToken <= 1e6
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualPoolAmountForShortToken is between 0 and 1e6"
            );
        }
        if (
            virtualPoolAmountForShortToken > 1e6 &&
            virtualPoolAmountForShortToken <= 1e12
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualPoolAmountForShortToken is between 1e6 and 1e12"
            );
        }
        if (
            virtualPoolAmountForShortToken > 1e12 &&
            virtualPoolAmountForShortToken <= 1e18
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualPoolAmountForShortToken is between 1e12 and 1e18"
            );
        }
        if (
            virtualPoolAmountForShortToken > 1e18 &&
            virtualPoolAmountForShortToken <= 1e24
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualPoolAmountForShortToken is between 1e18 and 1e24"
            );
        }
        if (virtualPoolAmountForShortToken > 1e24) {
            fl.log(
                "MarketInfo virtualInventory virtualPoolAmountForShortToken is greater than 1e24"
            );
        }
    }

    function _logMarketInfoVirtualInventoryVirtualInventoryForPositionsCoverage(
        int256 virtualInventoryForPositions
    ) internal {
        if (virtualInventoryForPositions == 0) {
            fl.log(
                "MarketInfo virtualInventory virtualInventoryForPositions is 0"
            );
        }
        if (
            virtualInventoryForPositions > 0 &&
            virtualInventoryForPositions <= 1e6
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualInventoryForPositions is between 0 and 1e6"
            );
        }
        if (
            virtualInventoryForPositions > 1e6 &&
            virtualInventoryForPositions <= 1e12
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualInventoryForPositions is between 1e6 and 1e12"
            );
        }
        if (
            virtualInventoryForPositions > 1e12 &&
            virtualInventoryForPositions <= 1e18
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualInventoryForPositions is between 1e12 and 1e18"
            );
        }
        if (
            virtualInventoryForPositions > 1e18 &&
            virtualInventoryForPositions <= 1e24
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualInventoryForPositions is between 1e18 and 1e24"
            );
        }
        if (virtualInventoryForPositions > 1e24) {
            fl.log(
                "MarketInfo virtualInventory virtualInventoryForPositions is greater than 1e24"
            );
        }
        if (
            virtualInventoryForPositions < 0 &&
            virtualInventoryForPositions >= -1e6
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualInventoryForPositions is between 0 and -1e6"
            );
        }
        if (
            virtualInventoryForPositions < -1e6 &&
            virtualInventoryForPositions >= -1e12
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualInventoryForPositions is between -1e6 and -1e12"
            );
        }
        if (
            virtualInventoryForPositions < -1e12 &&
            virtualInventoryForPositions >= -1e18
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualInventoryForPositions is between -1e12 and -1e18"
            );
        }
        if (
            virtualInventoryForPositions < -1e18 &&
            virtualInventoryForPositions >= -1e24
        ) {
            fl.log(
                "MarketInfo virtualInventory virtualInventoryForPositions is between -1e18 and -1e24"
            );
        }
        if (virtualInventoryForPositions < -1e24) {
            fl.log(
                "MarketInfo virtualInventory virtualInventoryForPositions is less than -1e24"
            );
        }
    }

    function _logMarketInfoIsDisabledCoverage(bool isDisabled) internal {
        if (isDisabled) {
            fl.log("MarketInfo isDisabled is true");
        } else {
            fl.log("MarketInfo isDisabled is false");
        }
    }
}
