// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../helpers/BaseSetup.sol";

contract BeforeAfter is BaseSetup {
    error IncorrectShiftStateParams(
        uint8 userIndex,
        uint8 marketFromIndex,
        uint8 marketToIndex,
        address user,
        address marketFrom,
        address marketTo
    );

    function _gammaBefore() internal {
        _snapGammaState(0);
    }
    function _gammaAfter() internal {
        _snapGammaState(1);
    }

    function _snapGammaState(uint8 callNum) internal {
        _captureVaultState(callNum);
        _collectDepositInfo(callNum);
    }

    function _positionBefore() internal {
        _snapPositionState(0);
    }
    function _positionAfter() internal {
        _snapPositionState(1);
    }
    function _collectDepositInfo(uint8 stateIndex) internal {
        State storage state = states[stateIndex];

        for (uint i = 0; i < VAULTS.length; i++) {
            address vault = VAULTS[i];

            VaultInfo storage vaultInfo = state.vaultInfos[vault];

            vaultInfo.totalAmount = 0;
            vaultInfo.totalSharesCalculated = 0;
            vaultInfo.oldestDepositTimestamp = type(uint256).max;
            vaultInfo.newestDepositTimestamp = 0;
            vaultInfo.collateralAmount = 0;

            //get collateral balance
            if (PerpetualVault(vault).curPositionKey() != bytes32(0)) {
                ReaderPositionUtils.PositionInfo memory positionInfo;
                try
                    reader.getPositionInfo(
                        dataStore,
                        referralStorage,
                        PerpetualVault(vault).curPositionKey(),
                        _getMarketPrices(
                            vaultToMarket[vault],
                            _setTokenPrices(5000e4)
                        ), //any price, checking for collateral
                        uint256(0),
                        address(0),
                        true
                    )
                returns (ReaderPositionUtils.PositionInfo memory return_positionInfo) {
                    positionInfo = return_positionInfo;
                } catch {
                    // Handle the error
                }
                vaultInfo.collateralAmount = positionInfo
                    .position
                    .numbers
                    .collateralAmount;
            }

            if (vaultInfo.totalShares > 0) {
                vaultInfo.shareValue =
                    ((vaultInfo.vaultUSDCBalance + vaultInfo.collateralAmount) *
                        1e30) /
                    vaultInfo.totalShares;
            } else {
                vaultInfo.shareValue = 0;
            }

            for (uint j = 0; j < USERS.length; j++) {
                address user = USERS[j];

                UserState storage userState = vaultInfo.userStates[user];
                userState.USDCBalance = USDC.balanceOf(USERS[j]);

                uint256[] memory depositIds = PerpetualVault(vault)
                    .getUserDeposits(user);
                userState.depositIds = depositIds;
                userState.totalAmount = 0;
                userState.totalShares = 0;
                userState.lastDepositTimestamp = 0;

                for (uint k = 0; k < depositIds.length; k++) {
                    uint256 depositId = depositIds[k];
                    DepositInfo memory deposit;
                    (
                        deposit.amount,
                        deposit.shares, //aaded execution fee
                        ,
                        ,
                        deposit.timestamp,

                    ) = PerpetualVault(vault).depositInfo(depositId);
                    userState.deposits[depositId] = deposit.amount;

                    userState.totalAmount += deposit.amount;
                    userState.totalShares += deposit.shares;

                    if (deposit.timestamp > userState.lastDepositTimestamp) {
                        userState.lastDepositTimestamp = deposit.timestamp;
                    }

                    vaultInfo.totalAmount += deposit.amount;
                    vaultInfo.totalSharesCalculated += deposit.shares;

                    if (deposit.timestamp < vaultInfo.oldestDepositTimestamp) {
                        vaultInfo.oldestDepositTimestamp = deposit.timestamp;
                    }
                    if (deposit.timestamp > vaultInfo.newestDepositTimestamp) {
                        vaultInfo.newestDepositTimestamp = deposit.timestamp;
                    }
                }
                if (userState.totalShares > 0) {
                    userState.shareValue =
                        (userState.totalShares * vaultInfo.shareValue) /
                        1e30;
                } else {
                    userState.shareValue = 0;
                }
            }
        }
        if (DEBUG) {
            // _analyzeDepositDistribution(stateIndex);
        }
    }

    function _analyzeDepositDistribution(uint8 stateIndex) internal view {
        State storage state = states[stateIndex];

        for (uint i = 0; i < VAULTS.length; i++) {
            address vault = VAULTS[i];
            VaultInfo storage vaultInfo = state.vaultInfos[vault];

            for (uint j = 0; j < USERS.length; j++) {
                address user = USERS[j];
                UserState storage userState = vaultInfo.userStates[user];
                uint256 userSharePercentage;
                uint256 userAmountPercentage;
                if (
                    vaultInfo.totalSharesCalculated != 0 &&
                    vaultInfo.totalAmount != 0
                ) {
                    userSharePercentage =
                        (userState.totalShares * 1e18) /
                        vaultInfo.totalSharesCalculated;
                    userAmountPercentage =
                        (userState.totalAmount * 1e18) /
                        vaultInfo.totalAmount;
                }
            }
        }
    }

    function _captureVaultState(uint8 stateIndex) internal {
        State storage state = states[stateIndex];

        for (uint i = 0; i < VAULTS.length; i++) {
            address vault = VAULTS[i];
            PerpetualVaultLens perpVault = PerpetualVaultLens(vault);
            VaultInfo storage vaultInfo = state.vaultInfos[vault];

            vaultInfo.totalShares = perpVault.totalShares();
            vaultInfo.counter = perpVault.counter();
            vaultInfo.curPositionKey = perpVault.curPositionKey();
            vaultInfo.totalDepositAmount = perpVault.totalDepositAmount();
            vaultInfo.beenLong = perpVault.beenLong();
            vaultInfo.positionIsClosed = perpVault.positionIsClosed();
            vaultInfo.gmxLock = perpVault.isLock();
            vaultInfo.isBusy = perpVault.isBusy();
            vaultInfo.isLocked = perpVault.isLock();

            vaultInfo.treasuryBalance = USDC.balanceOf(perpVault.treasury());
            vaultInfo.vaultUSDCBalance = USDC.balanceOf(vault);
        }
    }
    function _snapPositionState(uint8 stateIndex) internal {
        //checking for position instead of full market
        //not to mix vault fees with other players in the market
        State storage state = states[stateIndex];

        for (uint i = 0; i < VAULTS.length; i++) {
            address vault = VAULTS[i];
            PerpetualVault perpVault = PerpetualVault(vault);
            VaultInfo storage vaultInfo = state.vaultInfos[vault];

            if (PerpetualVault(vault).curPositionKey() != bytes32(0)) {
                ReaderPositionUtils.PositionInfo memory positionInfo;
                try
                    reader.getPositionInfo(
                        dataStore,
                        referralStorage,
                        PerpetualVault(vault).curPositionKey(),
                        _getMarketPrices(
                            vaultToMarket[vault],
                            _setTokenPrices(5000e4)
                        ), //any price, checking for collateral
                        uint256(0),
                        address(0),
                        true
                    )
                returns (ReaderPositionUtils.PositionInfo memory return_positionInfo) {
                    positionInfo = return_positionInfo;
                } catch {
                    // Handle the error
                }
                vaultInfo.totalFees = positionInfo
                    .fees
                    .funding
                    .claimableShortTokenAmount;
            }
        }
    }
    function _snapDepositState(
        address user,
        address market
    ) internal returns (DepositState memory state) {
        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            market
        );

        state.userBalanceMarket = ERC20(market).balanceOf(user);
        state.vaultBalanceLong = ERC20(marketProps.longToken).balanceOf(
            address(depositVault)
        );
        state.vaultBalanceShort = ERC20(marketProps.shortToken).balanceOf(
            address(depositVault)
        );
        state.marketTotalSupply = ERC20(market).totalSupply();

        state.userBalanceLong = ERC20(marketProps.longToken).balanceOf(user);

        state.userBalanceShort = ERC20(marketProps.shortToken).balanceOf(user);
    }

    function _snapShiftState(
        address user,
        address marketFrom,
        address marketTo
    ) internal returns (ShiftState memory state) {
        state.marketToBalance = ERC20(marketTo).balanceOf(user);
        state.marketFromBalance = ERC20(marketFrom).balanceOf(user);

        Market.Props memory marketFromProps = MarketStoreUtils.get(
            dataStore,
            marketFrom
        );
        Market.Props memory marketToProps = MarketStoreUtils.get(
            dataStore,
            marketTo
        );

        state.longTokenPoolAmountMarketFrom = _getPoolAmount(
            dataStore,
            marketFromProps,
            marketFromProps.longToken
        );

        state.shortTokenPoolAmountMarketFrom = _getPoolAmount(
            dataStore,
            marketFromProps,
            marketFromProps.shortToken
        );

        state.longTokenPoolAmountMarketTo = _getPoolAmount(
            dataStore,
            marketToProps,
            marketToProps.longToken
        );

        state.shortTokenPoolAmountMarketTo = _getPoolAmount(
            dataStore,
            marketToProps,
            marketToProps.shortToken
        );

        state.longTokenMarketFeeAmountMarketFrom = _getClaimableFeeAmount(
            marketFrom,
            marketFromProps.longToken
        );

        state.shortTokenMarketFeeAmountMarketFrom = _getClaimableFeeAmount(
            marketTo,
            marketFromProps.shortToken
        );

        return state;
    }

    function _depositPreconditions(
        uint8 userIndex,
        uint8 marketIndex
    ) internal {
        address market = _getMarketAddress(marketIndex);
        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            market
        );
        address user = _getRandomUser(userIndex);

        require(
            ERC20(marketProps.marketToken).balanceOf(user) == 0,
            "FuzzEchidna:: Fresh depositors only" // @coverage: limiter
        );
    }

    function _snapPositionState(
        bytes32 positionKey,
        OrderCreated memory order
    ) internal returns (PositionState memory) {
        /*
        ,___,
        [O.o]
        /)__)
        "--"   This market props are for the POSITION
            NOTE: when cancelling order, position is empty
        */
        Position.Props memory position = PositionStoreUtils.get(
            dataStore,
            positionKey
        );
        Market.Props memory market = MarketStoreUtils.get(
            dataStore,
            position.addresses.market
        );

        PositionState memory state;
        state.sizeInUsd = position.numbers.sizeInUsd;
        state.sizeInTokens = position.numbers.sizeInTokens;
        state.collateralAmount = position.numbers.collateralAmount;
        state.isLong = position.flags.isLong;
        state.OILong = dataStore.getUint(
            Keys.openInterestKey(
                order.createOrderParams.addresses.market,
                order.createOrderParams.addresses.initialCollateralToken,
                true
            )
        );

        address lastAddress = getLastSwapPathAddress(
            order.createOrderParams.addresses
        );
        state.OILongLatestMarket = dataStore.getUint(
            Keys.openInterestKey(
                lastAddress,
                order.createOrderParams.addresses.initialCollateralToken,
                true
            )
        );

        state.OIShort = dataStore.getUint(
            Keys.openInterestKey(
                order.createOrderParams.addresses.market,
                order.createOrderParams.addresses.initialCollateralToken,
                false
            )
        );
        state.collateralSumLong = dataStore.getUint(
            Keys.collateralSumKey(
                order.createOrderParams.addresses.market,
                order.createOrderParams.addresses.initialCollateralToken,
                true
            )
        );
        state.collateralSumShort = dataStore.getUint(
            Keys.collateralSumKey(
                order.createOrderParams.addresses.market,
                order.createOrderParams.addresses.initialCollateralToken,
                false
            )
        );

        /**
        / This marketProps are for the ORDER
        */

        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            order.createOrderParams.addresses.market
        );

        state.balanceOfLongToken = ERC20(marketProps.longToken).balanceOf(
            order.createOrderParams.addresses.receiver
        );

        state.balanceOfShortToken = ERC20(marketProps.shortToken).balanceOf(
            order.createOrderParams.addresses.receiver
        );

        return state;
    }

    function _snapSwapState(
        bool isAfter,
        OrderCreated memory order
    ) internal returns (SwapState memory) {
        SwapState memory state;

        state.balanceOfInputToken = ERC20(
            order.createOrderParams.addresses.initialCollateralToken
        ).balanceOf(order.createOrderParams.addresses.receiver);

        (, state.outputToken) = _getTokenOut(
            _getSwapPath(order.swapPathSeed),
            order.createOrderParams.addresses.initialCollateralToken
        );

        state.balanceOfInputToken = ERC20(
            order.createOrderParams.addresses.initialCollateralToken
        ).balanceOf(order.createOrderParams.addresses.receiver);
        state.balanceOfOutputToken = ERC20(state.outputToken).balanceOf(
            order.createOrderParams.addresses.receiver
        );

        if (!isAfter) {
            state.swapResult = _getAmountsOut(
                order.createOrderParams.addresses.swapPath,
                order.createOrderParams.addresses.initialCollateralToken,
                order.createOrderParams.numbers.initialCollateralDeltaAmount,
                address(0),
                order.tokenPrices
            );
        }

        if (isAfter) {
            fl.t(
                state.outputToken != address(0),
                "Path should be valid at this stage"
            );
        }
        return state;
    }
    function getLastSwapPathAddress(
        IBaseOrderUtils.CreateOrderParamsAddresses memory addresses
    ) internal pure returns (address) {
        if (addresses.swapPath.length == 0) return address(0);
        uint256 lastIndex = addresses.swapPath.length - 1;
        return addresses.swapPath[lastIndex];
    }

    function _snapWithdrawalState(
        address user,
        address market
    ) internal returns (WithdrawalState memory withdrawalState) {
        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            market
        );

        withdrawalState.userBalance = ERC20(market).balanceOf(user);
        withdrawalState.vaultBalance = ERC20(market).balanceOf(
            address(withdrawalVault)
        );
        withdrawalState.marketTokenTotalSupply = ERC20(market).totalSupply();
        withdrawalState.longTokenBalanceMarketVault = ERC20(
            marketProps.longToken
        ).balanceOf(market);
        withdrawalState.shortTokenBalanceMarketVault = ERC20(
            marketProps.shortToken
        ).balanceOf(market);
        withdrawalState.longTokenBalanceUser = ERC20(marketProps.longToken)
            .balanceOf(user);
        withdrawalState.nativeTokenBalanceUser = address(user).balance;
        withdrawalState.shortTokenBalanceUser = ERC20(marketProps.shortToken)
            .balanceOf(user);
    }
}
