// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../properties/BeforeAfter.sol";

contract DecreasePositionInfoCoverage is BeforeAfter {
    //       /\_/\           ___
    //    = o_o =_______    \ \  DECREASE POSITION
    //     __^      __(  \.__) )  GET POSITION INFO
    // (@)<_____>__(_____)____/    COVERAGE

    function _checkDecreaseOrderAndGetPositionCoverage(
        Position.Props memory position
    ) internal {
        _logPositionAccountCoverage_decreasePosition(
            position.addresses.account
        );
        _logPositionMarketCoverage_decreasePosition(position.addresses.market);
        _logPositionCollateralTokenCoverage_decreasePosition(
            position.addresses.collateralToken
        );
        _logPositionSizeInUsdCoverage_decreasePosition(
            position.numbers.sizeInUsd
        );
        _logPositionSizeInTokensCoverage_decreasePosition(
            position.numbers.sizeInTokens
        );
        _logPositionCollateralAmountCoverage_decreasePosition(
            position.numbers.collateralAmount
        );
        _logPositionBorrowingFactorCoverage_decreasePosition(
            position.numbers.borrowingFactor
        );
        _logPositionFundingFeeAmountPerSizeCoverage_decreasePosition(
            position.numbers.fundingFeeAmountPerSize
        );
        _logPositionLongTokenClaimableFundingAmountPerSizeCoverage_decreasePosition(
            position.numbers.longTokenClaimableFundingAmountPerSize
        );
        _logPositionShortTokenClaimableFundingAmountPerSizeCoverage_decreasePosition(
            position.numbers.shortTokenClaimableFundingAmountPerSize
        );
        // _logPositionIncreasedAtBlockCoverage_decreasePosition(
        //     position.numbers.increasedAtBlock
        // );
        // _logPositionDecreasedAtBlockCoverage_decreasePosition(
        //     position.numbers.decreasedAtBlock
        // );
        _logPositionIncreasedAtTimeCoverage_decreasePosition(
            position.numbers.increasedAtTime
        );
        _logPositionDecreasedAtTimeCoverage_decreasePosition(
            position.numbers.decreasedAtTime
        );
        _logPositionIsLongCoverage_decreasePosition(position.flags.isLong);
    }

    function _logPositionAccountCoverage_decreasePosition(
        address account
    ) internal {
        if (account == USER0) {
            fl.log("PositionFees account USER0 hit");
        }
        if (account == USER1) {
            fl.log("PositionFees account USER1 hit");
        }
        if (account == USER2) {
            fl.log("PositionFees account USER2 hit");
        }
        if (account == USER3) {
            fl.log("PositionFees account USER3 hit");
        }
        if (account == USER4) {
            fl.log("PositionFees account USER4 hit");
        }
        if (account == USER5) {
            fl.log("PositionFees account USER5 hit");
        }
        if (account == USER6) {
            fl.log("PositionFees account USER6 hit");
        }
        if (account == USER7) {
            fl.log("PositionFees account USER7 hit");
        }
        if (account == USER8) {
            fl.log("PositionFees account USER8 hit");
        }
        if (account == USER9) {
            fl.log("PositionFees account USER9 hit");
        }
        if (account == USER10) {
            fl.log("PositionFees account USER10 hit");
        }
        if (account == USER11) {
            fl.log("PositionFees account USER11 hit");
        }
        if (account == USER12) {
            fl.log("PositionFees account USER12 hit");
        }
        if (account == USER13) {
            fl.log("PositionFees account USER13 hit");
        }
    }
    function _logPositionMarketCoverage_decreasePosition(
        address market
    ) internal {
        if (market == address(market_0_WETH_USDC)) {
            fl.log("Position market market_0_WETH_USDC hit");
        }

        if (market == address(market_WBTC_WBTC_USDC)) {
            fl.log("Position market market_WBTC_WBTC_USDC hit");
        }
        if (market == address(market_WETH_WETH_USDC)) {
            fl.log("Position market market_WETH_WETH_USDC hit");
        }
        if (market == address(market_WETH_WETH_USDT)) {
            fl.log("Position market market_WETH_WETH_USDT hit");
        }
    }

    function _logPositionCollateralTokenCoverage_decreasePosition(
        address collateralToken
    ) internal {
        if (collateralToken == address(WETH)) {
            fl.log("Position collateralToken is WETH");
        }
        if (collateralToken == address(WBTC)) {
            fl.log("Position collateralToken is WBTC");
        }
        if (collateralToken == address(USDC)) {
            fl.log("Position collateralToken is USDC");
        }
        if (collateralToken == address(USDT)) {
            fl.log("Position collateralToken is USDT");
        }
        if (collateralToken == address(SOL)) {
            fl.log("Position collateralToken is SOL");
        }
    }

    function _logPositionSizeInUsdCoverage_decreasePosition(
        uint256 sizeInUsd
    ) internal {
        if (sizeInUsd == 0) {
            fl.log("Position sizeInUsd is 0");
        }
        if (sizeInUsd > 0 && sizeInUsd <= 1e6) {
            fl.log("Position sizeInUsd is between 0 and 1e6");
        }
        if (sizeInUsd > 1e6 && sizeInUsd <= 1e12) {
            fl.log("Position sizeInUsd is between 1e6 and 1e12");
        }
        if (sizeInUsd > 1e12 && sizeInUsd <= 1e18) {
            fl.log("Position sizeInUsd is between 1e12 and 1e18");
        }
        if (sizeInUsd > 1e18 && sizeInUsd <= 1e24) {
            fl.log("Position sizeInUsd is between 1e18 and 1e24");
        }
        if (sizeInUsd > 1e24) {
            fl.log("Position sizeInUsd is greater than 1e24");
        }
    }

    function _logPositionSizeInTokensCoverage_decreasePosition(
        uint256 sizeInTokens
    ) internal {
        if (sizeInTokens == 0) {
            fl.log("Position sizeInTokens is 0");
        }
        if (sizeInTokens > 0 && sizeInTokens <= 1e6) {
            fl.log("Position sizeInTokens is between 0 and 1e6");
        }
        if (sizeInTokens > 1e6 && sizeInTokens <= 1e12) {
            fl.log("Position sizeInTokens is between 1e6 and 1e12");
        }
        if (sizeInTokens > 1e12 && sizeInTokens <= 1e18) {
            fl.log("Position sizeInTokens is between 1e12 and 1e18");
        }
        if (sizeInTokens > 1e18 && sizeInTokens <= 1e24) {
            fl.log("Position sizeInTokens is between 1e18 and 1e24");
        }
        if (sizeInTokens > 1e24) {
            fl.log("Position sizeInTokens is greater than 1e24");
        }
    }

    function _logPositionCollateralAmountCoverage_decreasePosition(
        uint256 collateralAmount
    ) internal {
        if (collateralAmount == 0) {
            fl.log("Position collateralAmount is 0");
        }
        if (collateralAmount > 0 && collateralAmount <= 1e6) {
            fl.log("Position collateralAmount is between 0 and 1e6");
        }
        if (collateralAmount > 1e6 && collateralAmount <= 1e12) {
            fl.log("Position collateralAmount is between 1e6 and 1e12");
        }
        if (collateralAmount > 1e12 && collateralAmount <= 1e18) {
            fl.log("Position collateralAmount is between 1e12 and 1e18");
        }
        if (collateralAmount > 1e18 && collateralAmount <= 1e24) {
            fl.log("Position collateralAmount is between 1e18 and 1e24");
        }
        if (collateralAmount > 1e24) {
            fl.log("Position collateralAmount is greater than 1e24");
        }
    }

    function _logPositionBorrowingFactorCoverage_decreasePosition(
        uint256 borrowingFactor
    ) internal {
        if (borrowingFactor == 0) {
            fl.log("Position borrowingFactor is 0");
        }
        if (borrowingFactor > 0 && borrowingFactor <= 1e6) {
            fl.log("Position borrowingFactor is between 0 and 1e6");
        }
        if (borrowingFactor > 1e6 && borrowingFactor <= 1e12) {
            fl.log("Position borrowingFactor is between 1e6 and 1e12");
        }
        if (borrowingFactor > 1e12 && borrowingFactor <= 1e18) {
            fl.log("Position borrowingFactor is between 1e12 and 1e18");
        }
        if (borrowingFactor > 1e18 && borrowingFactor <= 1e24) {
            fl.log("Position borrowingFactor is between 1e18 and 1e24");
        }
        if (borrowingFactor > 1e24) {
            fl.log("Position borrowingFactor is greater than 1e24");
        }
    }

    function _logPositionFundingFeeAmountPerSizeCoverage_decreasePosition(
        uint256 fundingFeeAmountPerSize
    ) internal {
        if (fundingFeeAmountPerSize == 0) {
            fl.log("Position fundingFeeAmountPerSize is 0");
        }
        if (fundingFeeAmountPerSize > 0 && fundingFeeAmountPerSize <= 1e6) {
            fl.log("Position fundingFeeAmountPerSize is between 0 and 1e6");
        }
        if (fundingFeeAmountPerSize > 1e6 && fundingFeeAmountPerSize <= 1e12) {
            fl.log("Position fundingFeeAmountPerSize is between 1e6 and 1e12");
        }
        if (fundingFeeAmountPerSize > 1e12 && fundingFeeAmountPerSize <= 1e18) {
            fl.log("Position fundingFeeAmountPerSize is between 1e12 and 1e18");
        }
        if (fundingFeeAmountPerSize > 1e18 && fundingFeeAmountPerSize <= 1e24) {
            fl.log("Position fundingFeeAmountPerSize is between 1e18 and 1e24");
        }
        if (fundingFeeAmountPerSize > 1e24) {
            fl.log("Position fundingFeeAmountPerSize is greater than 1e24");
        }
    }

    function _logPositionLongTokenClaimableFundingAmountPerSizeCoverage_decreasePosition(
        uint256 longTokenClaimableFundingAmountPerSize
    ) internal {
        if (longTokenClaimableFundingAmountPerSize == 0) {
            fl.log("Position longTokenClaimableFundingAmountPerSize is 0");
        }
        if (
            longTokenClaimableFundingAmountPerSize > 0 &&
            longTokenClaimableFundingAmountPerSize <= 1e6
        ) {
            fl.log(
                "Position longTokenClaimableFundingAmountPerSize is between 0 and 1e6"
            );
        }
        if (
            longTokenClaimableFundingAmountPerSize > 1e6 &&
            longTokenClaimableFundingAmountPerSize <= 1e12
        ) {
            fl.log(
                "Position longTokenClaimableFundingAmountPerSize is between 1e6 and 1e12"
            );
        }
        if (
            longTokenClaimableFundingAmountPerSize > 1e12 &&
            longTokenClaimableFundingAmountPerSize <= 1e18
        ) {
            fl.log(
                "Position longTokenClaimableFundingAmountPerSize is between 1e12 and 1e18"
            );
        }
        if (
            longTokenClaimableFundingAmountPerSize > 1e18 &&
            longTokenClaimableFundingAmountPerSize <= 1e24
        ) {
            fl.log(
                "Position longTokenClaimableFundingAmountPerSize is between 1e18 and 1e24"
            );
        }
        if (longTokenClaimableFundingAmountPerSize > 1e24) {
            fl.log(
                "Position longTokenClaimableFundingAmountPerSize is greater than 1e24"
            );
        }
    }

    function _logPositionShortTokenClaimableFundingAmountPerSizeCoverage_decreasePosition(
        uint256 shortTokenClaimableFundingAmountPerSize
    ) internal {
        if (shortTokenClaimableFundingAmountPerSize == 0) {
            fl.log("Position shortTokenClaimableFundingAmountPerSize is 0");
        }
        if (
            shortTokenClaimableFundingAmountPerSize > 0 &&
            shortTokenClaimableFundingAmountPerSize <= 1e6
        ) {
            fl.log(
                "Position shortTokenClaimableFundingAmountPerSize is between 0 and 1e6"
            );
        }
        if (
            shortTokenClaimableFundingAmountPerSize > 1e6 &&
            shortTokenClaimableFundingAmountPerSize <= 1e12
        ) {
            fl.log(
                "Position shortTokenClaimableFundingAmountPerSize is between 1e6 and 1e12"
            );
        }
        if (
            shortTokenClaimableFundingAmountPerSize > 1e12 &&
            shortTokenClaimableFundingAmountPerSize <= 1e18
        ) {
            fl.log(
                "Position shortTokenClaimableFundingAmountPerSize is between 1e12 and 1e18"
            );
        }
        if (
            shortTokenClaimableFundingAmountPerSize > 1e18 &&
            shortTokenClaimableFundingAmountPerSize <= 1e24
        ) {
            fl.log(
                "Position shortTokenClaimableFundingAmountPerSize is between 1e18 and 1e24"
            );
        }
        if (shortTokenClaimableFundingAmountPerSize > 1e24) {
            fl.log(
                "Position shortTokenClaimableFundingAmountPerSize is greater than 1e24"
            );
        }
    }

    function _logPositionIncreasedAtBlockCoverage_decreasePosition(
        uint256 increasedAtBlock
    ) internal {
        if (increasedAtBlock == 0) {
            fl.log("Position increasedAtBlock is 0");
        } else {
            fl.log("Position increasedAtBlock is non-zero");
        }
    }

    function _logPositionDecreasedAtBlockCoverage_decreasePosition(
        uint256 decreasedAtBlock
    ) internal {
        if (decreasedAtBlock == 0) {
            fl.log("Position decreasedAtBlock is 0");
        } else {
            fl.log("Position decreasedAtBlock is non-zero");
        }
    }

    function _logPositionIncreasedAtTimeCoverage_decreasePosition(
        uint256 increasedAtTime
    ) internal {
        if (increasedAtTime == 0) {
            fl.log("Position increasedAtTime is 0");
        } else {
            fl.log("Position increasedAtTime is non-zero");
        }
    }

    function _logPositionDecreasedAtTimeCoverage_decreasePosition(
        uint256 decreasedAtTime
    ) internal {
        if (decreasedAtTime == 0) {
            fl.log("Position decreasedAtTime is 0");
        } else {
            fl.log("Position decreasedAtTime is non-zero");
        }
    }

    function _logPositionIsLongCoverage_decreasePosition(bool isLong) internal {
        if (isLong) {
            fl.log("Position isLong is true");
        } else {
            fl.log("Position isLong is false");
        }
    }

    function _checkDecreaseOrderAndGetPositionInfoCoverage(
        ReaderPositionUtils.PositionInfo memory positionInfo
    ) internal {
        // PositionFees
        _logPositionFeesReferralCodeCoverage_decreasePosition(
            positionInfo.fees.referral.referralCode
        );
        _logPositionFeesAffiliateCoverage_decreasePosition(
            positionInfo.fees.referral.affiliate
        );
        _logPositionFeesTraderCoverage_decreasePosition(
            positionInfo.fees.referral.trader
        );
        _logPositionFeesTotalRebateFactorCoverage_decreasePosition(
            positionInfo.fees.referral.totalRebateFactor
        );
        _logPositionFeesTraderDiscountFactorCoverage_decreasePosition(
            positionInfo.fees.referral.traderDiscountFactor
        );
        _logPositionFeesTotalRebateAmountCoverage_decreasePosition(
            positionInfo.fees.referral.totalRebateAmount
        );
        _logPositionFeesTraderDiscountAmountCoverage_decreasePosition(
            positionInfo.fees.referral.traderDiscountAmount
        );
        _logPositionFeesAffiliateRewardAmountCoverage_decreasePosition(
            positionInfo.fees.referral.affiliateRewardAmount
        );
        _logPositionFeesFundingFeeAmountCoverage_decreasePosition(
            positionInfo.fees.funding.fundingFeeAmount
        );
        _logPositionFeesClaimableLongTokenAmountCoverage_decreasePosition(
            positionInfo.fees.funding.claimableLongTokenAmount
        );
        _logPositionFeesClaimableShortTokenAmountCoverage_decreasePosition(
            positionInfo.fees.funding.claimableShortTokenAmount
        );
        _logPositionFeesLatestFundingFeeAmountPerSizeCoverage_decreasePosition(
            positionInfo.fees.funding.latestFundingFeeAmountPerSize
        );
        _logPositionFeesLatestLongTokenClaimableFundingAmountPerSizeCoverage_decreasePosition(
            positionInfo
                .fees
                .funding
                .latestLongTokenClaimableFundingAmountPerSize
        );
        _logPositionFeesLatestShortTokenClaimableFundingAmountPerSizeCoverage_decreasePosition(
            positionInfo
                .fees
                .funding
                .latestShortTokenClaimableFundingAmountPerSize
        );
        _logPositionFeesBorrowingFeeUsdCoverage_decreasePosition(
            positionInfo.fees.borrowing.borrowingFeeUsd
        );
        _logPositionFeesBorrowingFeeAmountCoverage_decreasePosition(
            positionInfo.fees.borrowing.borrowingFeeAmount
        );
        _logPositionFeesBorrowingFeeReceiverFactorCoverage_decreasePosition(
            positionInfo.fees.borrowing.borrowingFeeReceiverFactor
        );
        _logPositionFeesBorrowingFeeAmountForFeeReceiverCoverage_decreasePosition(
            positionInfo.fees.borrowing.borrowingFeeAmountForFeeReceiver
        );
        _logPositionFeesUiFeeReceiverCoverage_decreasePosition(
            positionInfo.fees.ui.uiFeeReceiver
        );
        _logPositionFeesUiFeeReceiverFactorCoverage_decreasePosition(
            positionInfo.fees.ui.uiFeeReceiverFactor
        );
        _logPositionFeesUiFeeAmountCoverage_decreasePosition(
            positionInfo.fees.ui.uiFeeAmount
        );
        _logPositionFeesCollateralTokenPriceCoverage_decreasePosition(
            positionInfo.fees.collateralTokenPrice.max
        );

        _logPositionFeesPositionFeeFactorCoverage_decreasePosition(
            positionInfo.fees.positionFeeFactor
        );
        _logPositionFeesProtocolFeeAmountCoverage_decreasePosition(
            positionInfo.fees.protocolFeeAmount
        );
        _logPositionFeesPositionFeeReceiverFactorCoverage_decreasePosition(
            positionInfo.fees.positionFeeReceiverFactor
        );
        _logPositionFeesFeeReceiverAmountCoverage_decreasePosition(
            positionInfo.fees.feeReceiverAmount
        );
        _logPositionFeesFeeAmountForPoolCoverage_decreasePosition(
            positionInfo.fees.feeAmountForPool
        );
        _logPositionFeesPositionFeeAmountForPoolCoverage_decreasePosition(
            positionInfo.fees.positionFeeAmountForPool
        );
        _logPositionFeesPositionFeeAmountCoverage_decreasePosition(
            positionInfo.fees.positionFeeAmount
        );
        _logPositionFeesTotalCostAmountExcludingFundingCoverage_decreasePosition(
            positionInfo.fees.totalCostAmountExcludingFunding
        );
        _logPositionFeesTotalCostAmountCoverage_decreasePosition(
            positionInfo.fees.totalCostAmount
        );

        // ExecutionPriceResult
        _logExecutionPriceResultPriceImpactUsdCoverage_decreasePosition(
            positionInfo.executionPriceResult.priceImpactUsd
        );
        _logExecutionPriceResultPriceImpactDiffUsdCoverage_decreasePosition(
            positionInfo.executionPriceResult.priceImpactDiffUsd
        );
        _logExecutionPriceResultExecutionPriceCoverage_decreasePosition(
            positionInfo.executionPriceResult.executionPrice
        );

        _logPositionInfoBasePnlUsdCoverage_decreasePosition(
            positionInfo.basePnlUsd
        );
        _logPositionInfoUncappedBasePnlUsdCoverage_decreasePosition(
            positionInfo.uncappedBasePnlUsd
        );
        _logPositionInfoPnlAfterPriceImpactUsdCoverage_decreasePosition(
            positionInfo.pnlAfterPriceImpactUsd
        );
    }

    function _logPositionFeesReferralCodeCoverage_decreasePosition(
        bytes32 referralCode
    ) internal {
        if (referralCode == bytes32(0)) {
            fl.log("PositionFees referralCode is empty");
        } else {
            fl.log("PositionFees referralCode is non-empty");
        }
    }

    function _logPositionFeesAffiliateCoverage_decreasePosition(
        address affiliate
    ) internal {
        if (affiliate == address(0)) {
            fl.log("PositionFees affiliate is address(0)");
        } else {
            fl.log("PositionFees affiliate is non-zero address");
        }
    }

    function _logPositionFeesTraderCoverage_decreasePosition(
        address trader
    ) internal {
        if (trader == USER0) {
            fl.log("PositionFees trader USER0 hit");
        }
        if (trader == USER1) {
            fl.log("PositionFees trader USER1 hit");
        }
        if (trader == USER2) {
            fl.log("PositionFees trader USER2 hit");
        }
        if (trader == USER3) {
            fl.log("PositionFees trader USER3 hit");
        }
        if (trader == USER4) {
            fl.log("PositionFees trader USER4 hit");
        }
        if (trader == USER5) {
            fl.log("PositionFees trader USER5 hit");
        }
        if (trader == USER6) {
            fl.log("PositionFees trader USER6 hit");
        }
        if (trader == USER7) {
            fl.log("PositionFees trader USER7 hit");
        }
        if (trader == USER8) {
            fl.log("PositionFees trader USER8 hit");
        }
        if (trader == USER9) {
            fl.log("PositionFees trader USER9 hit");
        }
        if (trader == USER10) {
            fl.log("PositionFees trader USER10 hit");
        }
        if (trader == USER11) {
            fl.log("PositionFees trader USER11 hit");
        }
        if (trader == USER12) {
            fl.log("PositionFees trader USER12 hit");
        }
        if (trader == USER13) {
            fl.log("PositionFees trader USER13 hit");
        }
    }

    function _logPositionFeesTotalRebateFactorCoverage_decreasePosition(
        uint256 totalRebateFactor
    ) internal {
        if (totalRebateFactor == 0) {
            fl.log("PositionFees totalRebateFactor is 0");
        }
        if (totalRebateFactor > 0 && totalRebateFactor <= 1e6) {
            fl.log("PositionFees totalRebateFactor is between 0 and 1e6");
        }
        if (totalRebateFactor > 1e6 && totalRebateFactor <= 1e12) {
            fl.log("PositionFees totalRebateFactor is between 1e6 and 1e12");
        }
        if (totalRebateFactor > 1e12 && totalRebateFactor <= 1e18) {
            fl.log("PositionFees totalRebateFactor is between 1e12 and 1e18");
        }
        if (totalRebateFactor > 1e18 && totalRebateFactor <= 1e24) {
            fl.log("PositionFees totalRebateFactor is between 1e18 and 1e24");
        }
        if (totalRebateFactor > 1e24) {
            fl.log("PositionFees totalRebateFactor is greater than 1e24");
        }
    }

    function _logPositionFeesTraderDiscountFactorCoverage_decreasePosition(
        uint256 traderDiscountFactor
    ) internal {
        if (traderDiscountFactor == 0) {
            fl.log("PositionFees traderDiscountFactor is 0");
        }
        if (traderDiscountFactor > 0 && traderDiscountFactor <= 1e6) {
            fl.log("PositionFees traderDiscountFactor is between 0 and 1e6");
        }
        if (traderDiscountFactor > 1e6 && traderDiscountFactor <= 1e12) {
            fl.log("PositionFees traderDiscountFactor is between 1e6 and 1e12");
        }
        if (traderDiscountFactor > 1e12 && traderDiscountFactor <= 1e18) {
            fl.log(
                "PositionFees traderDiscountFactor is between 1e12 and 1e18"
            );
        }
        if (traderDiscountFactor > 1e18 && traderDiscountFactor <= 1e24) {
            fl.log(
                "PositionFees traderDiscountFactor is between 1e18 and 1e24"
            );
        }
        if (traderDiscountFactor > 1e24) {
            fl.log("PositionFees traderDiscountFactor is greater than 1e24");
        }
    }

    function _logPositionFeesTotalRebateAmountCoverage_decreasePosition(
        uint256 totalRebateAmount
    ) internal {
        if (totalRebateAmount == 0) {
            fl.log("PositionFees totalRebateAmount is 0");
        }
        if (totalRebateAmount > 0 && totalRebateAmount <= 1e6) {
            fl.log("PositionFees totalRebateAmount is between 0 and 1e6");
        }
        if (totalRebateAmount > 1e6 && totalRebateAmount <= 1e12) {
            fl.log("PositionFees totalRebateAmount is between 1e6 and 1e12");
        }
        if (totalRebateAmount > 1e12 && totalRebateAmount <= 1e18) {
            fl.log("PositionFees totalRebateAmount is between 1e12 and 1e18");
        }
        if (totalRebateAmount > 1e18 && totalRebateAmount <= 1e24) {
            fl.log("PositionFees totalRebateAmount is between 1e18 and 1e24");
        }
        if (totalRebateAmount > 1e24) {
            fl.log("PositionFees totalRebateAmount is greater than 1e24");
        }
    }

    function _logPositionFeesTraderDiscountAmountCoverage_decreasePosition(
        uint256 traderDiscountAmount
    ) internal {
        if (traderDiscountAmount == 0) {
            fl.log("PositionFees traderDiscountAmount is 0");
        }
        if (traderDiscountAmount > 0 && traderDiscountAmount <= 1e6) {
            fl.log("PositionFees traderDiscountAmount is between 0 and 1e6");
        }
        if (traderDiscountAmount > 1e6 && traderDiscountAmount <= 1e12) {
            fl.log("PositionFees traderDiscountAmount is between 1e6 and 1e12");
        }
        if (traderDiscountAmount > 1e12 && traderDiscountAmount <= 1e18) {
            fl.log(
                "PositionFees traderDiscountAmount is between 1e12 and 1e18"
            );
        }
        if (traderDiscountAmount > 1e18 && traderDiscountAmount <= 1e24) {
            fl.log(
                "PositionFees traderDiscountAmount is between 1e18 and 1e24"
            );
        }
        if (traderDiscountAmount > 1e24) {
            fl.log("PositionFees traderDiscountAmount is greater than 1e24");
        }
    }

    function _logPositionFeesAffiliateRewardAmountCoverage_decreasePosition(
        uint256 affiliateRewardAmount
    ) internal {
        if (affiliateRewardAmount == 0) {
            fl.log("PositionFees affiliateRewardAmount is 0");
        }
        if (affiliateRewardAmount > 0 && affiliateRewardAmount <= 1e6) {
            fl.log("PositionFees affiliateRewardAmount is between 0 and 1e6");
        }
        if (affiliateRewardAmount > 1e6 && affiliateRewardAmount <= 1e12) {
            fl.log(
                "PositionFees affiliateRewardAmount is between 1e6 and 1e12"
            );
        }
        if (affiliateRewardAmount > 1e12 && affiliateRewardAmount <= 1e18) {
            fl.log(
                "PositionFees affiliateRewardAmount is between 1e12 and 1e18"
            );
        }
        if (affiliateRewardAmount > 1e18 && affiliateRewardAmount <= 1e24) {
            fl.log(
                "PositionFees affiliateRewardAmount is between 1e18 and 1e24"
            );
        }
        if (affiliateRewardAmount > 1e24) {
            fl.log("PositionFees affiliateRewardAmount is greater than 1e24");
        }
    }

    function _logPositionFeesFundingFeeAmountCoverage_decreasePosition(
        uint256 fundingFeeAmount
    ) internal {
        if (fundingFeeAmount == 0) {
            fl.log("PositionFees fundingFeeAmount is 0");
        }
        if (fundingFeeAmount > 0 && fundingFeeAmount <= 1e6) {
            fl.log("PositionFees fundingFeeAmount is between 0 and 1e6");
        }
        if (fundingFeeAmount > 1e6 && fundingFeeAmount <= 1e12) {
            fl.log("PositionFees fundingFeeAmount is between 1e6 and 1e12");
        }
        if (fundingFeeAmount > 1e12 && fundingFeeAmount <= 1e18) {
            fl.log("PositionFees fundingFeeAmount is between 1e12 and 1e18");
        }
        if (fundingFeeAmount > 1e18 && fundingFeeAmount <= 1e24) {
            fl.log("PositionFees fundingFeeAmount is between 1e18 and 1e24");
        }
        if (fundingFeeAmount > 1e24) {
            fl.log("PositionFees fundingFeeAmount is greater than 1e24");
        }
    }

    function _logPositionFeesClaimableLongTokenAmountCoverage_decreasePosition(
        uint256 claimableLongTokenAmount
    ) internal {
        if (claimableLongTokenAmount == 0) {
            fl.log("PositionFees claimableLongTokenAmount is 0");
        }
        if (claimableLongTokenAmount > 0 && claimableLongTokenAmount <= 1e6) {
            fl.log(
                "PositionFees claimableLongTokenAmount is between 0 and 1e6"
            );
        }
        if (
            claimableLongTokenAmount > 1e6 && claimableLongTokenAmount <= 1e12
        ) {
            fl.log(
                "PositionFees claimableLongTokenAmount is between 1e6 and 1e12"
            );
        }
        if (
            claimableLongTokenAmount > 1e12 && claimableLongTokenAmount <= 1e18
        ) {
            fl.log(
                "PositionFees claimableLongTokenAmount is between 1e12 and 1e18"
            );
        }
        if (
            claimableLongTokenAmount > 1e18 && claimableLongTokenAmount <= 1e24
        ) {
            fl.log(
                "PositionFees claimableLongTokenAmount is between 1e18 and 1e24"
            );
        }
        if (claimableLongTokenAmount > 1e24) {
            fl.log(
                "PositionFees claimableLongTokenAmount is greater than 1e24"
            );
        }
    }

    function _logPositionFeesClaimableShortTokenAmountCoverage_decreasePosition(
        uint256 claimableShortTokenAmount
    ) internal {
        if (claimableShortTokenAmount == 0) {
            fl.log("PositionFees claimableShortTokenAmount is 0");
        }
        if (claimableShortTokenAmount > 0 && claimableShortTokenAmount <= 1e6) {
            fl.log(
                "PositionFees claimableShortTokenAmount is between 0 and 1e6"
            );
        }
        if (
            claimableShortTokenAmount > 1e6 && claimableShortTokenAmount <= 1e12
        ) {
            fl.log(
                "PositionFees claimableShortTokenAmount is between 1e6 and 1e12"
            );
        }
        if (
            claimableShortTokenAmount > 1e12 &&
            claimableShortTokenAmount <= 1e18
        ) {
            fl.log(
                "PositionFees claimableShortTokenAmount is between 1e12 and 1e18"
            );
        }
        if (
            claimableShortTokenAmount > 1e18 &&
            claimableShortTokenAmount <= 1e24
        ) {
            fl.log(
                "PositionFees claimableShortTokenAmount is between 1e18 and 1e24"
            );
        }
        if (claimableShortTokenAmount > 1e24) {
            fl.log(
                "PositionFees claimableShortTokenAmount is greater than 1e24"
            );
        }
    }

    function _logPositionFeesLatestFundingFeeAmountPerSizeCoverage_decreasePosition(
        uint256 latestFundingFeeAmountPerSize
    ) internal {
        if (latestFundingFeeAmountPerSize == 0) {
            fl.log("PositionFees latestFundingFeeAmountPerSize is 0");
        }
        if (
            latestFundingFeeAmountPerSize > 0 &&
            latestFundingFeeAmountPerSize <= 1e6
        ) {
            fl.log(
                "PositionFees latestFundingFeeAmountPerSize is between 0 and 1e6"
            );
        }
        if (
            latestFundingFeeAmountPerSize > 1e6 &&
            latestFundingFeeAmountPerSize <= 1e12
        ) {
            fl.log(
                "PositionFees latestFundingFeeAmountPerSize is between 1e6 and 1e12"
            );
        }
        if (
            latestFundingFeeAmountPerSize > 1e12 &&
            latestFundingFeeAmountPerSize <= 1e18
        ) {
            fl.log(
                "PositionFees latestFundingFeeAmountPerSize is between 1e12 and 1e18"
            );
        }
        if (
            latestFundingFeeAmountPerSize > 1e18 &&
            latestFundingFeeAmountPerSize <= 1e24
        ) {
            fl.log(
                "PositionFees latestFundingFeeAmountPerSize is between 1e18 and 1e24"
            );
        }
        if (latestFundingFeeAmountPerSize > 1e24) {
            fl.log(
                "PositionFees latestFundingFeeAmountPerSize is greater than 1e24"
            );
        }
    }

    function _logPositionFeesLatestLongTokenClaimableFundingAmountPerSizeCoverage_decreasePosition(
        uint256 latestLongTokenClaimableFundingAmountPerSize
    ) internal {
        if (latestLongTokenClaimableFundingAmountPerSize == 0) {
            fl.log(
                "PositionFees latestLongTokenClaimableFundingAmountPerSize is 0"
            );
        }
        if (
            latestLongTokenClaimableFundingAmountPerSize > 0 &&
            latestLongTokenClaimableFundingAmountPerSize <= 1e6
        ) {
            fl.log(
                "PositionFees latestLongTokenClaimableFundingAmountPerSize is between 0 and 1e6"
            );
        }
        if (
            latestLongTokenClaimableFundingAmountPerSize > 1e6 &&
            latestLongTokenClaimableFundingAmountPerSize <= 1e12
        ) {
            fl.log(
                "PositionFees latestLongTokenClaimableFundingAmountPerSize is between 1e6 and 1e12"
            );
        }
        if (
            latestLongTokenClaimableFundingAmountPerSize > 1e12 &&
            latestLongTokenClaimableFundingAmountPerSize <= 1e18
        ) {
            fl.log(
                "PositionFees latestLongTokenClaimableFundingAmountPerSize is between 1e12 and 1e18"
            );
        }
        if (
            latestLongTokenClaimableFundingAmountPerSize > 1e18 &&
            latestLongTokenClaimableFundingAmountPerSize <= 1e24
        ) {
            fl.log(
                "PositionFees latestLongTokenClaimableFundingAmountPerSize is between 1e18 and 1e24"
            );
        }
        if (latestLongTokenClaimableFundingAmountPerSize > 1e24) {
            fl.log(
                "PositionFees latestLongTokenClaimableFundingAmountPerSize is greater than 1e24"
            );
        }
    }

    function _logPositionFeesLatestShortTokenClaimableFundingAmountPerSizeCoverage_decreasePosition(
        uint256 latestShortTokenClaimableFundingAmountPerSize
    ) internal {
        if (latestShortTokenClaimableFundingAmountPerSize == 0) {
            fl.log(
                "PositionFees latestShortTokenClaimableFundingAmountPerSize is 0"
            );
        }
        if (
            latestShortTokenClaimableFundingAmountPerSize > 0 &&
            latestShortTokenClaimableFundingAmountPerSize <= 1e6
        ) {
            fl.log(
                "PositionFees latestShortTokenClaimableFundingAmountPerSize is between 0 and 1e6"
            );
        }
        if (
            latestShortTokenClaimableFundingAmountPerSize > 1e6 &&
            latestShortTokenClaimableFundingAmountPerSize <= 1e12
        ) {
            fl.log(
                "PositionFees latestShortTokenClaimableFundingAmountPerSize is between 1e6 and 1e12"
            );
        }
        if (
            latestShortTokenClaimableFundingAmountPerSize > 1e12 &&
            latestShortTokenClaimableFundingAmountPerSize <= 1e18
        ) {
            fl.log(
                "PositionFees latestShortTokenClaimableFundingAmountPerSize is between 1e12 and 1e18"
            );
        }
        if (
            latestShortTokenClaimableFundingAmountPerSize > 1e18 &&
            latestShortTokenClaimableFundingAmountPerSize <= 1e24
        ) {
            fl.log(
                "PositionFees latestShortTokenClaimableFundingAmountPerSize is between 1e18 and 1e24"
            );
        }
        if (latestShortTokenClaimableFundingAmountPerSize > 1e24) {
            fl.log(
                "PositionFees latestShortTokenClaimableFundingAmountPerSize is greater than 1e24"
            );
        }
    }

    function _logPositionFeesBorrowingFeeUsdCoverage_decreasePosition(
        uint256 borrowingFeeUsd
    ) internal {
        if (borrowingFeeUsd == 0) {
            fl.log("PositionFees borrowingFeeUsd is 0");
        }
        if (borrowingFeeUsd > 0 && borrowingFeeUsd <= 1e6) {
            fl.log("PositionFees borrowingFeeUsd is between 0 and 1e6");
        }
        if (borrowingFeeUsd > 1e6 && borrowingFeeUsd <= 1e12) {
            fl.log("PositionFees borrowingFeeUsd is between 1e6 and 1e12");
        }
        if (borrowingFeeUsd > 1e12 && borrowingFeeUsd <= 1e18) {
            fl.log("PositionFees borrowingFeeUsd is between 1e12 and 1e18");
        }
        if (borrowingFeeUsd > 1e18 && borrowingFeeUsd <= 1e24) {
            fl.log("PositionFees borrowingFeeUsd is between 1e18 and 1e24");
        }
        if (borrowingFeeUsd > 1e24) {
            fl.log("PositionFees borrowingFeeUsd is greater than 1e24");
        }
    }

    function _logPositionFeesBorrowingFeeAmountCoverage_decreasePosition(
        uint256 borrowingFeeAmount
    ) internal {
        if (borrowingFeeAmount == 0) {
            fl.log("PositionFees borrowingFeeAmount is 0");
        }
        if (borrowingFeeAmount > 0 && borrowingFeeAmount <= 1e6) {
            fl.log("PositionFees borrowingFeeAmount is between 0 and 1e6");
        }
        if (borrowingFeeAmount > 1e6 && borrowingFeeAmount <= 1e12) {
            fl.log("PositionFees borrowingFeeAmount is between 1e6 and 1e12");
        }
        if (borrowingFeeAmount > 1e12 && borrowingFeeAmount <= 1e18) {
            fl.log("PositionFees borrowingFeeAmount is between 1e12 and 1e18");
        }
        if (borrowingFeeAmount > 1e18 && borrowingFeeAmount <= 1e24) {
            fl.log("PositionFees borrowingFeeAmount is between 1e18 and 1e24");
        }
        if (borrowingFeeAmount > 1e24) {
            fl.log("PositionFees borrowingFeeAmount is greater than 1e24");
        }
    }

    function _logPositionFeesBorrowingFeeReceiverFactorCoverage_decreasePosition(
        uint256 borrowingFeeReceiverFactor
    ) internal {
        if (borrowingFeeReceiverFactor == 0) {
            fl.log("PositionFees borrowingFeeReceiverFactor is 0");
        }
        if (
            borrowingFeeReceiverFactor > 0 && borrowingFeeReceiverFactor <= 1e6
        ) {
            fl.log(
                "PositionFees borrowingFeeReceiverFactor is between 0 and 1e6"
            );
        }
        if (
            borrowingFeeReceiverFactor > 1e6 &&
            borrowingFeeReceiverFactor <= 1e12
        ) {
            fl.log(
                "PositionFees borrowingFeeReceiverFactor is between 1e6 and 1e12"
            );
        }
        if (
            borrowingFeeReceiverFactor > 1e12 &&
            borrowingFeeReceiverFactor <= 1e18
        ) {
            fl.log(
                "PositionFees borrowingFeeReceiverFactor is between 1e12 and 1e18"
            );
        }
        if (
            borrowingFeeReceiverFactor > 1e18 &&
            borrowingFeeReceiverFactor <= 1e24
        ) {
            fl.log(
                "PositionFees borrowingFeeReceiverFactor is between 1e18 and 1e24"
            );
        }
        if (borrowingFeeReceiverFactor > 1e24) {
            fl.log(
                "PositionFees borrowingFeeReceiverFactor is greater than 1e24"
            );
        }
    }

    function _logPositionFeesBorrowingFeeAmountForFeeReceiverCoverage_decreasePosition(
        uint256 borrowingFeeAmountForFeeReceiver
    ) internal {
        if (borrowingFeeAmountForFeeReceiver == 0) {
            fl.log("PositionFees borrowingFeeAmountForFeeReceiver is 0");
        }
        if (
            borrowingFeeAmountForFeeReceiver > 0 &&
            borrowingFeeAmountForFeeReceiver <= 1e6
        ) {
            fl.log(
                "PositionFees borrowingFeeAmountForFeeReceiver is between 0 and 1e6"
            );
        }
        if (
            borrowingFeeAmountForFeeReceiver > 1e6 &&
            borrowingFeeAmountForFeeReceiver <= 1e12
        ) {
            fl.log(
                "PositionFees borrowingFeeAmountForFeeReceiver is between 1e6 and 1e12"
            );
        }
        if (
            borrowingFeeAmountForFeeReceiver > 1e12 &&
            borrowingFeeAmountForFeeReceiver <= 1e18
        ) {
            fl.log(
                "PositionFees borrowingFeeAmountForFeeReceiver is between 1e12 and 1e18"
            );
        }
        if (
            borrowingFeeAmountForFeeReceiver > 1e18 &&
            borrowingFeeAmountForFeeReceiver <= 1e24
        ) {
            fl.log(
                "PositionFees borrowingFeeAmountForFeeReceiver is between 1e18 and 1e24"
            );
        }
        if (borrowingFeeAmountForFeeReceiver > 1e24) {
            fl.log(
                "PositionFees borrowingFeeAmountForFeeReceiver is greater than 1e24"
            );
        }
    }

    function _logPositionFeesUiFeeReceiverCoverage_decreasePosition(
        address uiFeeReceiver
    ) internal {
        if (uiFeeReceiver == address(0)) {
            fl.log("PositionFees uiFeeReceiver is address(0)");
        } else {
            fl.log("PositionFees uiFeeReceiver is non-zero address");
        }
    }

    function _logPositionFeesUiFeeReceiverFactorCoverage_decreasePosition(
        uint256 uiFeeReceiverFactor
    ) internal {
        if (uiFeeReceiverFactor == 0) {
            fl.log("PositionFees uiFeeReceiverFactor is 0");
        }
        if (uiFeeReceiverFactor > 0 && uiFeeReceiverFactor <= 1e6) {
            fl.log("PositionFees uiFeeReceiverFactor is between 0 and 1e6");
        }
        if (uiFeeReceiverFactor > 1e6 && uiFeeReceiverFactor <= 1e12) {
            fl.log("PositionFees uiFeeReceiverFactor is between 1e6 and 1e12");
        }
        if (uiFeeReceiverFactor > 1e12 && uiFeeReceiverFactor <= 1e18) {
            fl.log("PositionFees uiFeeReceiverFactor is between 1e12 and 1e18");
        }
        if (uiFeeReceiverFactor > 1e18 && uiFeeReceiverFactor <= 1e24) {
            fl.log("PositionFees uiFeeReceiverFactor is between 1e18 and 1e24");
        }
        if (uiFeeReceiverFactor > 1e24) {
            fl.log("PositionFees uiFeeReceiverFactor is greater than 1e24");
        }
    }

    function _logPositionFeesUiFeeAmountCoverage_decreasePosition(
        uint256 uiFeeAmount
    ) internal {
        if (uiFeeAmount == 0) {
            fl.log("PositionFees uiFeeAmount is 0");
        }
        if (uiFeeAmount > 0 && uiFeeAmount <= 1e6) {
            fl.log("PositionFees uiFeeAmount is between 0 and 1e6");
        }
        if (uiFeeAmount > 1e6 && uiFeeAmount <= 1e12) {
            fl.log("PositionFees uiFeeAmount is between 1e6 and 1e12");
        }
        if (uiFeeAmount > 1e12 && uiFeeAmount <= 1e18) {
            fl.log("PositionFees uiFeeAmount is between 1e12 and 1e18");
        }
        if (uiFeeAmount > 1e18 && uiFeeAmount <= 1e24) {
            fl.log("PositionFees uiFeeAmount is between 1e18 and 1e24");
        }
        if (uiFeeAmount > 1e24) {
            fl.log("PositionFees uiFeeAmount is greater than 1e24");
        }
    }

    function _logPositionFeesCollateralTokenPriceCoverage_decreasePosition(
        uint256 collateralTokenPrice
    ) internal {
        if (collateralTokenPrice == 0) {
            fl.log("PositionFees collateralTokenPrice is 0");
        }
        if (collateralTokenPrice > 0 && collateralTokenPrice <= 1e6) {
            fl.log("PositionFees collateralTokenPrice is between 0 and 1e6");
        }
        if (collateralTokenPrice > 1e6 && collateralTokenPrice <= 1e12) {
            fl.log("PositionFees collateralTokenPrice is between 1e6 and 1e12");
        }
        if (collateralTokenPrice > 1e12 && collateralTokenPrice <= 1e18) {
            fl.log(
                "PositionFees collateralTokenPrice is between 1e12 and 1e18"
            );
        }
        if (collateralTokenPrice > 1e18 && collateralTokenPrice <= 1e24) {
            fl.log(
                "PositionFees collateralTokenPrice is between 1e18 and 1e24"
            );
        }
        if (collateralTokenPrice > 1e24) {
            fl.log("PositionFees collateralTokenPrice is greater than 1e24");
        }
    }

    function _logPositionFeesPositionFeeFactorCoverage_decreasePosition(
        uint256 positionFeeFactor
    ) internal {
        if (positionFeeFactor == 0) {
            fl.log("PositionFees positionFeeFactor is 0");
        }
        if (positionFeeFactor > 0 && positionFeeFactor <= 1e6) {
            fl.log("PositionFees positionFeeFactor is between 0 and 1e6");
        }
        if (positionFeeFactor > 1e6 && positionFeeFactor <= 1e12) {
            fl.log("PositionFees positionFeeFactor is between 1e6 and 1e12");
        }
        if (positionFeeFactor > 1e12 && positionFeeFactor <= 1e18) {
            fl.log("PositionFees positionFeeFactor is between 1e12 and 1e18");
        }
        if (positionFeeFactor > 1e18 && positionFeeFactor <= 1e24) {
            fl.log("PositionFees positionFeeFactor is between 1e18 and 1e24");
        }
        if (positionFeeFactor > 1e24) {
            fl.log("PositionFees positionFeeFactor is greater than 1e24");
        }
    }
    function _logPositionFeesProtocolFeeAmountCoverage_decreasePosition(
        uint256 protocolFeeAmount
    ) internal {
        if (protocolFeeAmount == 0) {
            fl.log("PositionFees protocolFeeAmount is 0");
        }
        if (protocolFeeAmount > 0 && protocolFeeAmount <= 1e6) {
            fl.log("PositionFees protocolFeeAmount is between 0 and 1e6");
        }
        if (protocolFeeAmount > 1e6 && protocolFeeAmount <= 1e12) {
            fl.log("PositionFees protocolFeeAmount is between 1e6 and 1e12");
        }
        if (protocolFeeAmount > 1e12 && protocolFeeAmount <= 1e18) {
            fl.log("PositionFees protocolFeeAmount is between 1e12 and 1e18");
        }
        if (protocolFeeAmount > 1e18 && protocolFeeAmount <= 1e24) {
            fl.log("PositionFees protocolFeeAmount is between 1e18 and 1e24");
        }
        if (protocolFeeAmount > 1e24) {
            fl.log("PositionFees protocolFeeAmount is greater than 1e24");
        }
    }
    function _logPositionFeesPositionFeeReceiverFactorCoverage_decreasePosition(
        uint256 positionFeeReceiverFactor
    ) internal {
        if (positionFeeReceiverFactor == 0) {
            fl.log("PositionFees positionFeeReceiverFactor is 0");
        }

        if (positionFeeReceiverFactor > 0 && positionFeeReceiverFactor <= 1e6) {
            fl.log(
                "PositionFees positionFeeReceiverFactor is between 0 and 1e6"
            );
        }

        if (
            positionFeeReceiverFactor > 1e6 && positionFeeReceiverFactor <= 1e12
        ) {
            fl.log(
                "PositionFees positionFeeReceiverFactor is between 1e6 and 1e12"
            );
        }

        if (
            positionFeeReceiverFactor > 1e12 &&
            positionFeeReceiverFactor <= 1e18
        ) {
            fl.log(
                "PositionFees positionFeeReceiverFactor is between 1e12 and 1e18"
            );
        }

        if (
            positionFeeReceiverFactor > 1e18 &&
            positionFeeReceiverFactor <= 1e24
        ) {
            fl.log(
                "PositionFees positionFeeReceiverFactor is between 1e18 and 1e24"
            );
        }

        if (positionFeeReceiverFactor > 1e24) {
            fl.log(
                "PositionFees positionFeeReceiverFactor is greater than 1e24"
            );
        }
    }

    function _logPositionFeesFeeReceiverAmountCoverage_decreasePosition(
        uint256 feeReceiverAmount
    ) internal {
        if (feeReceiverAmount == 0) {
            fl.log("PositionFees feeReceiverAmount is 0");
        }
        if (feeReceiverAmount > 0 && feeReceiverAmount <= 1e6) {
            fl.log("PositionFees feeReceiverAmount is between 0 and 1e6");
        }
        if (feeReceiverAmount > 1e6 && feeReceiverAmount <= 1e12) {
            fl.log("PositionFees feeReceiverAmount is between 1e6 and 1e12");
        }
        if (feeReceiverAmount > 1e12 && feeReceiverAmount <= 1e18) {
            fl.log("PositionFees feeReceiverAmount is between 1e12 and 1e18");
        }
        if (feeReceiverAmount > 1e18 && feeReceiverAmount <= 1e24) {
            fl.log("PositionFees feeReceiverAmount is between 1e18 and 1e24");
        }
        if (feeReceiverAmount > 1e24) {
            fl.log("PositionFees feeReceiverAmount is greater than 1e24");
        }
    }

    function _logPositionFeesFeeAmountForPoolCoverage_decreasePosition(
        uint256 feeAmountForPool
    ) internal {
        if (feeAmountForPool == 0) {
            fl.log("PositionFees feeAmountForPool is 0");
        }
        if (feeAmountForPool > 0 && feeAmountForPool <= 1e6) {
            fl.log("PositionFees feeAmountForPool is between 0 and 1e6");
        }
        if (feeAmountForPool > 1e6 && feeAmountForPool <= 1e12) {
            fl.log("PositionFees feeAmountForPool is between 1e6 and 1e12");
        }
        if (feeAmountForPool > 1e12 && feeAmountForPool <= 1e18) {
            fl.log("PositionFees feeAmountForPool is between 1e12 and 1e18");
        }
        if (feeAmountForPool > 1e18 && feeAmountForPool <= 1e24) {
            fl.log("PositionFees feeAmountForPool is between 1e18 and 1e24");
        }
        if (feeAmountForPool > 1e24) {
            fl.log("PositionFees feeAmountForPool is greater than 1e24");
        }
    }

    function _logPositionFeesPositionFeeAmountForPoolCoverage_decreasePosition(
        uint256 positionFeeAmountForPool
    ) internal {
        if (positionFeeAmountForPool == 0) {
            fl.log("PositionFees positionFeeAmountForPool is 0");
        }
        if (positionFeeAmountForPool > 0 && positionFeeAmountForPool <= 1e6) {
            fl.log(
                "PositionFees positionFeeAmountForPool is between 0 and 1e6"
            );
        }
        if (
            positionFeeAmountForPool > 1e6 && positionFeeAmountForPool <= 1e12
        ) {
            fl.log(
                "PositionFees positionFeeAmountForPool is between 1e6 and 1e12"
            );
        }
        if (
            positionFeeAmountForPool > 1e12 && positionFeeAmountForPool <= 1e18
        ) {
            fl.log(
                "PositionFees positionFeeAmountForPool is between 1e12 and 1e18"
            );
        }
        if (
            positionFeeAmountForPool > 1e18 && positionFeeAmountForPool <= 1e24
        ) {
            fl.log(
                "PositionFees positionFeeAmountForPool is between 1e18 and 1e24"
            );
        }
        if (positionFeeAmountForPool > 1e24) {
            fl.log(
                "PositionFees positionFeeAmountForPool is greater than 1e24"
            );
        }
    }

    function _logPositionFeesPositionFeeAmountCoverage_decreasePosition(
        uint256 positionFeeAmount
    ) internal {
        if (positionFeeAmount == 0) {
            fl.log("PositionFees positionFeeAmount is 0");
        }
        if (positionFeeAmount > 0 && positionFeeAmount <= 1e6) {
            fl.log("PositionFees positionFeeAmount is between 0 and 1e6");
        }
        if (positionFeeAmount > 1e6 && positionFeeAmount <= 1e12) {
            fl.log("PositionFees positionFeeAmount is between 1e6 and 1e12");
        }
        if (positionFeeAmount > 1e12 && positionFeeAmount <= 1e18) {
            fl.log("PositionFees positionFeeAmount is between 1e12 and 1e18");
        }
        if (positionFeeAmount > 1e18 && positionFeeAmount <= 1e24) {
            fl.log("PositionFees positionFeeAmount is between 1e18 and 1e24");
        }
        if (positionFeeAmount > 1e24) {
            fl.log("PositionFees positionFeeAmount is greater than 1e24");
        }
    }

    function _logPositionFeesTotalCostAmountExcludingFundingCoverage_decreasePosition(
        uint256 totalCostAmountExcludingFunding
    ) internal {
        if (totalCostAmountExcludingFunding == 0) {
            fl.log("PositionFees totalCostAmountExcludingFunding is 0");
        }
        if (
            totalCostAmountExcludingFunding > 0 &&
            totalCostAmountExcludingFunding <= 1e6
        ) {
            fl.log(
                "PositionFees totalCostAmountExcludingFunding is between 0 and 1e6"
            );
        }
        if (
            totalCostAmountExcludingFunding > 1e6 &&
            totalCostAmountExcludingFunding <= 1e12
        ) {
            fl.log(
                "PositionFees totalCostAmountExcludingFunding is between 1e6 and 1e12"
            );
        }
        if (
            totalCostAmountExcludingFunding > 1e12 &&
            totalCostAmountExcludingFunding <= 1e18
        ) {
            fl.log(
                "PositionFees totalCostAmountExcludingFunding is between 1e12 and 1e18"
            );
        }
        if (
            totalCostAmountExcludingFunding > 1e18 &&
            totalCostAmountExcludingFunding <= 1e24
        ) {
            fl.log(
                "PositionFees totalCostAmountExcludingFunding is between 1e18 and 1e24"
            );
        }
        if (totalCostAmountExcludingFunding > 1e24) {
            fl.log(
                "PositionFees totalCostAmountExcludingFunding is greater than 1e24"
            );
        }
    }

    function _logPositionFeesTotalCostAmountCoverage_decreasePosition(
        uint256 totalCostAmount
    ) internal {
        if (totalCostAmount == 0) {
            fl.log("PositionFees totalCostAmount is 0");
        }
        if (totalCostAmount > 0 && totalCostAmount <= 1e6) {
            fl.log("PositionFees totalCostAmount is between 0 and 1e6");
        }
        if (totalCostAmount > 1e6 && totalCostAmount <= 1e12) {
            fl.log("PositionFees totalCostAmount is between 1e6 and 1e12");
        }
        if (totalCostAmount > 1e12 && totalCostAmount <= 1e18) {
            fl.log("PositionFees totalCostAmount is between 1e12 and 1e18");
        }
        if (totalCostAmount > 1e18 && totalCostAmount <= 1e24) {
            fl.log("PositionFees totalCostAmount is between 1e18 and 1e24");
        }
        if (totalCostAmount > 1e24) {
            fl.log("PositionFees totalCostAmount is greater than 1e24");
        }
    }

    function _logExecutionPriceResultPriceImpactUsdCoverage_decreasePosition(
        int256 priceImpactUsd
    ) internal {
        if (priceImpactUsd == 0) {
            fl.log("ExecutionPriceResult priceImpactUsd is 0");
        }
        if (priceImpactUsd > 0 && priceImpactUsd <= 1e6) {
            fl.log("ExecutionPriceResult priceImpactUsd is between 0 and 1e6");
        }
        if (priceImpactUsd > 1e6 && priceImpactUsd <= 1e12) {
            fl.log(
                "ExecutionPriceResult priceImpactUsd is between 1e6 and 1e12"
            );
        }
        if (priceImpactUsd > 1e12 && priceImpactUsd <= 1e18) {
            fl.log(
                "ExecutionPriceResult priceImpactUsd is between 1e12 and 1e18"
            );
        }
        if (priceImpactUsd > 1e18 && priceImpactUsd <= 1e24) {
            fl.log(
                "ExecutionPriceResult priceImpactUsd is between 1e18 and 1e24"
            );
        }
        if (priceImpactUsd > 1e24) {
            fl.log("ExecutionPriceResult priceImpactUsd is greater than 1e24");
        }
        if (priceImpactUsd < 0 && priceImpactUsd >= -1e6) {
            fl.log("ExecutionPriceResult priceImpactUsd is between 0 and -1e6");
        }
        if (priceImpactUsd < -1e6 && priceImpactUsd >= -1e12) {
            fl.log(
                "ExecutionPriceResult priceImpactUsd is between -1e6 and -1e12"
            );
        }
        if (priceImpactUsd < -1e12 && priceImpactUsd >= -1e18) {
            fl.log(
                "ExecutionPriceResult priceImpactUsd is between -1e12 and -1e18"
            );
        }
        if (priceImpactUsd < -1e18 && priceImpactUsd >= -1e24) {
            fl.log(
                "ExecutionPriceResult priceImpactUsd is between -1e18 and -1e24"
            );
        }
        if (priceImpactUsd < -1e24) {
            fl.log("ExecutionPriceResult priceImpactUsd is less than -1e24");
        }
    }
    function _logExecutionPriceResultPriceImpactDiffUsdCoverage_decreasePosition(
        uint256 priceImpactDiffUsd
    ) internal {
        if (priceImpactDiffUsd == 0) {
            fl.log("ExecutionPriceResult priceImpactDiffUsd is 0");
        }
        if (priceImpactDiffUsd > 0 && priceImpactDiffUsd <= 1e6) {
            fl.log(
                "ExecutionPriceResult priceImpactDiffUsd is between 0 and 1e6"
            );
        }
        if (priceImpactDiffUsd > 1e6 && priceImpactDiffUsd <= 1e12) {
            fl.log(
                "ExecutionPriceResult priceImpactDiffUsd is between 1e6 and 1e12"
            );
        }
        if (priceImpactDiffUsd > 1e12 && priceImpactDiffUsd <= 1e18) {
            fl.log(
                "ExecutionPriceResult priceImpactDiffUsd is between 1e12 and 1e18"
            );
        }
        if (priceImpactDiffUsd > 1e18 && priceImpactDiffUsd <= 1e24) {
            fl.log(
                "ExecutionPriceResult priceImpactDiffUsd is between 1e18 and 1e24"
            );
        }
        if (priceImpactDiffUsd > 1e24) {
            fl.log(
                "ExecutionPriceResult priceImpactDiffUsd is greater than 1e24"
            );
        }
    }
    function _logExecutionPriceResultExecutionPriceCoverage_decreasePosition(
        uint256 executionPrice
    ) internal {
        if (executionPrice == 0) {
            fl.log("ExecutionPriceResult executionPrice is 0");
        }
        if (executionPrice > 0 && executionPrice <= 1e6) {
            fl.log("ExecutionPriceResult executionPrice is between 0 and 1e6");
        }
        if (executionPrice > 1e6 && executionPrice <= 1e12) {
            fl.log(
                "ExecutionPriceResult executionPrice is between 1e6 and 1e12"
            );
        }
        if (executionPrice > 1e12 && executionPrice <= 1e18) {
            fl.log(
                "ExecutionPriceResult executionPrice is between 1e12 and 1e18"
            );
        }
        if (executionPrice > 1e18 && executionPrice <= 1e24) {
            fl.log(
                "ExecutionPriceResult executionPrice is between 1e18 and 1e24"
            );
        }
        if (executionPrice > 1e24) {
            fl.log("ExecutionPriceResult executionPrice is greater than 1e24");
        }
    }
    function _logPositionInfoBasePnlUsdCoverage_decreasePosition(
        int256 basePnlUsd
    ) internal {
        if (basePnlUsd == 0) {
            fl.log("PositionInfo basePnlUsd is 0");
        }
        if (basePnlUsd > 0 && basePnlUsd <= 1e6) {
            fl.log("PositionInfo basePnlUsd is between 0 and 1e6");
        }
        if (basePnlUsd > 1e6 && basePnlUsd <= 1e12) {
            fl.log("PositionInfo basePnlUsd is between 1e6 and 1e12");
        }
        if (basePnlUsd > 1e12 && basePnlUsd <= 1e18) {
            fl.log("PositionInfo basePnlUsd is between 1e12 and 1e18");
        }
        if (basePnlUsd > 1e18 && basePnlUsd <= 1e24) {
            fl.log("PositionInfo basePnlUsd is between 1e18 and 1e24");
        }
        if (basePnlUsd > 1e24) {
            fl.log("PositionInfo basePnlUsd is greater than 1e24");
        }
        if (basePnlUsd < 0 && basePnlUsd >= -1e6) {
            fl.log("PositionInfo basePnlUsd is between 0 and -1e6");
        }
        if (basePnlUsd < -1e6 && basePnlUsd >= -1e12) {
            fl.log("PositionInfo basePnlUsd is between -1e6 and -1e12");
        }
        if (basePnlUsd < -1e12 && basePnlUsd >= -1e18) {
            fl.log("PositionInfo basePnlUsd is between -1e12 and -1e18");
        }
        if (basePnlUsd < -1e18 && basePnlUsd >= -1e24) {
            fl.log("PositionInfo basePnlUsd is between -1e18 and -1e24");
        }
        if (basePnlUsd < -1e24) {
            fl.log("PositionInfo basePnlUsd is less than -1e24");
        }
    }
    function _logPositionInfoUncappedBasePnlUsdCoverage_decreasePosition(
        int256 uncappedBasePnlUsd
    ) internal {
        if (uncappedBasePnlUsd == 0) {
            fl.log("PositionInfo uncappedBasePnlUsd is 0");
        }
        if (uncappedBasePnlUsd > 0 && uncappedBasePnlUsd <= 1e6) {
            fl.log("PositionInfo uncappedBasePnlUsd is between 0 and 1e6");
        }
        if (uncappedBasePnlUsd > 1e6 && uncappedBasePnlUsd <= 1e12) {
            fl.log("PositionInfo uncappedBasePnlUsd is between 1e6 and 1e12");
        }
        if (uncappedBasePnlUsd > 1e12 && uncappedBasePnlUsd <= 1e18) {
            fl.log("PositionInfo uncappedBasePnlUsd is between 1e12 and 1e18");
        }
        if (uncappedBasePnlUsd > 1e18 && uncappedBasePnlUsd <= 1e24) {
            fl.log("PositionInfo uncappedBasePnlUsd is between 1e18 and 1e24");
        }
        if (uncappedBasePnlUsd > 1e24) {
            fl.log("PositionInfo uncappedBasePnlUsd is greater than 1e24");
        }
        if (uncappedBasePnlUsd < 0 && uncappedBasePnlUsd >= -1e6) {
            fl.log("PositionInfo uncappedBasePnlUsd is between 0 and -1e6");
        }
        if (uncappedBasePnlUsd < -1e6 && uncappedBasePnlUsd >= -1e12) {
            fl.log("PositionInfo uncappedBasePnlUsd is between -1e6 and -1e12");
        }
        if (uncappedBasePnlUsd < -1e12 && uncappedBasePnlUsd >= -1e18) {
            fl.log(
                "PositionInfo uncappedBasePnlUsd is between -1e12 and -1e18"
            );
        }
        if (uncappedBasePnlUsd < -1e18 && uncappedBasePnlUsd >= -1e24) {
            fl.log(
                "PositionInfo uncappedBasePnlUsd is between -1e18 and -1e24"
            );
        }
        if (uncappedBasePnlUsd < -1e24) {
            fl.log("PositionInfo uncappedBasePnlUsd is less than -1e24");
        }
    }
    function _logPositionInfoPnlAfterPriceImpactUsdCoverage_decreasePosition(
        int256 pnlAfterPriceImpactUsd
    ) internal {
        if (pnlAfterPriceImpactUsd == 0) {
            fl.log("PositionInfo pnlAfterPriceImpactUsd is 0");
        }
        if (pnlAfterPriceImpactUsd > 0 && pnlAfterPriceImpactUsd <= 1e6) {
            fl.log("PositionInfo pnlAfterPriceImpactUsd is between 0 and 1e6");
        }
        if (pnlAfterPriceImpactUsd > 1e6 && pnlAfterPriceImpactUsd <= 1e12) {
            fl.log(
                "PositionInfo pnlAfterPriceImpactUsd is between 1e6 and 1e12"
            );
        }
        if (pnlAfterPriceImpactUsd > 1e12 && pnlAfterPriceImpactUsd <= 1e18) {
            fl.log(
                "PositionInfo pnlAfterPriceImpactUsd is between 1e12 and 1e18"
            );
        }
        if (pnlAfterPriceImpactUsd > 1e18 && pnlAfterPriceImpactUsd <= 1e24) {
            fl.log(
                "PositionInfo pnlAfterPriceImpactUsd is between 1e18 and 1e24"
            );
        }
        if (pnlAfterPriceImpactUsd > 1e24) {
            fl.log("PositionInfo pnlAfterPriceImpactUsd is greater than 1e24");
        }
        if (pnlAfterPriceImpactUsd < 0 && pnlAfterPriceImpactUsd >= -1e6) {
            fl.log("PositionInfo pnlAfterPriceImpactUsd is between 0 and -1e6");
        }
        if (pnlAfterPriceImpactUsd < -1e6 && pnlAfterPriceImpactUsd >= -1e12) {
            fl.log(
                "PositionInfo pnlAfterPriceImpactUsd is between -1e6 and -1e12"
            );
        }
        if (pnlAfterPriceImpactUsd < -1e12 && pnlAfterPriceImpactUsd >= -1e18) {
            fl.log(
                "PositionInfo pnlAfterPriceImpactUsd is between -1e12 and -1e18"
            );
        }
        if (pnlAfterPriceImpactUsd < -1e18 && pnlAfterPriceImpactUsd >= -1e24) {
            fl.log(
                "PositionInfo pnlAfterPriceImpactUsd is between -1e18 and -1e24"
            );
        }
        if (pnlAfterPriceImpactUsd < -1e24) {
            fl.log("PositionInfo pnlAfterPriceImpactUsd is less than -1e24");
        }
    }
}
