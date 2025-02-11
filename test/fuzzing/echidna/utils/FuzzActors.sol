// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FunctionCalls.sol";

contract FuzzActors is FunctionCalls {
    address internal DEPLOYER;
    address internal HEVM_INITIAL_ADDRESS =
        address(0x00a329c0648769A73afAc7F9381E08FB43dBEA72);
    address internal FOUNDRY_INITIAL_ADDRESS =
        address(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496);
    address internal FOUNDRY_DEFAULT_ADDRESS =
        0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

    address internal gammaKeeper = address(0xeeefeee);

    address payable internal treasury_GammaVault1x_WETHUSDC =
        payable(address(0xea1));
    address payable internal treasury_GammaVault2x_WETHUSDC =
        payable(address(0xea2));
    address payable internal treasury_GammaVault3x_WETHUSDC =
        payable(address(0xea3));

    address payable internal treasury_GammaVault1x_WBTCUSDC =
        payable(address(0xea1));
    address payable internal treasury_GammaVault2x_WBTCUSDC =
        payable(address(0xea2));
    address payable internal treasury_GammaVault3x_WBTCUSDC =
        payable(address(0xea3));

    address internal paraswapDeployer =
        address(0xf01121e808F782d7F34E857c27dA31AD1f151b39);

    address internal USER0 = address(10101);
    address internal USER1 = address(1);
    address internal USER2 = address(2);
    address internal USER3 = address(3);
    address internal USER4 = address(4);
    address internal USER5 = address(5);
    address internal USER6 = address(6);
    address internal USER7 = address(7);
    address internal USER8 = address(8);
    address internal USER9 = address(9);
    address internal USER10 = address(10);
    address internal USER11 = address(11);
    address internal USER12 = address(12);
    address internal USER13 = address(13);

    address[] internal USERS = [
        USER0,
        USER1,
        USER2,
        USER3,
        USER4,
        USER5,
        USER6,
        USER7,
        USER8,
        USER9,
        USER10,
        USER11,
        USER12,
        USER13
    ];
}
