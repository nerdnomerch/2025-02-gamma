// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./WithdrawSetup.sol";

contract WithdrawSpeedup is WithdrawSetup {
    function CreateCancelWithdrawal(
        uint8 userIndex,
        uint8 marketIndex,
        uint withdrawalAmountSeed
    ) public {
        CreateWithdrawal(userIndex, marketIndex, withdrawalAmountSeed);
        (
            WithdrawalState memory _before,
            WithdrawalState memory _after,
            WithdrawalCreated memory withdrawalToCancel
        ) = CancelWithdrawal(withdrawalAmountSeed, true);

        _cancelWithdrawalAssertions(_before, _after, withdrawalToCancel);
    }
}
