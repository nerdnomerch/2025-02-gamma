// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./depositSetup/DepositSpeedup.sol";
import "./withdrawSetup/WithdrawSpeedup.sol";
import "./positionSetup/PositionSpeedup.sol";
import "./positionSetup/GMXPositionSpeedup.sol";
import "./shiftSetup/ShiftSpeedup.sol";
import "./LiquidationSetup.sol";
import "./DonationSetup.sol";

contract GMXSetup is
    DepositSpeedup,
    WithdrawSpeedup,
    PositionSpeedup,
    GMXPositionSpeedup,
    ShiftSpeedup,
    LiquidationSetup,
    DonationSetup
    //ADL is imported through positions contract
{
    function SetUpGMX() internal {
        deployment(address(this));
        marketsSetup();
        userSetup();
        deployCallbackCotracts();
        deployGammaVault1x_WETHUSDC();
        deployGammaVault2x_WETHUSDC();
        deployGammaVault3x_WETHUSDC();
        deployGammaVault1x_WBTCUSDC();
        deployGammaVault2x_WBTCUSDC();
        deployGammaVault3x_WBTCUSDC();
        setVaultsArray();
        deployDex();

        for (uint i = 0; i < USERS.length; ++i) {
            if (address(USERS[i]).balance > 0) {
                vm.prank(USERS[i]);
                WETH.deposit{value: address(USERS[i]).balance / 2}();
            }
            MintableToken(address(USDC)).mint(USERS[i], 1000_000_000e6);
            MintableToken(address(USDT)).mint(USERS[i], 1000_000_000e6);
            MintableToken(address(WBTC)).mint(USERS[i], 1_000_000e8);
        }

        if (address(paraswapDeployer).balance > 0) {
            uint paraswapDeployerBalance = address(paraswapDeployer).balance;
            vm.prank(paraswapDeployer);
            WETH.deposit{value: paraswapDeployerBalance / 2}();
        }
        MintableToken(address(USDC)).mint(paraswapDeployer, 1000_000_000e6);
        MintableToken(address(USDT)).mint(paraswapDeployer, 1000_000_000e6);
        MintableToken(address(WBTC)).mint(paraswapDeployer, 1_000_000e8);

        setUpDeposits(6, 500e18, 100_000_000e6);
        setUpDeposits(7, 500e18, 100_000_000e6);
        setUpDeposits(8, 500e18, 100_000_000e6);
        setUpDeposits(9, 500e8, 100_000_000e6);

        addLiquidityDex();
        fillVaultMarketMap();
        setRouterInVault();
    }

    /**
     *
     * GAMMA GUIDED FUNCTIONS
     *
     */

    function fuzz_GammaDepositWithOpenPosition(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        IncreaseOrder(seed, priceSeed, true);
        ExecuteOrder(seed, priceSeed, false);

        GammaDeposit(seed, userSeed, priceSeed);
        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);

        NextActionPerps(seed, priceSeed);

        address user = _getRandomUser(userSeed);

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
        _invariant_GAMMA_12(vault, user);
    }

    function fuzz_GammaWithdrawWithOpenPosition(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();
        IncreaseOrder(seed, priceSeed, true);
        ExecuteOrder(seed, priceSeed, false);

        GammaWithdraw(seed, userSeed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);

        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_GammaOpenPosition1x(
        bool isLong,
        bool isParaswap,
        uint8 seed,
        uint8 userSeed,
        uint priceSeed,
        uint amount
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        SwapOrder(
            isLong,
            isParaswap, //only paraswap
            seed,
            priceSeed,
            amount
        );
        ExecuteOrder(seed, priceSeed, false);

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_GammaSwitchPositionType(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        IncreaseOrder(seed, priceSeed, true); // Open long
        ExecuteOrder(seed, priceSeed, false);

        IncreaseOrder(seed, priceSeed, false); // Attempt to open short
        ExecuteOrder(seed, priceSeed, false); // This should close the long position

        NextActionPerps(seed, priceSeed);

        IncreaseOrder(seed, priceSeed, false); // Attempt to open short
        ExecuteOrder(seed, priceSeed, false); // This should close the long position

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_GammaCloseNonOneLeveragePosition(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        IncreaseOrder(seed, priceSeed, true);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);

        DecreasePosition(seed, priceSeed, true);
        ExecuteOrder(seed, priceSeed, false);

        NextActionPerps(seed, priceSeed);

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_GammaCloseOneLeveragePosition(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed,
        uint swapAmount
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        SwapOrder(true, true, seed, priceSeed, swapAmount);
        ExecuteOrder(seed, priceSeed, false);

        DecreasePosition(seed, priceSeed, true);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);
        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_GammaRunNextActionWithdraw(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        IncreaseOrder(seed, priceSeed, true);
        ExecuteOrder(seed, priceSeed, false);

        GammaWithdraw(seed, userSeed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);

        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_GammaDepositTwiceRunNextActionWithdraw(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        address user = _getRandomUser(userSeed);

        GammaDeposit(seed, userSeed, priceSeed);

        _invariant_GAMMA_12(vault, user);

        IncreaseOrder(seed, priceSeed, true);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);

        GammaWithdraw(seed, userSeed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);

        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_GammaRunNextActionSettle(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        IncreaseOrder(seed, priceSeed, true);
        ExecuteOrder(seed, priceSeed, false);

        GammaWithdraw(seed, userSeed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);

        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);

        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);
        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_AfterOrderExecution_DepositMarketIncrease(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed); //this will execute finalize

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_AfterOrderExecution_WithdrawMarketDecrease(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        IncreaseOrder(seed, priceSeed, true);
        ExecuteOrder(seed, priceSeed, false);

        GammaWithdraw(seed, userSeed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed); //this will execute finalize

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_AfterOrderExecution_WithdrawMarketSwap(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed,
        uint swapAmount
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        SwapOrder(true, true, seed, priceSeed, swapAmount);
        ExecuteOrder(seed, priceSeed, false);

        GammaWithdraw(seed, userSeed, priceSeed);

        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed); //this will execute finalize

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_AfterOrderExecution_GmxSwapNonCollateralToIndex(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed,
        uint swapAmount
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        SwapOrder(true, true, seed, priceSeed, swapAmount);
        ExecuteOrder(seed, priceSeed, false);

        DecreasePosition(seed, priceSeed, true);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);

        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);
        NextActionPerps(seed, priceSeed); //this will execute finalize

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_AfterOrderExecution_CompoundSwapToCollateral(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed,
        uint swapAmount
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        SwapOrder(true, true, seed, priceSeed, swapAmount);
        ExecuteOrder(seed, priceSeed, false);

        vm.warp(block.timestamp + 7 days); //collect fees

        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);
        NextActionPerps(seed, priceSeed);

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_Coverage01_SwitchPositionType(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        IncreaseOrder(seed, priceSeed, true); // Open long
        ExecuteOrder(seed, priceSeed, false);

        bool isLong = false; //short
        IncreaseOrder(seed, priceSeed, isLong);
        ExecuteOrder(seed, priceSeed, false);

        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);
        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_withdrawAndCheckFees(
        uint8 vaultSeed,
        uint8 userSeed,
        uint priceSeed,
        bool isLong
    ) public {
        (address vault, , , ) = _gamma_getVault(vaultSeed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();
        require(
            PerpetualVault(vault).curPositionKey() != bytes32(0),
            "Position should be opened"
        );

        _positionBefore();
        if (states[0].vaultInfos[vault].totalFees > 0) {
            DecreasePosition(vaultSeed, priceSeed, isLong);

            ExecuteOrder(vaultSeed, priceSeed, true); //isAtomic
            NextActionPerps(vaultSeed, priceSeed);

            _gammaBefore();
            (
                ,
                uint initialDepositAmount,
                uint depositTimestamp
            ) = GammaWithdraw(vaultSeed, userSeed, priceSeed);
            _positionAfter();
            require(
                states[1].vaultInfos[vault].totalFees == 0,
                "Position wasn't closed"
            );
            if (
                initialFlow == PerpetualVault.FLOW.NONE &&
                !PerpetualVaultLens(vault).cancellationTriggered()
            ) {
                gammaGeneralPostconditions(vault, priceSeed);
            }
            _invariant_GAMMA_01(userSeed, vaultSeed, initialDepositAmount);
            _invariant_GAMMA_07(vault, depositTimestamp);
        }
    }

    function fuzz_GammaNextActionCompound(
        uint8 vaultSeed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(vaultSeed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();
        IncreaseExecuteOrder_GuidedBrick_01(userSeed, priceSeed);
        GammaDeposit(vaultSeed, userSeed, priceSeed);
        RunNextAction_GuidedBrick_02(vaultSeed, priceSeed);
        vm.warp(block.timestamp + priceSeed); //collect funding
        RunNextAction_GuidedBrick_02(vaultSeed, priceSeed);
    }

    function fuzz_DonateAndCheckExecution(
        uint8 vaultSeed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(vaultSeed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();
        address index = PerpetualVault(vault).indexToken();

        (PerpetualVault.NextActionSelector currentAction, ) = PerpetualVault(
            vault
        ).nextAction();

        IncreaseOrder(userSeed, priceSeed, true);

        (currentAction, ) = PerpetualVault(vault).nextAction();
        address nakamoto = _getRandomUser(userSeed + 1); //other user - nakamoto the wealthy

        _mintAndSendTokensTo(
            nakamoto,
            address(orderVault),
            fl.clamp(priceSeed, 0, WETH.balanceOf(nakamoto)), //long token
            fl.clamp(priceSeed, 0, USDC.balanceOf(nakamoto)), //short token
            address(index),
            address(USDC),
            0,
            false
        );
        ExecuteOrder(userSeed, priceSeed, false);
        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(vaultSeed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(vaultSeed, priceSeed);
        }

        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_openAndLiquidatePosition(
        uint8 vaultSeed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(vaultSeed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        GammaDeposit(vaultSeed, userSeed, priceSeed);

        IncreaseOrder(vaultSeed, priceSeed, true); // Open long
        ExecuteOrder(vaultSeed, priceSeed, false);

        LiquidateVault(vaultSeed);

        (bool success, , ) = GammaWithdraw(vaultSeed, userSeed, priceSeed);
        fl.t(success, "GAMMA-15: WIthdraw failed afted liquidation");

        ExecuteOrder(vaultSeed, priceSeed, false);

        NextActionPerps(vaultSeed, priceSeed);
        ExecuteOrder(vaultSeed, priceSeed, false); //retry
        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(vaultSeed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(vaultSeed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_openAndADLVault_PriceGuided(
        uint8 vaultSeed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(vaultSeed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        priceSeed = 1000e4; //from 1k

        GammaDepositAmount(vaultSeed, userSeed, priceSeed, 83000e6); //to 250k x3 lev

        IncreaseOrder(vaultSeed, priceSeed, true);
        ExecuteOrder(vaultSeed, priceSeed, false);

        ExecuteADLonVault(vaultSeed, 999999e4);

        (bool success, , ) = GammaWithdraw(vaultSeed, userSeed, priceSeed);
        fl.t(success, "GAMMA-16: WIthdraw failed afted ADL");

        ExecuteOrder(vaultSeed, priceSeed, false);

        NextActionPerps(vaultSeed, priceSeed);
        ExecuteOrder(vaultSeed, priceSeed, false);
        NextActionPerps(vaultSeed, priceSeed);
        gammaGeneralPostconditions(vault, priceSeed);
        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(vaultSeed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(vaultSeed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_openAndADLVault_Free(
        uint8 vaultSeed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(vaultSeed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        GammaDepositAmount(
            vaultSeed,
            userSeed,
            priceSeed,
            priceSeed / vaultSeed
        );

        IncreaseOrder(vaultSeed, priceSeed, true);
        ExecuteOrder(vaultSeed, priceSeed, false);

        ExecuteADLonVault(vaultSeed, priceSeed);

        GammaWithdraw(vaultSeed, userSeed, priceSeed);
        ExecuteOrder(vaultSeed, priceSeed, false);

        NextActionPerps(vaultSeed, priceSeed);
        ExecuteOrder(vaultSeed, priceSeed, false);
        NextActionPerps(vaultSeed, priceSeed);
        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(vaultSeed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(vaultSeed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    /*
     *
     * GAMMA REMEDIATIONS COVERAGE GUIDANCE
     *
     */

    function fuzz_GammaDepositOpenCloseDonateWETH_Finalize(
        uint8 vaultSeed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(vaultSeed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();
        address index = PerpetualVault(vault).indexToken();

        IncreaseOrder(vaultSeed, priceSeed, true); //isLong
        ExecuteOrder(vaultSeed, priceSeed, false); //isAtomic
        NextActionPerps(vaultSeed, priceSeed);

        DecreasePosition(
            vaultSeed,
            priceSeed / fl.clamp(userSeed, 1, 10),
            true
        );
        ExecuteOrder(vaultSeed, priceSeed, false); //isAtomic

        _mintAndSendTokensTo(
            _getRandomUser(1),
            address(vault),
            fl.clamp(priceSeed, 0, 10e19), //arbitrary
            0,
            address(index),
            address(0),
            0,
            false
        );

        NextActionPerps(vaultSeed, priceSeed);

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(vaultSeed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(vaultSeed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_GammaDepositWithOpenPositionDonateWETH(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();
        address index = PerpetualVault(vault).indexToken();

        GammaDeposit(seed, userSeed, priceSeed);

        _mintAndSendTokensTo(
            _getRandomUser(1),
            address(vault),
            fl.clamp(priceSeed, 0, 10e19), //arbitrary,
            0,
            address(index),
            address(0),
            0,
            false
        );

        IncreaseOrder(seed, priceSeed, false);

        ExecuteOrder(seed, priceSeed, false);
        
        NextActionPerps(seed, priceSeed);

        GammaDeposit(seed, userSeed, priceSeed);

        NextActionPerps(seed, priceSeed);

        ExecuteOrder(seed, priceSeed, false);

        NextActionPerps(seed, priceSeed);
        // NextActionPerps(seed, priceSeed);
        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }

        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_SwitchPositionType_Donate(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();
        address index = PerpetualVault(vault).indexToken();

        GammaDeposit(seed, userSeed, priceSeed);
        _mintAndSendTokensTo(
            _getRandomUser(1),
            address(vault),
            fl.clamp(priceSeed, 0, 10e19), //arbitrary,
            0,
            address(index),
            address(0),
            0,
            false
        );
        IncreaseOrder(seed, priceSeed, true); // Open long

        ExecuteOrder(seed, priceSeed, false);

        NextActionPerps(seed, priceSeed);

        bool isLong = false;
        IncreaseOrder(seed, priceSeed, isLong);

        ExecuteOrder(seed, priceSeed, false);

        _mintAndSendTokensTo(
            _getRandomUser(1),
            address(vault),
            fl.clamp(priceSeed, 0, 10e19), //arbitrary,
            0,
            address(index),
            address(0),
            0,
            false
        );

        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_GammaCloseOneLeveragePosition_Remed(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        GammaDeposit(seed, userSeed, priceSeed);

        SwapOrder(
            true,
            true,
            seed,
            priceSeed,
            fl.clamp(priceSeed, 100e6, 10000e6)
        ); //arbitrary

        ExecuteOrder(seed, priceSeed, false);

        DecreasePosition(seed, priceSeed, true);

        ExecuteOrder(seed, priceSeed, false);

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_GammaCompoundPositionDonateUSDC(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        IncreaseOrder(seed, priceSeed, seed % 2 == 0 ? true : false); //longs/shorts
        ExecuteOrder(seed, priceSeed, false);

        _mintAndSendTokensTo(
            _getRandomUser(1), //any
            address(vault),
            0,
            fl.clamp(priceSeed, 100e6, 10000e9), //arbitrary,
            address(0),
            address(USDC),
            0,
            false
        );

        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);
        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
    }

    function fuzz_GammaAfterOrderExecutionDeposit(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        IncreaseOrder(seed, priceSeed, true); // Open long
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);
        GammaDepositAmount(
            seed,
            userSeed,
            priceSeed,
            fl.clamp(priceSeed, 100e6, 10000e9)
        ); //arbitrary
        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);

        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function fuzz_GammaAfterOrderExecutionWithdraw(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public {
        (address vault, , , ) = _gamma_getVault(seed);
        PerpetualVault.FLOW initialFlow = PerpetualVault(vault).flow();

        GammaDeposit(seed, userSeed, priceSeed);
        IncreaseOrder(seed, priceSeed, true); // Open long
        ExecuteOrder(seed, priceSeed, false);
        GammaWithdraw(seed, userSeed, 50000e4);
        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        if (PerpetualVaultLens(vault)._getGMXLock() == true) {
            ExecuteOrder(seed, priceSeed, false); //isAtomic
        } else if (isNextFinalize(vault)) {
            NextActionPerps(seed, priceSeed);
        }
        if (
            initialFlow == PerpetualVault.FLOW.NONE &&
            !PerpetualVaultLens(vault).cancellationTriggered()
        ) {
            gammaGeneralPostconditions(vault, priceSeed);
        }
    }

    function IncreaseExecuteOrder_GuidedBrick_01(
        //long
        uint8 userSeed,
        uint priceSeed
    ) public {
        IncreaseOrder(userSeed, priceSeed, true); // Open long
        ExecuteOrder(userSeed, priceSeed, false);
    }

    function RunNextAction_GuidedBrick_02(
        uint8 vaultSeed,
        uint priceSeed
    ) public {
        NextActionPerps(vaultSeed, priceSeed);
        ExecuteOrder(vaultSeed, priceSeed, false);
    }
}
