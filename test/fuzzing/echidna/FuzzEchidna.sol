// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./helpers/GMXSetup.sol";

contract FuzzEchidna is GMXSetup {
    constructor() payable {
        SetUpGMX();
    }

    receive() external payable {}
}
