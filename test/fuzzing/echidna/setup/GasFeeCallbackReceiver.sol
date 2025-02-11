// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;
import "fuzzlib/FuzzBase.sol";

import "../../contracts/event/EventUtils.sol";
import "../../contracts/deposit/Deposit.sol";
import "../../contracts/withdrawal/Withdrawal.sol";
import "../../contracts/shift/Shift.sol";
import "../../contracts/order/Order.sol";

contract GasFeeCallbackReceiver is FuzzBase {
    function refundExecutionFee(
        bytes32 key,
        EventUtils.EventLogData memory eventData
    ) public payable {}

    function afterDepositExecution(
        bytes32 key,
        Deposit.Props memory deposit,
        EventUtils.EventLogData memory eventData
    ) public payable {}

    function afterDepositCancellation(
        bytes32 key,
        Deposit.Props memory deposit,
        EventUtils.EventLogData memory eventData
    ) public payable {}

    function afterWithdrawalExecution(
        bytes32 key,
        Withdrawal.Props memory withdrawal,
        EventUtils.EventLogData memory eventData
    ) public payable {}

    function afterWithdrawalCancellation(
        bytes32 key,
        Withdrawal.Props memory withdrawal,
        EventUtils.EventLogData memory eventData
    ) public payable {}

    function afterShiftExecution(
        bytes32 key,
        Shift.Props memory shift,
        EventUtils.EventLogData memory eventData
    ) public payable {}

    function afterShiftCancellation(
        bytes32 key,
        Shift.Props memory shift,
        EventUtils.EventLogData memory eventData
    ) public payable {}

    function afterOrderExecution(
        bytes32 key,
        Order.Props memory order,
        EventUtils.EventLogData memory eventData
    ) public payable {}

    function afterOrderCancellation(
        bytes32 key,
        Order.Props memory order,
        EventUtils.EventLogData memory eventData
    ) public payable {}

    function afterOrderFrozen(
        bytes32 key,
        Order.Props memory order,
        EventUtils.EventLogData memory eventData
    ) public payable {}

    function cleanETHBalance(address user) public {
        address(user).call{value: address(this).balance}("");
    }

    receive() external payable {}
}
