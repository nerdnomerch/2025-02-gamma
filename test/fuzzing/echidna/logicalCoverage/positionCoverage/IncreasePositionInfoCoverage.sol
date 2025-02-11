// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../properties/BeforeAfter.sol";

contract IncreasePositionInfoCoverage is BeforeAfter {
    //       /\_/\           ___
    //    = o_o =_______    \ \  INCREASE POSITION
    //     __^      __(  \.__) )  GET POSITION INFO
    // (@)<_____>__(_____)____/    COVERAGE

    function _checkIncreaseOrderAndGetPositionCoverage(
        Position.Props memory position
    ) internal {
        _logPositionAccountCoverage(position.addresses.account);
        _logPositionMarketCoverage(position.addresses.market);
        _logPositionCollateralTokenCoverage(position.addresses.collateralToken);
        _logPositionSizeInUsdCoverage(position.numbers.sizeInUsd);
        _logPositionSizeInTokensCoverage(position.numbers.sizeInTokens);
        _logPositionCollateralAmountCoverage(position.numbers.collateralAmount);
        _logPositionBorrowingFactorCoverage(position.numbers.borrowingFactor);
        _logPositionFundingFeeAmountPerSizeCoverage(
            position.numbers.fundingFeeAmountPerSize
        );
        _logPositionLongTokenClaimableFundingAmountPerSizeCoverage(
            position.numbers.longTokenClaimableFundingAmountPerSize
        );
        _logPositionShortTokenClaimableFundingAmountPerSizeCoverage(
            position.numbers.shortTokenClaimableFundingAmountPerSize
        );
        // _logPositionIncreasedAtBlockCoverage(position.numbers.increasedAtBlock);
        // _logPositionDecreasedAtBlockCoverage(position.numbers.decreasedAtBlock);
        _logPositionIncreasedAtTimeCoverage(position.numbers.increasedAtTime);
        _logPositionDecreasedAtTimeCoverage(position.numbers.decreasedAtTime);
        _logPositionIsLongCoverage(position.flags.isLong);
    }

    function _checkIncreaseOrderAndGetPositionInfoCoverage(
        ReaderPositionUtils.PositionInfo memory positionInfo
    ) internal {
        // Position.Props logged above
        _logPositionFeesReferralCodeCoverage(
            positionInfo.fees.referral.referralCode
        );
        _logPositionFeesAffiliateCoverage(positionInfo.fees.referral.affiliate);
        _logPositionFeesTraderCoverage(positionInfo.fees.referral.trader);
        _logPositionFeesTotalRebateFactorCoverage(
            positionInfo.fees.referral.totalRebateFactor
        );
        _logPositionFeesTraderDiscountFactorCoverage(
            positionInfo.fees.referral.traderDiscountFactor
        );
        _logPositionFeesTotalRebateAmountCoverage(
            positionInfo.fees.referral.totalRebateAmount
        );
        _logPositionFeesTraderDiscountAmountCoverage(
            positionInfo.fees.referral.traderDiscountAmount
        );
        _logPositionFeesAffiliateRewardAmountCoverage(
            positionInfo.fees.referral.affiliateRewardAmount
        );
        _logPositionFeesFundingFeeAmountCoverage(
            positionInfo.fees.funding.fundingFeeAmount
        );
        _logPositionFeesClaimableLongTokenAmountCoverage(
            positionInfo.fees.funding.claimableLongTokenAmount
        );
        _logPositionFeesClaimableShortTokenAmountCoverage(
            positionInfo.fees.funding.claimableShortTokenAmount
        );
        _logPositionFeesLatestFundingFeeAmountPerSizeCoverage(
            positionInfo.fees.funding.latestFundingFeeAmountPerSize
        );
        _logPositionFeesLatestLongTokenClaimableFundingAmountPerSizeCoverage(
            positionInfo
                .fees
                .funding
                .latestLongTokenClaimableFundingAmountPerSize
        );
        _logPositionFeesLatestShortTokenClaimableFundingAmountPerSizeCoverage(
            positionInfo
                .fees
                .funding
                .latestShortTokenClaimableFundingAmountPerSize
        );
        _logPositionFeesBorrowingFeeUsdCoverage(
            positionInfo.fees.borrowing.borrowingFeeUsd
        );
        _logPositionFeesBorrowingFeeAmountCoverage(
            positionInfo.fees.borrowing.borrowingFeeAmount
        );
        _logPositionFeesBorrowingFeeReceiverFactorCoverage(
            positionInfo.fees.borrowing.borrowingFeeReceiverFactor
        );
        _logPositionFeesBorrowingFeeAmountForFeeReceiverCoverage(
            positionInfo.fees.borrowing.borrowingFeeAmountForFeeReceiver
        );
        _logPositionFeesUiFeeReceiverCoverage(
            positionInfo.fees.ui.uiFeeReceiver
        );
        _logPositionFeesUiFeeReceiverFactorCoverage(
            positionInfo.fees.ui.uiFeeReceiverFactor
        );
        _logPositionFeesUiFeeAmountCoverage(positionInfo.fees.ui.uiFeeAmount);
        _logPositionFeesCollateralTokenPriceCoverage(
            positionInfo.fees.collateralTokenPrice.max
        );
        _logPositionFeesPositionFeeFactorCoverage(
            positionInfo.fees.positionFeeFactor
        );
        _logPositionFeesProtocolFeeAmountCoverage(
            positionInfo.fees.protocolFeeAmount
        );
        _logPositionFeesPositionFeeReceiverFactorCoverage(
            positionInfo.fees.positionFeeReceiverFactor
        );
        _logPositionFeesFeeReceiverAmountCoverage(
            positionInfo.fees.feeReceiverAmount
        );
        _logPositionFeesFeeAmountForPoolCoverage(
            positionInfo.fees.feeAmountForPool
        );
        _logPositionFeesPositionFeeAmountForPoolCoverage(
            positionInfo.fees.positionFeeAmountForPool
        );
        _logPositionFeesPositionFeeAmountCoverage(
            positionInfo.fees.positionFeeAmount
        );
        _logPositionFeesTotalCostAmountExcludingFundingCoverage(
            positionInfo.fees.totalCostAmountExcludingFunding
        );
        _logPositionFeesTotalCostAmountCoverage(
            positionInfo.fees.totalCostAmount
        );

        // ExecutionPriceResult
        _logExecutionPriceResultPriceImpactUsdCoverage(
            positionInfo.executionPriceResult.priceImpactUsd
        );
        _logExecutionPriceResultPriceImpactDiffUsdCoverage(
            positionInfo.executionPriceResult.priceImpactDiffUsd
        );
        _logExecutionPriceResultExecutionPriceCoverage(
            positionInfo.executionPriceResult.executionPrice
        );

        _logPositionInfoBasePnlUsdCoverage(positionInfo.basePnlUsd);
        _logPositionInfoUncappedBasePnlUsdCoverage(
            positionInfo.uncappedBasePnlUsd
        );
        _logPositionInfoPnlAfterPriceImpactUsdCoverage(
            positionInfo.pnlAfterPriceImpactUsd
        );
    }

    function _logPositionAccountCoverage(address account) internal {
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
    function _logPositionMarketCoverage(address market) internal {
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

    function _logPositionCollateralTokenCoverage(
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

    function _logPositionSizeInUsdCoverage(uint256 sizeInUsd) internal {
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

    function _logPositionSizeInTokensCoverage(uint256 sizeInTokens) internal {
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

    function _logPositionCollateralAmountCoverage(
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

    function _logPositionBorrowingFactorCoverage(
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

    function _logPositionFundingFeeAmountPerSizeCoverage(
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

    function _logPositionLongTokenClaimableFundingAmountPerSizeCoverage(
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

    function _logPositionShortTokenClaimableFundingAmountPerSizeCoverage(
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

    function _logPositionIncreasedAtBlockCoverage(
        uint256 increasedAtBlock
    ) internal {
        if (increasedAtBlock == 0) {
            fl.log("Position increasedAtBlock is 0");
        } else {
            fl.log("Position increasedAtBlock is non-zero");
        }
    }

    function _logPositionDecreasedAtBlockCoverage(
        uint256 decreasedAtBlock
    ) internal {
        if (decreasedAtBlock == 0) {
            fl.log("Position decreasedAtBlock is 0");
        } else {
            fl.log("Position decreasedAtBlock is non-zero");
        }
    }

    function _logPositionIncreasedAtTimeCoverage(
        uint256 increasedAtTime
    ) internal {
        if (increasedAtTime == 0) {
            fl.log("Position increasedAtTime is 0");
        } else {
            fl.log("Position increasedAtTime is non-zero");
        }
    }

    function _logPositionDecreasedAtTimeCoverage(
        uint256 decreasedAtTime
    ) internal {
        if (decreasedAtTime == 0) {
            fl.log("Position decreasedAtTime is 0");
        } else {
            fl.log("Position decreasedAtTime is non-zero");
        }
    }

    function _logPositionIsLongCoverage(bool isLong) internal {
        if (isLong) {
            fl.log("Position isLong is true");
        } else {
            fl.log("Position isLong is false");
        }
    }

    function _logPositionFeesReferralCodeCoverage(
        bytes32 referralCode
    ) internal {
        if (referralCode == bytes32(0)) {
            fl.log("PositionFees referralCode is empty");
        } else {
            fl.log("PositionFees referralCode is non-empty");
        }
    }

    function _logPositionFeesAffiliateCoverage(address affiliate) internal {
        if (affiliate == address(0)) {
            fl.log("PositionFees affiliate is address(0)");
        } else {
            fl.log("PositionFees affiliate is non-zero address");
        }
    }

    function _logPositionFeesTraderCoverage(address trader) internal {
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

    function _logPositionFeesTotalRebateFactorCoverage(
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

    function _logPositionFeesTraderDiscountFactorCoverage(
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

    function _logPositionFeesTotalRebateAmountCoverage(
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

    function _logPositionFeesTraderDiscountAmountCoverage(
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

    function _logPositionFeesAffiliateRewardAmountCoverage(
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

    function _logPositionFeesFundingFeeAmountCoverage(
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

    function _logPositionFeesClaimableLongTokenAmountCoverage(
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

    function _logPositionFeesClaimableShortTokenAmountCoverage(
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

    function _logPositionFeesLatestFundingFeeAmountPerSizeCoverage(
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

    function _logPositionFeesLatestLongTokenClaimableFundingAmountPerSizeCoverage(
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

    function _logPositionFeesLatestShortTokenClaimableFundingAmountPerSizeCoverage(
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

    function _logPositionFeesBorrowingFeeUsdCoverage(
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

    function _logPositionFeesBorrowingFeeAmountCoverage(
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

    function _logPositionFeesBorrowingFeeReceiverFactorCoverage(
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

    function _logPositionFeesBorrowingFeeAmountForFeeReceiverCoverage(
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

    function _logPositionFeesUiFeeReceiverCoverage(
        address uiFeeReceiver
    ) internal {
        if (uiFeeReceiver == address(0)) {
            fl.log("PositionFees uiFeeReceiver is address(0)");
        } else {
            fl.log("PositionFees uiFeeReceiver is non-zero address");
        }
    }

    function _logPositionFeesUiFeeReceiverFactorCoverage(
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

    function _logPositionFeesUiFeeAmountCoverage(uint256 uiFeeAmount) internal {
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

    function _logPositionFeesCollateralTokenPriceCoverage(
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

    function _logPositionFeesPositionFeeFactorCoverage(
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

    function _logPositionFeesProtocolFeeAmountCoverage(
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

    function _logPositionFeesPositionFeeReceiverFactorCoverage(
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

    function _logPositionFeesFeeReceiverAmountCoverage(
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

    function _logPositionFeesFeeAmountForPoolCoverage(
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

    function _logPositionFeesPositionFeeAmountForPoolCoverage(
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

    function _logPositionFeesPositionFeeAmountCoverage(
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

    function _logPositionFeesTotalCostAmountExcludingFundingCoverage(
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

    function _logPositionFeesTotalCostAmountCoverage(
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

    function _logExecutionPriceResultPriceImpactUsdCoverage(
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
    function _logExecutionPriceResultPriceImpactDiffUsdCoverage(
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
    function _logExecutionPriceResultExecutionPriceCoverage(
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
    function _logPositionInfoBasePnlUsdCoverage(int256 basePnlUsd) internal {
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
    function _logPositionInfoUncappedBasePnlUsdCoverage(
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
    function _logPositionInfoPnlAfterPriceImpactUsdCoverage(
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
