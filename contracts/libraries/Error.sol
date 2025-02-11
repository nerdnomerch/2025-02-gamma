// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

library Error {
  error ZeroValue();
  error FlowInProgress();
  error NotAKeeper();
  error GmxLock();
  error InsufficientAmount();
  error ExceedMaxDepositCap();
  error Paused();
  error Locked();
  error InvalidUser();
  error LowerThanMinEth();
  error NoAction();
  error InvalidData();
  error InvalidCall();
}
