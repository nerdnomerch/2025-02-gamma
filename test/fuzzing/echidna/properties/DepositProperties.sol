// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../logicalCoverage/DepositCoverage.sol";

contract DepositProperties is DepositCoverage {
    function invariantDepositedTokensMatchSimulatedAmounts(
        DepositCreated memory depositCreated,
        DepositState memory _after
    ) internal {
        uint actualDepositedAmount = _after.userBalanceMarket -
            depositCreated.beforeDepositExec.userBalanceMarket;

        eqPercentageDiff(
            depositCreated.beforeDepositExec.simulateDepositAmountOut,
            actualDepositedAmount,
            15e27, //eqPercentageDiff has 1e30 precision
            "DEP-1 Deposited market token amount should be equal amount after simulation."
        );
    }
    function invariantMarketTokenSupplyIncreases(DepositCreated memory depositCreated) internal {
        fl.gt(
            ERC20(depositCreated.createDepositParams.market).totalSupply(),
            depositCreated.beforeDepositExec.marketTotalSupply,
            "DEP-2 Market tokens total supply should increase"
        );
    }

    function _cancelDepositAssertions(
        DepositState memory _before,
        DepositState memory _after,
        DepositCreated memory depositCreated
    ) internal {
        uint gasFeePaidForExecution = FIXED_EXECUTION_FEE_AMOUNT - address(callback).balance;

        Market.Props memory market = MarketStoreUtils.get(
            dataStore,
            depositCreated.createDepositParams.market
        );

        require(
            market.longToken != market.shortToken,
            "Assertions are not suitable for homogenic markets"
        );

        fl.eq(
            _before.userBalanceMarket,
            _after.userBalanceMarket,
            "CNCL-DEP-01 User market token amounts should stay unchanged"
        );

        if (depositCreated.depositorParams.longAmount > 0) {
            fl.lte(
                _after.userBalanceLong,
                _before.userBalanceLong +
                    depositCreated.depositorParams.longAmount +
                    gasFeePaidForExecution,
                "CNCL-DEP-02 User long token amounts after cancel should be less or equal balance before plus deposited amount"
            );

            eqPercentageDiff(
                _after.userBalanceLong,
                _before.userBalanceLong + depositCreated.depositorParams.longAmount,
                1e27, //dust
                "CNCL-DEP-03 User long token amounts should stay unchanged"
            );

            eqPercentageDiff(
                _before.vaultBalanceLong -
                    depositCreated.depositorParams.longAmount -
                    (market.longToken == address(WETH) ? FIXED_EXECUTION_FEE_AMOUNT : 0),
                //before cancel tokens are in the vault
                _after.vaultBalanceLong,
                0, //exact eq
                "CNCL-DEP-04 Vault long token amounts should stay unchanged"
            );
        }

        if (depositCreated.depositorParams.shortAmount > 0) {
            fl.lte(
                _after.userBalanceShort,
                _before.userBalanceShort + depositCreated.depositorParams.shortAmount,
                "CNCL-DEP-05 User short token amounts after cancel should be less or equal balance before plus deposited amount"
            );

            eqPercentageDiff(
                _after.userBalanceShort,
                _before.userBalanceShort + depositCreated.depositorParams.shortAmount,
                1e27, //dust
                "CNCL-DEP-06 User short token amounts should stay unchanged"
            );

            eqPercentageDiff(
                _before.vaultBalanceShort - depositCreated.depositorParams.shortAmount,
                _after.vaultBalanceShort,
                1e27,
                "CNCL-DEP-07 Vault short token amounts should stay unchanged"
            );
        }
    }
}
