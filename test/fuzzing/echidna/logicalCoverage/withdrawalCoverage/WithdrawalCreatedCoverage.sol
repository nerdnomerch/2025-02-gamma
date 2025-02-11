// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../properties/BeforeAfter.sol";

contract WithdrawalCreatedCoverage is BeforeAfter {
    //       /\_/\           ___
    //    = o_o =_______    \ \  CREATE WITHDRAWAL COVERAGE
    //     __^      __(  \.__) )
    // (@)<_____>__(_____)____/

    function _checkCreateWithdrawalCoverage(
        Withdrawal.Props memory withdrawalProps
    ) internal {
        _logWithdrawalAccountCoverage(withdrawalProps.addresses.account);
        _logWithdrawalReceiverCoverage(withdrawalProps.addresses.receiver);
        _logWithdrawalCallbackContractCoverage(
            withdrawalProps.addresses.callbackContract
        );
        _logWithdrawalUiFeeReceiverCoverage(
            withdrawalProps.addresses.uiFeeReceiver
        );
        _logWithdrawalMarketCoverage(withdrawalProps.addresses.market);
        _logWithdrawalLongTokenSwapPathCoverage(
            withdrawalProps.addresses.longTokenSwapPath
        );
        _logWithdrawalShortTokenSwapPathCoverage(
            withdrawalProps.addresses.shortTokenSwapPath
        );
        _logWithdrawalMarketTokenAmountCoverage(
            withdrawalProps.numbers.marketTokenAmount
        );
        _logWithdrawalMinLongTokenAmountCoverage(
            withdrawalProps.numbers.minLongTokenAmount
        );
        _logWithdrawalMinShortTokenAmountCoverage(
            withdrawalProps.numbers.minShortTokenAmount
        );
        // _logWithdrawalUpdatedAtBlockCoverage(
        //     withdrawalProps.numbers.updatedAtBlock
        // );
        _logWithdrawalUpdatedAtTimeCoverage(
            withdrawalProps.numbers.updatedAtTime
        );
        _logWithdrawalExecutionFeeCoverage(
            withdrawalProps.numbers.executionFee
        );
        _logWithdrawalCallbackGasLimitCoverage(
            withdrawalProps.numbers.callbackGasLimit
        );
        _logWithdrawalShouldUnwrapNativeTokenCoverage(
            withdrawalProps.flags.shouldUnwrapNativeToken
        );
    }

    function _logWithdrawalAccountCoverage(address account) internal {
        if (account == USER0) {
            fl.log("Withdrawal account USER0 hit");
        }
        if (account == USER1) {
            fl.log("Withdrawal account USER1 hit");
        }
        if (account == USER2) {
            fl.log("Withdrawal account USER2 hit");
        }
        if (account == USER3) {
            fl.log("Withdrawal account USER3 hit");
        }
        if (account == USER4) {
            fl.log("Withdrawal account USER4 hit");
        }
        if (account == USER5) {
            fl.log("Withdrawal account USER5 hit");
        }
        if (account == USER6) {
            fl.log("Withdrawal account USER6 hit");
        }
        if (account == USER7) {
            fl.log("Withdrawal account USER7 hit");
        }
        if (account == USER8) {
            fl.log("Withdrawal account USER8 hit");
        }
        if (account == USER9) {
            fl.log("Withdrawal account USER9 hit");
        }
        if (account == USER10) {
            fl.log("Withdrawal account USER10 hit");
        }
        if (account == USER11) {
            fl.log("Withdrawal account USER11 hit");
        }
        if (account == USER12) {
            fl.log("Withdrawal account USER12 hit");
        }
        if (account == USER13) {
            fl.log("Withdrawal account USER13 hit");
        }
    }

    function _logWithdrawalReceiverCoverage(address receiver) internal {
        if (receiver == USER0) {
            fl.log("Withdrawal receiver USER0 hit");
        }
        if (receiver == USER1) {
            fl.log("Withdrawal receiver USER1 hit");
        }
        if (receiver == USER2) {
            fl.log("Withdrawal receiver USER2 hit");
        }
        if (receiver == USER3) {
            fl.log("Withdrawal receiver USER3 hit");
        }
        if (receiver == USER4) {
            fl.log("Withdrawal receiver USER4 hit");
        }
        if (receiver == USER5) {
            fl.log("Withdrawal receiver USER5 hit");
        }
        if (receiver == USER6) {
            fl.log("Withdrawal receiver USER6 hit");
        }
        if (receiver == USER7) {
            fl.log("Withdrawal receiver USER7 hit");
        }
        if (receiver == USER8) {
            fl.log("Withdrawal receiver USER8 hit");
        }
        if (receiver == USER9) {
            fl.log("Withdrawal receiver USER9 hit");
        }
        if (receiver == USER10) {
            fl.log("Withdrawal receiver USER10 hit");
        }
        if (receiver == USER11) {
            fl.log("Withdrawal receiver USER11 hit");
        }
        if (receiver == USER12) {
            fl.log("Withdrawal receiver USER12 hit");
        }
        if (receiver == USER13) {
            fl.log("Withdrawal receiver USER13 hit");
        }
    }
    function _logWithdrawalCallbackContractCoverage(
        address callbackContract
    ) internal {
        if (callbackContract == address(0)) {
            fl.log("Withdrawal callbackContract is address(0)");
        } else {
            fl.log("Withdrawal callbackContract is non-zero address");
        }
    }

    function _logWithdrawalUiFeeReceiverCoverage(
        address uiFeeReceiver
    ) internal {
        if (uiFeeReceiver == address(0)) {
            fl.log("Withdrawal uiFeeReceiver is address(0)");
        } else {
            fl.log("Withdrawal uiFeeReceiver is non-zero address");
        }
    }

    function _logWithdrawalMarketCoverage(address market) internal {
        if (market == address(market_0_WETH_USDC)) {
            fl.log("Withdrawal market market_0_WETH_USDC hit");
        }

        if (market == address(market_WBTC_WBTC_USDC)) {
            fl.log("Withdrawal market market_WBTC_WBTC_USDC hit");
        }
        if (market == address(market_WETH_WETH_USDC)) {
            fl.log("Withdrawal market market_WETH_WETH_USDC hit");
        }
        if (market == address(market_WETH_WETH_USDT)) {
            fl.log("Withdrawal market market_WETH_WETH_USDT hit");
        }
    }

    function _logWithdrawalLongTokenSwapPathCoverage(
        address[] memory longTokenSwapPath
    ) internal {
        if (longTokenSwapPath.length == 0) {
            fl.log("Withdrawal longTokenSwapPath is empty");
        }
        if (longTokenSwapPath.length == 1) {
            fl.log("Withdrawal longTokenSwapPath has 1 element");
        }
        if (longTokenSwapPath.length == 2) {
            fl.log("Withdrawal longTokenSwapPath has 2 elements");
        }
        if (longTokenSwapPath.length >= 3) {
            fl.log("Withdrawal longTokenSwapPath has 3 or more elements");
        }
    }

    function _logWithdrawalShortTokenSwapPathCoverage(
        address[] memory shortTokenSwapPath
    ) internal {
        if (shortTokenSwapPath.length == 0) {
            fl.log("Withdrawal shortTokenSwapPath is empty");
        }
        if (shortTokenSwapPath.length == 1) {
            fl.log("Withdrawal shortTokenSwapPath has 1 element");
        }
        if (shortTokenSwapPath.length == 2) {
            fl.log("Withdrawal shortTokenSwapPath has 2 elements");
        }
        if (shortTokenSwapPath.length >= 3) {
            fl.log("Withdrawal shortTokenSwapPath has 3 or more elements");
        }
    }

    function _logWithdrawalMarketTokenAmountCoverage(
        uint256 marketTokenAmount
    ) internal {
        if (marketTokenAmount == 0) {
            fl.log("Withdrawal marketTokenAmount is 0");
        }
        if (marketTokenAmount > 0 && marketTokenAmount <= 1e6) {
            fl.log("Withdrawal marketTokenAmount is between 0 and 1e6");
        }
        if (marketTokenAmount > 1e6 && marketTokenAmount <= 1e12) {
            fl.log("Withdrawal marketTokenAmount is between 1e6 and 1e12");
        }
        if (marketTokenAmount > 1e12 && marketTokenAmount <= 1e18) {
            fl.log("Withdrawal marketTokenAmount is between 1e12 and 1e18");
        }
        if (marketTokenAmount > 1e18 && marketTokenAmount <= 1e24) {
            fl.log("Withdrawal marketTokenAmount is between 1e18 and 1e24");
        }
        if (marketTokenAmount > 1e24) {
            fl.log("Withdrawal marketTokenAmount is greater than 1e24");
        }
    }

    function _logWithdrawalMinLongTokenAmountCoverage(
        uint256 minLongTokenAmount
    ) internal {
        if (minLongTokenAmount == 0) {
            fl.log("Withdrawal minLongTokenAmount is 0");
        }
        if (minLongTokenAmount > 0 && minLongTokenAmount <= 1e6) {
            fl.log("Withdrawal minLongTokenAmount is between 0 and 1e6");
        }
        if (minLongTokenAmount > 1e6 && minLongTokenAmount <= 1e12) {
            fl.log("Withdrawal minLongTokenAmount is between 1e6 and 1e12");
        }
        if (minLongTokenAmount > 1e12 && minLongTokenAmount <= 1e18) {
            fl.log("Withdrawal minLongTokenAmount is between 1e12 and 1e18");
        }
        if (minLongTokenAmount > 1e18 && minLongTokenAmount <= 1e24) {
            fl.log("Withdrawal minLongTokenAmount is between 1e18 and 1e24");
        }
        if (minLongTokenAmount > 1e24) {
            fl.log("Withdrawal minLongTokenAmount is greater than 1e24");
        }
    }

    function _logWithdrawalMinShortTokenAmountCoverage(
        uint256 minShortTokenAmount
    ) internal {
        if (minShortTokenAmount == 0) {
            fl.log("Withdrawal minShortTokenAmount is 0");
        }
        if (minShortTokenAmount > 0 && minShortTokenAmount <= 1e6) {
            fl.log("Withdrawal minShortTokenAmount is between 0 and 1e6");
        }
        if (minShortTokenAmount > 1e6 && minShortTokenAmount <= 1e12) {
            fl.log("Withdrawal minShortTokenAmount is between 1e6 and 1e12");
        }
        if (minShortTokenAmount > 1e12 && minShortTokenAmount <= 1e18) {
            fl.log("Withdrawal minShortTokenAmount is between 1e12 and 1e18");
        }
        if (minShortTokenAmount > 1e18 && minShortTokenAmount <= 1e24) {
            fl.log("Withdrawal minShortTokenAmount is between 1e18 and 1e24");
        }
        if (minShortTokenAmount > 1e24) {
            fl.log("Withdrawal minShortTokenAmount is greater than 1e24");
        }
    }

    function _logWithdrawalUpdatedAtBlockCoverage(
        uint256 updatedAtBlock
    ) internal {
        if (updatedAtBlock == 0) {
            fl.log("Withdrawal updatedAtBlock is 0");
        } else {
            fl.log("Withdrawal updatedAtBlock is non-zero");
        }
    }

    function _logWithdrawalUpdatedAtTimeCoverage(
        uint256 updatedAtTime
    ) internal {
        if (updatedAtTime == 0) {
            fl.log("Withdrawal updatedAtTime is 0");
        } else {
            fl.log("Withdrawal updatedAtTime is non-zero");
        }
    }

    function _logWithdrawalExecutionFeeCoverage(uint256 executionFee) internal {
        if (executionFee == 0) {
            fl.log("Withdrawal executionFee is 0");
        }
        if (executionFee > 0 && executionFee <= 1e6) {
            fl.log("Withdrawal executionFee is between 0 and 1e6");
        }
        if (executionFee > 1e6 && executionFee <= 1e12) {
            fl.log("Withdrawal executionFee is between 1e6 and 1e12");
        }
        if (executionFee > 1e12 && executionFee <= 1e18) {
            fl.log("Withdrawal executionFee is between 1e12 and 1e18");
        }
        if (executionFee > 1e18 && executionFee <= 1e24) {
            fl.log("Withdrawal executionFee is between 1e18 and 1e24");
        }
        if (executionFee > 1e24) {
            fl.log("Withdrawal executionFee is greater than 1e24");
        }
    }

    function _logWithdrawalCallbackGasLimitCoverage(
        uint256 callbackGasLimit
    ) internal {
        if (callbackGasLimit == 0) {
            fl.log("Withdrawal callbackGasLimit is 0");
        }
        if (callbackGasLimit > 0 && callbackGasLimit <= 1e6) {
            fl.log("Withdrawal callbackGasLimit is between 0 and 1e6");
        }
        if (callbackGasLimit > 1e6 && callbackGasLimit <= 1e12) {
            fl.log("Withdrawal callbackGasLimit is between 1e6 and 1e12");
        }
        if (callbackGasLimit > 1e12 && callbackGasLimit <= 1e18) {
            fl.log("Withdrawal callbackGasLimit is between 1e12 and 1e18");
        }
        if (callbackGasLimit > 1e18 && callbackGasLimit <= 1e24) {
            fl.log("Withdrawal callbackGasLimit is between 1e18 and 1e24");
        }
        if (callbackGasLimit > 1e24) {
            fl.log("Withdrawal callbackGasLimit is greater than 1e24");
        }
    }

    function _logWithdrawalShouldUnwrapNativeTokenCoverage(
        bool shouldUnwrapNativeToken
    ) internal {
        if (shouldUnwrapNativeToken) {
            fl.log("Withdrawal shouldUnwrapNativeToken is true");
        } else {
            fl.log("Withdrawal shouldUnwrapNativeToken is false");
        }
    }
}
