// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./PropertiesSetup.sol";

contract ADLSetup is PropertiesSetup {
    struct ADL_cache {
        bytes callData_SwitchADL;
        bool success_SwitchADL;
        bytes returnData_SwitchADL;
        bytes callData_ExecuteADL;
        bool success_ExecuteADL;
        bytes returnData_ExecuteADL;
        bytes callData_SwitchADL_back;
        bool success_SwitchADL_back;
        bytes returnData_SwitchADL_back;
    }
    function ExecuteADLonVault(uint8 userIndex, uint seed) public {
        (, , , address user) = _gamma_getVault(userIndex); //gmxUtils is a holder of position

        Position.Props[] memory positions = reader.getAccountPositions(
            dataStore,
            user,
            0,
            10
        );
        Position.Props memory positionToADL = positions[0];

        bytes32 positionKey = Position.getPositionKey(
            user,
            positionToADL.addresses.market,
            positionToADL.addresses.collateralToken,
            positionToADL.flags.isLong
        );

        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            positionToADL.addresses.market
        );

        TokenPrices memory tokenPrices = _setTokenPrices(
            seed //priceseed for the max price
        );

        ReaderPositionUtils.PositionInfo memory positionInfo = reader.getPositionInfo(
            dataStore,
            referralStorage,
            positionKey,
            _getMarketPrices(marketProps.marketToken, tokenPrices),
            0, //size delta usd == 0 because usePositionSizeAsSizeDeltaUsd is true
            address(0), //uiFeeReceiver
            true //usePositionSizeAsSizeDeltaUsd
        );

        uint reduceSizeBy = clampBetween(
            seed,
            1,
            positionInfo.position.numbers.sizeInUsd
        );

        _adl(
            marketProps,
            user,
            positionToADL.addresses.market,
            positionToADL.flags.isLong,
            positionToADL.addresses.collateralToken,
            reduceSizeBy,
            tokenPrices
        );

        ReaderPositionUtils.PositionInfo memory positionInfoAfter = reader
            .getPositionInfo(
                dataStore,
                referralStorage,
                positionKey,
                _getMarketPrices(marketProps.marketToken, tokenPrices),
                0, //size delta usd = 0 because usePositionSizeAsSizeDeltaUsd is true
                address(0),
                true //usePositionSizeAsSizeDeltaUsd
            );

        invariantPositionSizeUSDShouldDecrease(
            positionInfo.position.numbers.sizeInUsd,
            positionInfoAfter.position.numbers.sizeInUsd,
            reduceSizeBy
        );
    }

    function ExecuteADL(uint8 userIndex, uint seed) public {
        address user = _getRandomUser(userIndex);

        Position.Props[] memory positions = reader.getAccountPositions(
            dataStore,
            user,
            0,
            10
        );
        Position.Props memory positionToADL = positions[0];

        bytes32 positionKey = Position.getPositionKey(
            user,
            positionToADL.addresses.market,
            positionToADL.addresses.collateralToken,
            positionToADL.flags.isLong
        );

        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            positionToADL.addresses.market
        );

        TokenPrices memory tokenPrices = _setTokenPrices(
            seed //priceseed for the max price
        );

        ReaderPositionUtils.PositionInfo memory positionInfo = reader.getPositionInfo(
            dataStore,
            referralStorage,
            positionKey,
            _getMarketPrices(marketProps.marketToken, tokenPrices),
            0, //size delta usd == 0 because usePositionSizeAsSizeDeltaUsd is true
            address(0), //uiFeeReceiver
            true //usePositionSizeAsSizeDeltaUsd
        );

        uint reduceSizeBy = clampBetween(
            seed,
            1,
            positionInfo.position.numbers.sizeInUsd
        );

        _adl(
            marketProps,
            user,
            positionToADL.addresses.market,
            positionToADL.flags.isLong,
            positionToADL.addresses.collateralToken,
            reduceSizeBy,
            tokenPrices
        );

        ReaderPositionUtils.PositionInfo memory positionInfoAfter = reader
            .getPositionInfo(
                dataStore,
                referralStorage,
                positionKey,
                _getMarketPrices(marketProps.marketToken, tokenPrices),
                0, //size delta usd = 0 because usePositionSizeAsSizeDeltaUsd is true
                address(0),
                true //usePositionSizeAsSizeDeltaUsd
            );

        invariantPositionSizeUSDShouldDecrease(
            positionInfo.position.numbers.sizeInUsd,
            positionInfoAfter.position.numbers.sizeInUsd,
            reduceSizeBy
        );
    }

    function _adl(
        Market.Props memory marketProps,
        address user,
        address market,
        bool isLong,
        address collateralToken,
        uint reduceSizeBy,
        TokenPrices memory tokenPrices
    ) internal {
        ADL_cache memory cache;

        OracleUtils.SetPricesParams memory oracleParams = SetOraclePrices(
            tokenPrices.tokens,
            tokenPrices.maxPrices,
            tokenPrices.minPrices
        );

        cache.callData_SwitchADL = abi.encodeWithSelector(
            adlHandler.updateAdlState.selector,
            market,
            isLong,
            oracleParams
        );

        vm.prank(DEPLOYER);
        adlHandler.updateAdlState(market, isLong, oracleParams);

        vm.prank(DEPLOYER);
        adlHandler.executeAdl(
            user,
            market,
            collateralToken,
            isLong,
            reduceSizeBy,
            oracleParams
        );

        //Switching prices back to minimum and disabling ADL
        TokenPrices memory lowestTokenPrices = _setTokenPrices(1000e4);

        OracleUtils.SetPricesParams
            memory oracleParamsSwitchADL = SetOraclePrices(
                lowestTokenPrices.tokens,
                lowestTokenPrices.maxPrices,
                lowestTokenPrices.minPrices
            );

        vm.prank(DEPLOYER);
        adlHandler.updateAdlState(market, isLong, oracleParams);
        bool isAdlEnabled = dataStore.getBool(
            Keys.isAdlEnabledKey(market, isLong)
        );

        require(!isAdlEnabled, "ADL should be disabled");
    }
}
