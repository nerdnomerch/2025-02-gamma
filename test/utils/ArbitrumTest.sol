// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {TestBase} from "forge-std/Base.sol";

contract ArbSysMock {

    function arbBlockNumber() external pure returns (uint256) {
        return 230082640;
    }
}

contract ArbitrumTest is TestBase {
    ArbSysMock arbsys;

    constructor() {
        arbsys = new ArbSysMock();
        vm.etch(address(0x0000000000000000000000000000000000000064), address(arbsys).code);
    }
}
