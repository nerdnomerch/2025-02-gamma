// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./PropertiesSetup.sol";

contract DonationSetup is PropertiesSetup {
    //turned off
    function Donate(
        uint seed,
        uint8 userSeed,
        address addressFrom,
        uint longAmount,
        uint shortAmount
    ) internal {
        uint userIndex = seed % USERS.length;
        addressFrom = _getRandomUser(userSeed);

        address addressTo;
        uint randomAddress = seed % 10;
        if (randomAddress == 0) {
            addressTo = address(depositVault);
        } else if (randomAddress == 1) {
            addressTo = address(orderVault);
        } else if (randomAddress == 2) {
            addressTo = address(shiftVault);
        } else if (randomAddress == 3) {
            addressTo = address(withdrawalVault);
        } else if (randomAddress == 4) {
            addressTo = market_0_WETH_USDC;
        } else if (randomAddress == 6) {
            addressTo = market_WBTC_WBTC_USDC;
        } else if (randomAddress == 8) {
            addressTo = market_WETH_WETH_USDC;
        } else {
            addressTo = market_WETH_WETH_USDT;
        }

        (address longToken, address shortToken) = _getRandomTokenPair(
            seed,
            addressTo
        );

        bool isWeth = longToken == address(WETH) || shortToken == address(WETH);

        (uint longAmountClamped, uint shortAmountClamped) = _getTokenAmounts(
            longAmount,
            shortAmount,
            longToken,
            shortToken,
            addressFrom
        );

        _mintAndSendTokensTo(
            addressFrom,
            addressTo,
            longAmountClamped,
            shortAmountClamped,
            longToken,
            shortToken,
            0,
            isWeth
        );
    }
}
