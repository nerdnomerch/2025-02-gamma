// SPDX-License-Identifier: MIT
import "../../../contracts/order/IBaseOrderUtils.sol";
import {MarketUtils} from "../../../contracts/market/MarketUtils.sol";
import {Price} from "../../../contracts/price/Price.sol";

pragma solidity ^0.8.0;
contract OrderSetup {
    function _setCreateOrderParamsAddresses(
        address receiver,
        address callbackContract,
        address uiFeeReceiver,
        address market,
        address initialCollateralToken,
        address[] memory swapPath
    )
        internal
        pure
        returns (IBaseOrderUtils.CreateOrderParamsAddresses memory)
    {
        return
            IBaseOrderUtils.CreateOrderParamsAddresses({
                receiver: receiver,
                cancellationReceiver: receiver,
                callbackContract: callbackContract,
                uiFeeReceiver: uiFeeReceiver,
                market: market,
                initialCollateralToken: initialCollateralToken,
                swapPath: swapPath
            });
    }

    function _setCreateOrderParamsNumbers(
        uint256 sizeDeltaUsd,
        uint256 initialCollateralDeltaAmount,
        uint256 triggerPrice,
        uint256 acceptablePrice,
        uint256 executionFee,
        uint256 callbackGasLimit,
        uint256 minOutputAmount,
        uint256 validFromTime
    ) internal pure returns (IBaseOrderUtils.CreateOrderParamsNumbers memory) {
        return
            IBaseOrderUtils.CreateOrderParamsNumbers({
                sizeDeltaUsd: sizeDeltaUsd,
                initialCollateralDeltaAmount: initialCollateralDeltaAmount,
                triggerPrice: triggerPrice,
                acceptablePrice: acceptablePrice,
                executionFee: executionFee,
                callbackGasLimit: callbackGasLimit,
                minOutputAmount: minOutputAmount,
                validFromTime: validFromTime
            });
    }

    function _setCreateOrderParams(
        IBaseOrderUtils.CreateOrderParamsAddresses memory addresses,
        IBaseOrderUtils.CreateOrderParamsNumbers memory numbers,
        Order.OrderType orderType,
        Order.DecreasePositionSwapType decreasePositionSwapType,
        bool isLong,
        bool shouldUnwrapNativeToken,
        bool autoCancel,
        bytes32 referralCode
    ) internal pure returns (IBaseOrderUtils.CreateOrderParams memory) {
        return
            IBaseOrderUtils.CreateOrderParams({
                addresses: addresses,
                numbers: numbers,
                orderType: orderType,
                decreasePositionSwapType: decreasePositionSwapType,
                isLong: isLong,
                shouldUnwrapNativeToken: shouldUnwrapNativeToken,
                autoCancel: autoCancel,
                referralCode: referralCode
            });
    }

    function _setMarketPrices(
        uint256 indexTokenPriceMin,
        uint256 indexTokenPriceMax,
        uint256 longTokenPriceMin,
        uint256 longTokenPriceMax,
        uint256 shortTokenPriceMin,
        uint256 shortTokenPriceMax
    ) internal pure returns (MarketUtils.MarketPrices memory) {
        MarketUtils.MarketPrices memory prices;
        prices.indexTokenPrice = Price.Props(
            indexTokenPriceMin,
            indexTokenPriceMax
        );
        prices.longTokenPrice = Price.Props(
            longTokenPriceMin,
            longTokenPriceMax
        );
        prices.shortTokenPrice = Price.Props(
            shortTokenPriceMin,
            shortTokenPriceMax
        );

        return prices;
    }
}
