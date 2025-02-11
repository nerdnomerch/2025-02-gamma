// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./DepositSetup.sol";

contract DepositSpeedup is DepositSetup {
    function CreateExecuteDeposit(
        uint8 marketIndex,
        uint8 userIndex,
        uint longAmount,
        uint shortAmount,
        uint priceSeed,
        uint executionFee,
        uint8 swapPathSeed
    ) public {
        callback.cleanETHBalance(address(0));

        _createDeposit(
            marketIndex,
            userIndex,
            longAmount,
            shortAmount,
            priceSeed,
            SWAPS_ENABLED ? swapPathSeed : 7,
            executionFee,
            false
        );
        uint before_callbackBalance_GEN2 = address(callback).balance;

        (
            DepositCreated memory depositToExecute,
            DepositState memory afterDepositExecution
        ) = ExecuteDeposit(priceSeed, true); //isAtomicExec

        invariantDepositedTokensMatchSimulatedAmounts(
            depositToExecute,
            afterDepositExecution
        );
        invariantMarketTokenSupplyIncreases(depositToExecute);

        // InvariantExecutionFeeIsAlwaysCovered( //NOTE: this execution fee is checked by callback contract which is not used in GAMMA version
        //     address(0),
        //     before_callbackBalance_GEN2,
        //     address(callback).balance, //after
        //     depositToExecute.createDepositParams.executionFee
        // );
    }

    function CreateCancelDeposit(
        uint8 marketIndex,
        uint8 userIndex,
        uint longAmount,
        uint shortAmount,
        uint priceSeed,
        uint8 swapPathSeed,
        uint executionFee
    ) public {
        _createDeposit(
            marketIndex,
            userIndex,
            longAmount,
            shortAmount,
            priceSeed,
            SWAPS_ENABLED ? swapPathSeed : 7,
            executionFee,
            false
        );

        (
            DepositState memory _before,
            DepositState memory _after,
            DepositCreated memory depositCreated
        ) = CancelDeposit(priceSeed, true);

        _cancelDepositAssertions(_before, _after, depositCreated);
    }
    function CreateExecuteInitialDeposit(
        uint8 marketIndex,
        uint8 userIndex,
        uint longAmount,
        uint shortAmount,
        uint priceSeed,
        uint8 swapPathSeed,
        uint executionFee
    ) internal {
        callback.cleanETHBalance(address(0));

        _createDeposit(
            marketIndex,
            userIndex,
            longAmount,
            shortAmount,
            priceSeed,
            SWAPS_ENABLED ? swapPathSeed : 7,
            executionFee,
            true //setUp has 0 gas price, so we need to skip fee coverage invariants
        );
        uint before_callbackBalance_GEN2 = address(callback).balance;

        (
            DepositCreated memory depositToExecute,
            DepositState memory afterDepositExecution
        ) = ExecuteDeposit(priceSeed, true); //isAtomicExec

        invariantDepositedTokensMatchSimulatedAmounts(
            depositToExecute,
            afterDepositExecution
        );
        invariantMarketTokenSupplyIncreases(depositToExecute);

        // InvariantExecutionFeeIsAlwaysCovered(//NOTE: this execution fee is checked by callback contract which is not used in GAMMA version
        //     address(0),
        //     before_callbackBalance_GEN2,
        //     address(callback).balance, //after
        //     depositToExecute.createDepositParams.executionFee
        // );
    }
    function setUpDeposits(
        uint8 marketIndex,
        uint longAmount,
        uint shortAmount
    ) internal {
        CreateExecuteInitialDeposit(
            marketIndex,
            0,
            longAmount,
            shortAmount,
            5000e4,
            7,
            FIXED_EXECUTION_FEE_AMOUNT
        );
    }
}
