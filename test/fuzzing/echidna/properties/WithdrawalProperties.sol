// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../logicalCoverage/WithdrawalCoverage.sol";

contract WithdrawalProperties is WithdrawalCoverage {
    struct Cache {
        uint256 userDepositAmount;
        uint256 vaultValueBefore;
        uint256 vaultValueAfter;
        uint256 userBalanceBefore;
        uint256 userBalanceAfter;
        uint256 withdrawnAmount;
        uint256 depositedAmount;
        uint256 userShareBefore;
        uint256 totalWithdrawn;
        uint256 totalFeesBefore;
        uint256 totalFeesAfter;
        uint256 userFairShareOfFees;
        uint256 userActualFees;
        uint256 treasuryBalanceBefore;
        uint256 treasuryBalanceAfter;
        uint256 treasuryFees;
    }

    function _invariant_GAMMA_01(
        uint8 userSeed,
        uint8 vaultSeed,
        uint initialDepositAmount
    ) internal {
        Cache memory cache;

        address user = _getRandomUser(userSeed);
        (address vault, , , ) = _gamma_getVault(vaultSeed);

        cache.userBalanceBefore = states[0]
            .vaultInfos[vault]
            .userStates[user]
            .USDCBalance;
        cache.userBalanceAfter = states[1]
            .vaultInfos[vault]
            .userStates[user]
            .USDCBalance;

        cache.withdrawnAmount =
            cache.userBalanceAfter -
            cache.userBalanceBefore;

        cache.treasuryBalanceBefore = states[0]
            .vaultInfos[vault]
            .treasuryBalance;
        cache.treasuryBalanceAfter = states[1]
            .vaultInfos[vault]
            .treasuryBalance;
        cache.treasuryFees =
            cache.treasuryBalanceAfter -
            cache.treasuryBalanceBefore;

        cache.withdrawnAmount = cache.withdrawnAmount + cache.treasuryFees; //NOTE: we are taking fees into calculation for a fair share

        cache.depositedAmount = states[0].vaultInfos[vault].totalAmount;

        cache.userDepositAmount = initialDepositAmount;

        cache.userShareBefore =
            (cache.userDepositAmount * 1e30) /
            cache.depositedAmount;

        cache.totalFeesBefore = states[0].vaultInfos[vault].totalFees;
        cache.totalFeesAfter = states[1].vaultInfos[vault].totalFees;

        if (cache.totalFeesBefore > 0 && cache.totalFeesAfter == 0) {
            cache.userFairShareOfFees =
                (cache.totalFeesBefore * cache.userShareBefore) /
                1e30;

            cache.userActualFees =
                cache.withdrawnAmount -
                cache.userDepositAmount;

            eqPercentageDiff(
                uint256(cache.userFairShareOfFees),
                uint256(cache.userActualFees),
                1e25, //super small tolerance for precision
                "GAMMA-1"
            );
        }
    }

    function _invariant_GAMMA_07(
        address vault,
        uint depositTimestamp
    ) internal {
        fl.gte(
            block.timestamp + PerpetualVault(vault).lockTime() + 1,
            depositTimestamp,
            "GAMMA-7"
        );
    }

    function invariantWithdrawnTokensMatchSimulatedAmounts(
        WithdrawalState memory _before,
        WithdrawalState memory _after,
        WithdrawalCreated memory withdrawalCreated
    ) internal {
        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            withdrawalCreated.withdrawalParams.market
        );
        if (marketProps.longToken != marketProps.shortToken) {
            eqPercentageDiff(
                _before.longTokenBalanceUser +
                    _before.simulateLongTokenAmountWithdrawal,
                _after.longTokenBalanceUser,
                1e27,
                "WITHD-1 Withdrawn long token amount should be equal amount after simulation."
            );

            eqPercentageDiff(
                _before.shortTokenBalanceUser +
                    _before.simulateShortTokenAmountWithdrawal,
                _after.shortTokenBalanceUser,
                1e27,
                "WITHD-2 Withdrawn short token amount should be equal amount after simulation."
            );
        }
    }

    function invariantMarketTokenSupplyDecreases(
        WithdrawalState memory _before,
        WithdrawalState memory _after
    ) internal {
        fl.lt(
            _after.marketTokenTotalSupply,
            _before.marketTokenTotalSupply,
            "WITH-3 Market tokens total supply should decrease"
        );
    }
    function _cancelWithdrawalAssertions(
        WithdrawalState memory _before,
        WithdrawalState memory _after,
        WithdrawalCreated memory withdrawalToCancel
    ) internal {
        eqPercentageDiff(
            _after.userBalance,
            _before.userBalance + withdrawalToCancel.amount,
            1e27,
            "CNCL-WITH-1 User should receive market tokens back after cancelling withdrawal"
        );
        fl.eq(
            _after.marketTokenTotalSupply,
            _before.marketTokenTotalSupply,
            "CNCL-WITH-2 Market tokens total supply should stay the same"
        );

        eqPercentageDiff(
            _after.vaultBalance,
            _before.vaultBalance - withdrawalToCancel.amount,
            1e27,
            "CNCL-WITH-3 Vault should refund market tokens. "
        );
    }
}
