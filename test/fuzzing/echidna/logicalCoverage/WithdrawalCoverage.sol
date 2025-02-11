pragma solidity ^0.8.0;

import "./withdrawalCoverage/WithdrawalCreatedCoverage.sol";
import "./withdrawalCoverage/WithdrawalCancelCoverage.sol";
import "./withdrawalCoverage/WithdrawalExecuteCoverage.sol";
import "./withdrawalCoverage/WithdrawalExecuteAtomicCoverage.sol";

contract WithdrawalCoverage is
    WithdrawalCreatedCoverage,
    WithdrawalCancelCoverage,
    WithdrawalExecuteCoverage,
    WithdrawalExecuteAtomicCoverage
{}
