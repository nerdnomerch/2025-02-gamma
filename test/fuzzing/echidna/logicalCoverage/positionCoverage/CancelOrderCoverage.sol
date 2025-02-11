// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../properties/BeforeAfter.sol";

contract CancelOrderCoverage is BeforeAfter {
    //       /\_/\           ___
    //    = o_o =_______    \ \  CANCEL ORDER COVERAGE
    //     __^      __(  \.__) )
    // (@)<_____>__(_____)____/

    function _checkOrderCancelCoverage(
        OrderCreated memory orderToCancel
    ) internal {
        _logReceiverCoverage_cancelOrder(
            orderToCancel.createOrderParams.addresses.receiver
        );
        _logCancellationReceiverCoverage_cancelOrder(
            orderToCancel.createOrderParams.addresses.cancellationReceiver
        );
        _logCallbackContractCoverage_cancelOrder(
            orderToCancel.createOrderParams.addresses.callbackContract
        );
        _logUiFeeReceiverCoverage_cancelOrder(
            orderToCancel.createOrderParams.addresses.uiFeeReceiver
        );
        _logInitialCollateralTokenCoverage_cancelOrder(
            orderToCancel.createOrderParams.addresses.initialCollateralToken
        );
        _logMarketCoverage_cancelOrder(
            orderToCancel.createOrderParams.addresses.market
        );
        _logSwapPathCoverage_cancelOrder(
            orderToCancel.createOrderParams.addresses.swapPath
        );
        _logOrderTypeCoverage_cancelOrder(
            orderToCancel.createOrderParams.orderType
        );
        _logDecreasePositionSwapTypeCoverage_cancelOrder(
            orderToCancel.createOrderParams.decreasePositionSwapType
        );
        _logIsLongCoverage_cancelOrder(orderToCancel.createOrderParams.isLong);
        _logShouldUnwrapNativeTokenCoverage_cancelOrder(
            orderToCancel.createOrderParams.shouldUnwrapNativeToken
        );
        _logAutoCancelCoverage_cancelOrder(
            orderToCancel.createOrderParams.autoCancel
        );
        _logReferralCodeCoverage_cancelOrder(
            orderToCancel.createOrderParams.referralCode
        );
        _logSizeDeltaUsdCoverage_cancelOrder(
            orderToCancel.createOrderParams.numbers.sizeDeltaUsd
        );
        _logInitialCollateralDeltaAmountCoverage_cancelOrder(
            orderToCancel.createOrderParams.numbers.initialCollateralDeltaAmount
        );
        _logTriggerPriceCoverage_cancelOrder(
            orderToCancel.createOrderParams.numbers.triggerPrice
        );
        _logAcceptablePriceCoverage_cancelOrder(
            orderToCancel.createOrderParams.numbers.acceptablePrice
        );
        _logExecutionFeeCoverage_cancelOrder(
            orderToCancel.createOrderParams.numbers.executionFee
        );
        _logCallbackGasLimitCoverage_cancelOrder(
            orderToCancel.createOrderParams.numbers.callbackGasLimit
        );
        _logMinOutputAmountCoverage_cancelOrder(
            orderToCancel.createOrderParams.numbers.minOutputAmount
        );
        _logKeyCoverage_cancelOrder(orderToCancel.key);
        _logUpdatedAtCoverage_cancelOrder(orderToCancel.updatedAt);
        _logUserCoverage_cancelOrder(orderToCancel.user);
        _logHandlerTypeCoverage_cancelOrder(orderToCancel.handlerType);
        _logAmountSentCoverage_cancelOrder(orderToCancel.amountSent);
        _logIsCloseCoverage_cancelOrder(orderToCancel.isClose);
    }

    function _logReceiverCoverage_cancelOrder(address receiver) internal {
        if (receiver == USER0) {
            fl.log("Receiver USER0 hit");
        }
        if (receiver == USER1) {
            fl.log("Receiver USER1 hit");
        }
        if (receiver == USER2) {
            fl.log("Receiver USER2 hit");
        }
        if (receiver == USER3) {
            fl.log("Receiver USER3 hit");
        }
        if (receiver == USER4) {
            fl.log("Receiver USER4 hit");
        }
        if (receiver == USER5) {
            fl.log("Receiver USER5 hit");
        }
        if (receiver == USER6) {
            fl.log("Receiver USER6 hit");
        }
        if (receiver == USER7) {
            fl.log("Receiver USER7 hit");
        }
        if (receiver == USER8) {
            fl.log("Receiver USER8 hit");
        }
        if (receiver == USER9) {
            fl.log("Receiver USER9 hit");
        }
        if (receiver == USER10) {
            fl.log("Receiver USER10 hit");
        }
        if (receiver == USER11) {
            fl.log("Receiver USER11 hit");
        }
        if (receiver == USER12) {
            fl.log("Receiver USER12 hit");
        }
        if (receiver == USER13) {
            fl.log("Receiver USER13 hit");
        }
    }

    function _logCancellationReceiverCoverage_cancelOrder(
        address cancellationReceiver
    ) internal {
        if (cancellationReceiver == USER0) {
            fl.log("CancellationReceiver USER0 hit");
        }
        if (cancellationReceiver == USER1) {
            fl.log("CancellationReceiver USER1 hit");
        }
        if (cancellationReceiver == USER2) {
            fl.log("CancellationReceiver USER2 hit");
        }
        if (cancellationReceiver == USER3) {
            fl.log("CancellationReceiver USER3 hit");
        }
        if (cancellationReceiver == USER4) {
            fl.log("CancellationReceiver USER4 hit");
        }
        if (cancellationReceiver == USER5) {
            fl.log("CancellationReceiver USER5 hit");
        }
        if (cancellationReceiver == USER6) {
            fl.log("CancellationReceiver USER6 hit");
        }
        if (cancellationReceiver == USER7) {
            fl.log("CancellationReceiver USER7 hit");
        }
        if (cancellationReceiver == USER8) {
            fl.log("CancellationReceiver USER8 hit");
        }
        if (cancellationReceiver == USER9) {
            fl.log("CancellationReceiver USER9 hit");
        }
        if (cancellationReceiver == USER10) {
            fl.log("CancellationReceiver USER10 hit");
        }
        if (cancellationReceiver == USER11) {
            fl.log("CancellationReceiver USER11 hit");
        }
        if (cancellationReceiver == USER12) {
            fl.log("CancellationReceiver USER12 hit");
        }
        if (cancellationReceiver == USER13) {
            fl.log("CancellationReceiver USER13 hit");
        }
    }

    function _logCallbackContractCoverage_cancelOrder(
        address callbackContract
    ) internal {
        if (callbackContract == address(0)) {
            fl.log("CallbackContract is address(0)");
        } else {
            fl.log("CallbackContract is non-zero address");
        }
    }

    function _logUiFeeReceiverCoverage_cancelOrder(
        address uiFeeReceiver
    ) internal {
        if (uiFeeReceiver == address(0)) {
            fl.log("UiFeeReceiver is address(0)");
        } else {
            fl.log("UiFeeReceiver is non-zero address");
        }
    }

    function _logInitialCollateralTokenCoverage_cancelOrder(
        address initialCollateralToken
    ) internal {
        if (initialCollateralToken == address(WETH)) {
            fl.log("InitialCollateralToken is WETH");
        }
        if (initialCollateralToken == address(WBTC)) {
            fl.log("InitialCollateralToken is WBTC");
        }
        if (initialCollateralToken == address(USDC)) {
            fl.log("InitialCollateralToken is USDC");
        }
        if (initialCollateralToken == address(USDT)) {
            fl.log("InitialCollateralToken is USDT");
        }
        if (initialCollateralToken == address(SOL)) {
            fl.log("InitialCollateralToken is SOL");
        }
    }

    function _logMarketCoverage_cancelOrder(address market) internal {
        if (market == address(market_0_WETH_USDC)) {
            fl.log("Market market_0_WETH_USDC hit");
        }

        if (market == address(market_WBTC_WBTC_USDC)) {
            fl.log("Market market_WBTC_WBTC_USDC hit");
        }
        if (market == address(market_WETH_WETH_USDC)) {
            fl.log("Market market_WETH_WETH_USDC hit");
        }
        if (market == address(market_WETH_WETH_USDT)) {
            fl.log("Market market_WETH_WETH_USDT hit");
        }
    }

    function _logSwapPathCoverage_cancelOrder(
        address[] memory swapPath
    ) internal {
        if (swapPath.length == 0) {
            fl.log("SwapPath is empty");
        }
        if (swapPath.length == 1) {
            fl.log("SwapPath has 1 element");
        }
        if (swapPath.length == 2) {
            fl.log("SwapPath has 2 elements");
        }
        if (swapPath.length >= 3) {
            fl.log("SwapPath has 3 or more elements");
        }
    }

    function _logOrderTypeCoverage_cancelOrder(
        Order.OrderType orderType
    ) internal {
        if (orderType == Order.OrderType.MarketSwap) {
            fl.log("OrderType is MarketSwap");
        }
        if (orderType == Order.OrderType.LimitSwap) {
            fl.log("OrderType is LimitSwap");
        }
        if (orderType == Order.OrderType.MarketIncrease) {
            fl.log("OrderType is MarketIncrease");
        }
        if (orderType == Order.OrderType.LimitIncrease) {
            fl.log("OrderType is LimitIncrease");
        }
        if (orderType == Order.OrderType.MarketDecrease) {
            fl.log("OrderType is MarketDecrease");
        }
        if (orderType == Order.OrderType.LimitDecrease) {
            fl.log("OrderType is LimitDecrease");
        }
        if (orderType == Order.OrderType.StopLossDecrease) {
            fl.log("OrderType is StopLossDecrease");
        }
        if (orderType == Order.OrderType.Liquidation) {
            fl.log("OrderType is Liquidation");
        }
    }

    function _logDecreasePositionSwapTypeCoverage_cancelOrder(
        Order.DecreasePositionSwapType decreasePositionSwapType
    ) internal {
        if (decreasePositionSwapType == Order.DecreasePositionSwapType.NoSwap) {
            fl.log("DecreasePositionSwapType is NoSwap");
        }
        if (
            decreasePositionSwapType ==
            Order.DecreasePositionSwapType.SwapPnlTokenToCollateralToken
        ) {
            fl.log("DecreasePositionSwapType is SwapPnlTokenToCollateralToken");
        }
        if (
            decreasePositionSwapType ==
            Order.DecreasePositionSwapType.SwapCollateralTokenToPnlToken
        ) {
            fl.log("DecreasePositionSwapType is SwapCollateralTokenToPnlToken");
        }
    }

    function _logIsLongCoverage_cancelOrder(bool isLong) internal {
        if (isLong) {
            fl.log("IsLong is true");
        } else {
            fl.log("IsLong is false");
        }
    }

    function _logShouldUnwrapNativeTokenCoverage_cancelOrder(
        bool shouldUnwrapNativeToken
    ) internal {
        if (shouldUnwrapNativeToken) {
            fl.log("ShouldUnwrapNativeToken is true");
        } else {
            fl.log("ShouldUnwrapNativeToken is false");
        }
    }

    function _logAutoCancelCoverage_cancelOrder(bool autoCancel) internal {
        if (autoCancel) {
            fl.log("AutoCancel is true");
        } else {
            fl.log("AutoCancel is false");
        }
    }

    function _logReferralCodeCoverage_cancelOrder(
        bytes32 referralCode
    ) internal {
        if (referralCode == bytes32(0)) {
            fl.log("ReferralCode is empty");
        } else {
            fl.log("ReferralCode is non-empty");
        }
    }

    function _logSizeDeltaUsdCoverage_cancelOrder(
        uint256 sizeDeltaUsd
    ) internal {
        if (sizeDeltaUsd == 0) {
            fl.log("SizeDeltaUsd is 0");
        }
        if (sizeDeltaUsd > 0 && sizeDeltaUsd <= 1e6) {
            fl.log("SizeDeltaUsd is between 0 and 1e6");
        }
        if (sizeDeltaUsd > 1e6 && sizeDeltaUsd <= 1e12) {
            fl.log("SizeDeltaUsd is between 1e6 and 1e12");
        }
        if (sizeDeltaUsd > 1e12 && sizeDeltaUsd <= 1e18) {
            fl.log("SizeDeltaUsd is between 1e12 and 1e18");
        }
        if (sizeDeltaUsd > 1e18 && sizeDeltaUsd <= 1e24) {
            fl.log("SizeDeltaUsd is between 1e18 and 1e24");
        }
        if (sizeDeltaUsd > 1e24) {
            fl.log("SizeDeltaUsd is greater than 1e24");
        }
    }

    function _logInitialCollateralDeltaAmountCoverage_cancelOrder(
        uint256 initialCollateralDeltaAmount
    ) internal {
        if (initialCollateralDeltaAmount == 0) {
            fl.log("InitialCollateralDeltaAmount is 0");
        }
        if (
            initialCollateralDeltaAmount > 0 &&
            initialCollateralDeltaAmount <= 1e6
        ) {
            fl.log("InitialCollateralDeltaAmount is between 0 and 1e6");
        }
        if (
            initialCollateralDeltaAmount > 1e6 &&
            initialCollateralDeltaAmount <= 1e12
        ) {
            fl.log("InitialCollateralDeltaAmount is between 1e6 and 1e12");
        }
        if (
            initialCollateralDeltaAmount > 1e12 &&
            initialCollateralDeltaAmount <= 1e18
        ) {
            fl.log("InitialCollateralDeltaAmount is between 1e12 and 1e18");
        }
        if (
            initialCollateralDeltaAmount > 1e18 &&
            initialCollateralDeltaAmount <= 1e24
        ) {
            fl.log("InitialCollateralDeltaAmount is between 1e18 and 1e24");
        }
        if (initialCollateralDeltaAmount > 1e24) {
            fl.log("InitialCollateralDeltaAmount is greater than 1e24");
        }
    }

    function _logTriggerPriceCoverage_cancelOrder(
        uint256 triggerPrice
    ) internal {
        if (triggerPrice == 0) {
            fl.log("TriggerPrice is 0");
        }
        if (triggerPrice > 0 && triggerPrice <= 1e6) {
            fl.log("TriggerPrice is between 0 and 1e6");
        }
        if (triggerPrice > 1e6 && triggerPrice <= 1e12) {
            fl.log("TriggerPrice is between 1e6 and 1e12");
        }
        if (triggerPrice > 1e12 && triggerPrice <= 1e18) {
            fl.log("TriggerPrice is between 1e12 and 1e18");
        }
        if (triggerPrice > 1e18 && triggerPrice <= 1e24) {
            fl.log("TriggerPrice is between 1e18 and 1e24");
        }
        if (triggerPrice > 1e24) {
            fl.log("TriggerPrice is greater than 1e24");
        }
    }

    function _logAcceptablePriceCoverage_cancelOrder(
        uint256 acceptablePrice
    ) internal {
        if (acceptablePrice == 0) {
            fl.log("AcceptablePrice is 0");
        }
        if (acceptablePrice > 0 && acceptablePrice <= 1e6) {
            fl.log("AcceptablePrice is between 0 and 1e6");
        }
        if (acceptablePrice > 1e6 && acceptablePrice <= 1e12) {
            fl.log("AcceptablePrice is between 1e6 and 1e12");
        }
        if (acceptablePrice > 1e12 && acceptablePrice <= 1e18) {
            fl.log("AcceptablePrice is between 1e12 and 1e18");
        }
        if (acceptablePrice > 1e18 && acceptablePrice <= 1e24) {
            fl.log("AcceptablePrice is between 1e18 and 1e24");
        }
        if (acceptablePrice > 1e24) {
            fl.log("AcceptablePrice is greater than 1e24");
        }
    }

    function _logExecutionFeeCoverage_cancelOrder(
        uint256 executionFee
    ) internal {
        if (executionFee == 0) {
            fl.log("ExecutionFee is 0");
        }
        if (executionFee > 0 && executionFee <= 1e6) {
            fl.log("ExecutionFee is between 0 and 1e6");
        }
        if (executionFee > 1e6 && executionFee <= 1e12) {
            fl.log("ExecutionFee is between 1e6 and 1e12");
        }
        if (executionFee > 1e12 && executionFee <= 1e18) {
            fl.log("ExecutionFee is between 1e12 and 1e18");
        }
        if (executionFee > 1e18 && executionFee <= 1e24) {
            fl.log("ExecutionFee is between 1e18 and 1e24");
        }
        if (executionFee > 1e24) {
            fl.log("ExecutionFee is greater than 1e24");
        }
    }

    function _logCallbackGasLimitCoverage_cancelOrder(
        uint256 callbackGasLimit
    ) internal {
        if (callbackGasLimit == 0) {
            fl.log("CallbackGasLimit is 0");
        }
        if (callbackGasLimit > 0 && callbackGasLimit <= 1e6) {
            fl.log("CallbackGasLimit is between 0 and 1e6");
        }
        if (callbackGasLimit > 1e6 && callbackGasLimit <= 1e12) {
            fl.log("CallbackGasLimit is between 1e6 and 1e12");
        }
        if (callbackGasLimit > 1e12 && callbackGasLimit <= 1e18) {
            fl.log("CallbackGasLimit is between 1e12 and 1e18");
        }
        if (callbackGasLimit > 1e18 && callbackGasLimit <= 1e24) {
            fl.log("CallbackGasLimit is between 1e18 and 1e24");
        }
        if (callbackGasLimit > 1e24) {
            fl.log("CallbackGasLimit is greater than 1e24");
        }
    }

    function _logMinOutputAmountCoverage_cancelOrder(
        uint256 minOutputAmount
    ) internal {
        if (minOutputAmount == 0) {
            fl.log("MinOutputAmount is 0");
        }
        if (minOutputAmount > 0 && minOutputAmount <= 1e6) {
            fl.log("MinOutputAmount is between 0 and 1e6");
        }
        if (minOutputAmount > 1e6 && minOutputAmount <= 1e12) {
            fl.log("MinOutputAmount is between 1e6 and 1e12");
        }
        if (minOutputAmount > 1e12 && minOutputAmount <= 1e18) {
            fl.log("MinOutputAmount is between 1e12 and 1e18");
        }
        if (minOutputAmount > 1e18 && minOutputAmount <= 1e24) {
            fl.log("MinOutputAmount is between 1e18 and 1e24");
        }
        if (minOutputAmount > 1e24) {
            fl.log("MinOutputAmount is greater than 1e24");
        }
    }

    function _logKeyCoverage_cancelOrder(bytes32 key) internal {
        if (key == bytes32(0)) {
            fl.log("Key is empty");
        } else {
            fl.log("Key is non-empty");
        }
    }

    function _logUpdatedAtCoverage_cancelOrder(uint256 updatedAt) internal {
        if (updatedAt == 0) {
            fl.log("UpdatedAt is 0");
        } else {
            fl.log("UpdatedAt is non-zero");
        }
    }

    function _logUserCoverage_cancelOrder(address user) internal {
        if (user == USER0) {
            fl.log("User USER0 hit");
        }
        if (user == USER1) {
            fl.log("User USER1 hit");
        }
        if (user == USER2) {
            fl.log("User USER2 hit");
        }
        if (user == USER3) {
            fl.log("User USER3 hit");
        }
        if (user == USER4) {
            fl.log("User USER4 hit");
        }
        if (user == USER5) {
            fl.log("User USER5 hit");
        }
        if (user == USER6) {
            fl.log("User USER6 hit");
        }
        if (user == USER7) {
            fl.log("User USER7 hit");
        }
        if (user == USER8) {
            fl.log("User USER8 hit");
        }
        if (user == USER9) {
            fl.log("User USER9 hit");
        }
        if (user == USER10) {
            fl.log("User USER10 hit");
        }
        if (user == USER11) {
            fl.log("User USER11 hit");
        }
        if (user == USER12) {
            fl.log("User USER12 hit");
        }
        if (user == USER13) {
            fl.log("User USER13 hit");
        }
    }

    function _logHandlerTypeCoverage_cancelOrder(bytes32 handlerType) internal {
        if (handlerType == bytes32(0)) {
            fl.log("HandlerType is empty");
        } else {
            fl.log("HandlerType is non-empty");
        }
    }

    function _logAmountSentCoverage_cancelOrder(uint256 amountSent) internal {
        if (amountSent == 0) {
            fl.log("AmountSent is 0");
        }
        if (amountSent > 0 && amountSent <= 1e6) {
            fl.log("AmountSent is between 0 and 1e6");
        }
        if (amountSent > 1e6 && amountSent <= 1e12) {
            fl.log("AmountSent is between 1e6 and 1e12");
        }
        if (amountSent > 1e12 && amountSent <= 1e18) {
            fl.log("AmountSent is between 1e12 and 1e18");
        }
        if (amountSent > 1e18 && amountSent <= 1e24) {
            fl.log("AmountSent is between 1e18 and 1e24");
        }
        if (amountSent > 1e24) {
            fl.log("AmountSent is greater than 1e24");
        }
    }

    function _logIsCloseCoverage_cancelOrder(bool isClose) internal {
        if (isClose) {
            fl.log("IsClose is true");
        } else {
            fl.log("IsClose is false");
        }
    }
}
