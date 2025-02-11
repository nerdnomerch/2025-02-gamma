// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../logicalCoverage/ShiftCoverage.sol";

contract ShiftProperties is ShiftCoverage {
    function invariantFromAndToMarketTokenBalancesUpdated(
        ShiftState memory _after,
        ShiftState memory _before
    ) internal {
        require(
            _after.createShiftParams.fromMarket != _after.createShiftParams.toMarket,
            "Invalid invariant for the same market shifting"
        );
        address marketFrom = _after.createShiftParams.fromMarket;

        uint marketFromTokenBalanceAfterShift = ERC20(marketFrom).balanceOf(_after.user);

        TokenPrices memory tokenPrices = _after.tokenPrices;

        address marketTo = _after.createShiftParams.toMarket;
        Market.Props memory marketToProps = MarketStoreUtils.get(dataStore, marketTo);

        /**
     __
    ( o>
    /// \  @coverage:limiter 
    \V_/_  this is literally the second deposit
    

    */

        uint simulateDepositAmountOut = ReaderDepositUtils.getDepositAmountOut(
            dataStore,
            marketToProps,
            _getMarketPrices(marketTo, tokenPrices),
            _after.marketDataBefore.simulateLongTokenAmountWithdrawal,
            _after.marketDataBefore.simulateShortTokenAmountWithdrawal,
            address(0),
            ISwapPricingUtils.SwapPricingType.Shift, // TwoStep, Shift, Atomic
            true //includeVirtualInventoryImpact, removed in 7602ff95489fb032e4eeb59d81125d5f3d93e976
        );

        fl.lt(
            marketFromTokenBalanceAfterShift,
            _before.marketFromBalance,
            "SHFT-1 User balance of `from` GM tokens decreases upon shift"
        );
        uint marketToTokenBalanceAfterShift = ERC20(marketTo).balanceOf(_after.user);

        eqPercentageDiff(
            marketToTokenBalanceAfterShift, //15
            _before.marketToBalance + simulateDepositAmountOut, //30
            1e28,
            "SHFT-2 User balance of to market GM += shift.marketTokenAmount()"
        );

        fl.eq(
            marketFromTokenBalanceAfterShift,
            _before.marketFromBalance - _after.marketTokenAmount,
            "SHFT-3 User balance of from market GM -= shift.marketTokenAmount()"
        );
    }
    function invariantClaimableFeesUnchangedAfterShift(
        ShiftState memory _after,
        ShiftState memory _before
    ) internal {
        address marketFrom = _after.createShiftParams.fromMarket;
        Market.Props memory marketFromProps = MarketStoreUtils.get(dataStore, marketFrom);

        uint longTokenMarketFeeAmountAfterMarketFrom = _getClaimableFeeAmount(
            marketFrom,
            marketFromProps.longToken
        );
        uint shortTokenMarketFeeAmountAfterMarketFrom = _getClaimableFeeAmount(
            marketFrom,
            marketFromProps.shortToken
        );

        fl.eq(
            _before.longTokenMarketFeeAmountMarketFrom,
            longTokenMarketFeeAmountAfterMarketFrom,
            "SHFT-4 Claimable fees for long token do not change upon shift."
        );
        fl.eq(
            _before.shortTokenMarketFeeAmountMarketFrom,
            shortTokenMarketFeeAmountAfterMarketFrom,
            "SHFT-5 Claimable fees for short token do not change upon shift."
        );
    }

    function invariantFromMarketPoolAmountsDecrease(
        ShiftState memory _after,
        ShiftState memory _before
    ) internal {
        require(
            _after.createShiftParams.fromMarket != _after.createShiftParams.toMarket,
            "Invalid assertion for the same market shifting"
        );

        address marketFrom = _after.createShiftParams.fromMarket;

        Market.Props memory marketFromProps = MarketStoreUtils.get(dataStore, marketFrom);

        uint longTokenPoolAmountAfterMarketFrom = _getPoolAmount(
            dataStore,
            marketFromProps,
            marketFromProps.longToken
        );

        uint shortTokenPoolAmountAfterMarketFrom = _getPoolAmount(
            dataStore,
            marketFromProps,
            marketFromProps.shortToken
        );

        if (_after.marketDataBefore.simulateLongTokenAmountWithdrawal != 0) {
            fl.lt(
                longTokenPoolAmountAfterMarketFrom,
                _before.longTokenPoolAmountMarketFrom,
                "SHFT-6 Long token pool Amount For `from` market should decrease"
            );
        }
        if (_after.marketDataBefore.simulateShortTokenAmountWithdrawal != 0) {
            fl.lt(
                shortTokenPoolAmountAfterMarketFrom,
                _before.shortTokenPoolAmountMarketFrom,
                "SHFT-7 Short token Amount For `from` market should decrease"
            );
        }
    }

    function invariantToMarketPoolAmountsIncrease(
        ShiftState memory _after,
        ShiftState memory _before
    ) internal {
        require(
            _after.createShiftParams.fromMarket != _after.createShiftParams.toMarket,
            "Invalid assertion for the same market shifting"
        );
        address marketTo = _after.createShiftParams.toMarket;

        Market.Props memory marketToProps = MarketStoreUtils.get(dataStore, marketTo);

        uint toMarketLongTokenPoolAmount = _getPoolAmount(
            dataStore,
            marketToProps,
            marketToProps.longToken
        );
        uint toMarketShortTokenPoolAmount = _getPoolAmount(
            dataStore,
            marketToProps,
            marketToProps.shortToken
        );
        if (_after.marketDataBefore.simulateLongTokenAmountWithdrawal != 0) {
            fl.gt(
                toMarketLongTokenPoolAmount,
                _before.longTokenPoolAmountMarketTo,
                "SHFT-8 Pool Amount For `to` market long token should increase"
            );
        }

        if (_after.marketDataBefore.simulateShortTokenAmountWithdrawal != 0) {
            fl.gt(
                toMarketShortTokenPoolAmount,
                _before.shortTokenPoolAmountMarketTo,
                "SHFT-9 Pool Amount For `to` market short token should increase"
            );
        }
    }

    function invariantMarketTokenValuesStaySame(ShiftState memory _after) internal {
        int defaultPriceForMarketToken = 1e30;

        if (_after.marketDataBefore.marketTokenPriceTo != defaultPriceForMarketToken) {
            eqPercentageDiff(
                uint(_after.marketDataBefore.marketTokenPriceFrom),
                uint(_after.marketDataAfter.marketTokenPriceFrom),
                1e26,
                "SHFT-10 Market token  (GM)  value for `from` market stays the same after shift execution."
            );

            eqPercentageDiff(
                uint(_after.marketDataBefore.marketTokenPriceTo),
                uint(_after.marketDataAfter.marketTokenPriceTo),
                1e26,
                "SHFT-11 Market token  (GM)  value for `to` market stays the same after shift execution."
            );
        }
    }

    function _cancelShiftAssertions(
        ShiftState memory _before,
        ShiftState memory _after,
        ShiftCreated memory shiftToCancel
    ) internal {
        eqPercentageDiff(
            _after.marketFromBalance,
            _before.marketFromBalance + shiftToCancel.marketTokenAmount,
            0,
            "CNCL-SHFT-01 Market from received amount should be less or equal than before"
        );
        fl.eq(
            _after.marketToBalance,
            _before.marketToBalance,
            "CNCL-SHFT-02 Market to balance should stay unchanged"
        );
    }
}
