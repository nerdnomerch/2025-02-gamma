// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./shiftCoverage/ShiftCreatedCoverage.sol";
import "./shiftCoverage/ShiftCancelCoverage.sol";
import "./shiftCoverage/ShiftExecutedCoverage.sol";

contract ShiftCoverage is ShiftCreatedCoverage, ShiftCancelCoverage, ShiftExecutedCoverage {}
