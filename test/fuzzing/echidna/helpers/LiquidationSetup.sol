// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./PropertiesSetup.sol";
import "../../contracts/market/MarketUtils.sol";

contract LiquidationSetup is PropertiesSetup {
    function LiquidateVault(uint8 userIndex) public {
        (, , , address user) = _gamma_getVault(userIndex); //gmxUtils is a holder of position

        uint256 positionCountBefore = PositionStoreUtils.getPositionCount(
            dataStore
        );

        Position.Props[] memory positions = reader.getAccountPositions(
            dataStore,
            user,
            0,
            10
        ); //@coverage:limiter
        Position.Props memory positionToLiquidate = positions[0];

        bytes32 positionKey = Position.getPositionKey(
            user,
            positionToLiquidate.addresses.market,
            positionToLiquidate.addresses.collateralToken,
            positionToLiquidate.flags.isLong
        );

        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            positionToLiquidate.addresses.market
        );

        TokenPrices memory tokenPrices = _setTokenPrices(
            1 //priceseed for the minimal price
        );

        (
            bool isLiquidatable /*string memory */,
            ,
            PositionUtils.IsPositionLiquidatableInfo
                memory isPositionLiquidatableInfo
        ) = PositionUtils.isPositionLiquidatable(
                dataStore,
                referralStorage,
                positionToLiquidate, //Position.Props memory position,
                marketProps, //Market.Props memory market,
                _getMarketPrices(marketProps.marketToken, tokenPrices), //MarketUtils.MarketPrices memory prices
                true // bool shouldValidateMinCollateralUsd
            );

        require(isLiquidatable, "Position is not liquidatable");

        _liquidate(
            user,
            positionToLiquidate.addresses.market,
            positionToLiquidate.addresses.collateralToken,
            positionToLiquidate.flags.isLong,
            tokenPrices
        );

        uint256 positionCountAfter = PositionStoreUtils.getPositionCount(
            dataStore
        );

        bytes32[] memory autoCancelOrderKeys = AutoCancelUtils
            .getAutoCancelOrderKeys(dataStore, positionKey);

        invariantPositionCountShouldDecrease(
            positionCountAfter,
            positionCountBefore
        );
        invariantPositionCountDecreasesByOne(
            positionCountAfter,
            positionCountBefore
        );
        invariantAutoCancelListShouldBeEmptyAfterLiquidation(
            autoCancelOrderKeys.length
        );

        _checkPositionLiquitatableCoverage(
            user,
            positionToLiquidate.addresses.market,
            positionToLiquidate.addresses.collateralToken,
            positionToLiquidate.flags.isLong,
            isPositionLiquidatableInfo
        );
    }

    function Liquidate(uint8 userIndex) public {
        address user = _getRandomUser(userIndex);

        uint256 positionCountBefore = PositionStoreUtils.getPositionCount(
            dataStore
        );

        Position.Props[] memory positions = reader.getAccountPositions(
            dataStore,
            user,
            0,
            10
        ); //@coverage:limiter
        Position.Props memory positionToLiquidate = positions[0];

        bytes32 positionKey = Position.getPositionKey(
            user,
            positionToLiquidate.addresses.market,
            positionToLiquidate.addresses.collateralToken,
            positionToLiquidate.flags.isLong
        );

        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            positionToLiquidate.addresses.market
        );

        TokenPrices memory tokenPrices = _setTokenPrices(
            1 //priceseed for the minimal price
        );

        (
            bool isLiquidatable /*string memory */,
            ,
            PositionUtils.IsPositionLiquidatableInfo
                memory isPositionLiquidatableInfo
        ) = PositionUtils.isPositionLiquidatable(
                dataStore,
                referralStorage,
                positionToLiquidate, //Position.Props memory position,
                marketProps, //Market.Props memory market,
                _getMarketPrices(marketProps.marketToken, tokenPrices), //MarketUtils.MarketPrices memory prices
                true // bool shouldValidateMinCollateralUsd
            );

        require(isLiquidatable, "Position is not liquidatable");

        _liquidate(
            user,
            positionToLiquidate.addresses.market,
            positionToLiquidate.addresses.collateralToken,
            positionToLiquidate.flags.isLong,
            tokenPrices
        );

        uint256 positionCountAfter = PositionStoreUtils.getPositionCount(
            dataStore
        );

        bytes32[] memory autoCancelOrderKeys = AutoCancelUtils
            .getAutoCancelOrderKeys(dataStore, positionKey);

        invariantPositionCountShouldDecrease(
            positionCountAfter,
            positionCountBefore
        );
        invariantPositionCountDecreasesByOne(
            positionCountAfter,
            positionCountBefore
        );
        invariantAutoCancelListShouldBeEmptyAfterLiquidation(
            autoCancelOrderKeys.length
        );

        _checkPositionLiquitatableCoverage(
            user,
            positionToLiquidate.addresses.market,
            positionToLiquidate.addresses.collateralToken,
            positionToLiquidate.flags.isLong,
            isPositionLiquidatableInfo
        );
    }

    function _liquidate(
        address account,
        address market,
        address collateralToken,
        bool isLong,
        TokenPrices memory tokenPrices
    ) internal {
        OracleUtils.SetPricesParams memory oracleParams = SetOraclePrices(
            tokenPrices.tokens,
            tokenPrices.maxPrices,
            tokenPrices.minPrices
        );

        vm.prank(DEPLOYER);
        (bool success, bytes memory data) = address(liquidationHandler).call(
            abi.encodeWithSelector(
                LiquidationHandler.executeLiquidation.selector,
                account,
                market,
                collateralToken,
                isLong,
                oracleParams
            )
        );
        if (!success) {
            invariantDoesNotSilentRevert(data);
        }
    }
}
