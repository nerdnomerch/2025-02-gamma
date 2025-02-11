// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./helpers/GMXSetup.sol";
import {MarketPrices, PriceProps} from "../../../contracts/libraries/StructData.sol";

contract FuzzFoundry is GMXSetup {
    event GmxPositionCallbackCalled(bytes32 requestKey, bool success);

    function setUp() public {
        SetUpGMX();
    }

    function test_fail() public {
        assert(false);
    }

    function test_GammaDeposit() public {
        GammaDeposit(2, 2, 10_000e6);
    }

    function test_GammaDepositWithdraw() public {
        GammaDeposit(2, 2, 10_000e6);
        GammaDeposit(2, 3, 10_000e6);
        GammaDeposit(2, 1, 10_000e6);
        GammaDeposit(2, 0, 10_000e6);
        vm.prank(USER1);
        USDC.transfer(vault_GammaVault3x_WETHUSDC, 3333e6); //direct transfer to getRandomvault(2) emulate fees
        GammaWithdraw(2, 2, 10_000e6); //seed should be the same for the same vault
    }

    function test_GammaDepositOpenExecuteOrder() public {
        GammaDeposit(2, 2, 10_000e6);
        IncreaseOrder(2, 50000e4, true); //isLong
        ExecuteOrder(2, 50000e4, false); //isAtomic
    }

    function test_GammaDepositOpenClose() public {
        GammaDeposit(2, 2, 10_000e6);
        IncreaseOrder(2, 50000e4, true); //isLong
        ExecuteOrder(2, 50000e4, false); //isAtomic
        NextActionPerps(2, 50000e4);
        DecreasePosition(2, 4000e4, true);
        ExecuteOrder(2, 50000e4, false); //isAtomic
        NextActionPerps(2, 50000e4);
    }

    function test_GammaDepositOpenLongOpenShort() public {
        GammaDeposit(2, 2, 10_000e6);
        IncreaseOrder(2, 50000e4, true); //isLong
        ExecuteOrder(2, 50000e4, false); //isAtomic
        NextActionPerps(2, 50000e4);
        IncreaseOrder(2, 4000e4, false); //this is short, but will just close long
        ExecuteOrder(2, 50000e4, false); //isAtomic
        NextActionPerps(2, 5222e4);
        // IncreaseOrder(2, 4000e4, false); //open short
        ExecuteOrder(2, 50000e4, false);
        NextActionPerps(2, 50000e4); // this executes FINALIZE action.
    }

    /*
     *
     * GAMMA COVERAGE CHECK
     *
     */
    function test_GammaDepositWithOpenPosition() public {
        uint8 seed = 2;
        uint8 userSeed = 1;
        uint priceSeed = 5000;
        GammaDeposit(seed, userSeed, 50000e4);
        console.log("Deposit #1 done");

        IncreaseOrder(seed, priceSeed, true);
        console.log("Increase order done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(seed, priceSeed);
        console.log("Nextaction done(finalize)");

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("Nextaction #1 done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("Nextaction done(finalize)");

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_GammaWithdrawWithOpenPosition() public {
        uint8 seed = 2;
        uint8 userSeed = 2;
        uint priceSeed = 50000e4;

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(seed, priceSeed, true);
        console.log("Increase order done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done(finalize)");

        GammaWithdraw(seed, userSeed, priceSeed);
        console.log("Withdrawal done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction #1 done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #3 done");

        NextActionPerps(seed, priceSeed);

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_GammaOpenLongPosition1x() public {
        uint8 seed = 6;
        uint8 userSeed = 1;
        uint priceSeed = 50000e4 * 2 + 1; //odd is USDC => WETH

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        SwapOrder(
            true,
            true, //only paraswap
            seed,
            priceSeed,
            50000e4
        );
        console.log("Swap order done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order done");

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_GammaSwitchPositionType() public {
        uint8 seed = 2;
        uint8 userSeed = 2;
        uint priceSeed = 5000e4;

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(seed, priceSeed, true); // Open long
        console.log("Increase order (long) done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done(finalize)");

        IncreaseOrder(seed, priceSeed, false); // Attempt to open short
        console.log("Increase order (decrease) done");

        ExecuteOrder(seed, priceSeed, false); // This should close the long position
        console.log("Execute order #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done");

        ExecuteOrder(seed, priceSeed, false); // This should close the long position
        console.log("Execute order #3 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done(finalize)");

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_GammaCloseNonOneLeveragePosition() public {
        uint8 seed = 2;
        uint8 userSeed = 2;
        uint priceSeed = 50000e4;

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(seed, priceSeed, true);
        console.log("Increase order done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done(finalize)");

        DecreasePosition(seed, priceSeed, true);
        console.log("Decrease position done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done(finalize)");

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_GammaCloseOneLeveragePosition() public {
        uint8 seed = 6;
        uint8 userSeed = 1;
        uint priceSeed = 100000e6 + 1;

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        SwapOrder(true, true, seed, priceSeed, 10000e6);
        console.log("Swap order done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        DecreasePosition(seed, priceSeed, true);
        console.log("Decrease position done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done(finalize)");

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_GammaRunNextActionWithdraw() public {
        uint8 seed = 2;
        uint8 userSeed = 2;
        uint priceSeed = 50000e4;

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(seed, priceSeed, true);
        console.log("Increase order done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done(finalize)");

        GammaWithdraw(seed, userSeed, priceSeed);
        console.log("Withdrawal done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #3 done");

        NextActionPerps(seed, priceSeed);

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_GammaDepositTwiceRunNextActionWithdraw() public {
        uint8 seed = 2;
        uint8 userSeed = 2;
        uint priceSeed = 50000e4;
        (address vault, , , ) = _gamma_getVault(seed);
        address user = _getRandomUser(userSeed);

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");
        // ExecuteOrder(seed, priceSeed, false);

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit #2 done");

        _invariant_GAMMA_12(vault, user);

        IncreaseOrder(seed, priceSeed, true);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);

        GammaWithdraw(seed, userSeed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);

        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        NextActionPerps(seed, priceSeed);

        gammaGeneralPostconditions(vault, priceSeed);
    }
    function test_GammaRunNextActionSettle() public {
        uint8 seed = 2;
        uint8 userSeed = 2;
        uint priceSeed = 50000e4;

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(seed, priceSeed, true);
        console.log("Increase order done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done(finalize)");

        GammaWithdraw(seed, userSeed, priceSeed);
        console.log("Withdrawal done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #3 done");
        NextActionPerps(seed, priceSeed);

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_AfterOrderExecution_WithdrawMarketDecrease() public {
        uint8 seed = 2;
        uint8 userSeed = 2;
        uint priceSeed = 50000e4;

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(seed, priceSeed, true);
        console.log("Increase order done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction #1 done");

        GammaWithdraw(seed, userSeed, priceSeed);
        console.log("Withdrawal done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #2 done");
        console.log(
            "test_AfterOrderExecution_WithdrawMarketDecrease::Withdrawal executed"
        );

        NextActionPerps(seed, priceSeed);
        console.log("NextAction #1 done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #3 done");

        NextActionPerps(seed, priceSeed); //this will execute finalize
        console.log("NextAction #2 done (finalize)");

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_AfterOrderExecution_WithdrawMarketSwap() public {
        uint8 seed = 6;
        uint8 userSeed = 2;
        uint priceSeed = 50000e4;

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        SwapOrder(true, true, seed, priceSeed, 5e7);
        console.log("Swap order create done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Swap order execute done");

        GammaWithdraw(seed, userSeed, priceSeed);
        console.log("Withdraw create done");

        NextActionPerps(seed, priceSeed);
        ExecuteOrder(seed, priceSeed, false);
        // NextActionPerps(seed, priceSeed); //this will execute finalize

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_Coverage01_SwitchPositionType() public {
        uint8 seed = 6;
        uint8 userSeed = 1;
        uint priceSeed = 10000e6 * 2 + 1;

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(seed, priceSeed, true); // Open long
        console.log("Increase order (long) done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        bool isLong = false;
        IncreaseOrder(seed, priceSeed, isLong);
        console.log("Increase order (close) done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done");
        
        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #3 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done(finalize)");

        // IncreaseOrder(seed, priceSeed, isLong);
        // console.log("Increase order (short) done");

        // ExecuteOrder(seed, priceSeed, false);
        // console.log("Execute order #3 done");

        // NextActionPerps(seed, priceSeed);
        // console.log("NextAction done");

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_fundingFeesCollection() public {
        //make sure LP is ok
        IncreaseOrder(
            6, //  marketIndex,
            2, //  userIndex,
            2, // leverageSeed,
            5000e4, //  priceSeed,
            10e18, // amount,
            false, //isLimit,
            false, //isLong,
            7,
            FIXED_EXECUTION_FEE_AMOUNT //executionFee
        );
        console.log("Increase order for LP done");

        (address vault, , , ) = _gamma_getVault(7);

        ExecuteOrder(5000e4, true);
        console.log("Execute order for LP done");

        GammaDeposit(7, 2, 10_000e6);
        console.log("Deposit done");

        IncreaseOrder(7, 5000e4, true); //isLong
        console.log("Increase order (long) done");

        ExecuteOrder(7, 5000e4, false); //isAtomic
        console.log("Execute order done");

        NextActionPerps(7, 5000e4);
        console.log("NextAction done(finalize)");

        vm.warp(block.timestamp + 3 weeks);
        console.log("Time warped 3 weeks");

        test_withdrawAndCheckFees(7, 2, 5000e4, true);
        console.log("Withdraw and check fees done");
    }
    function test_withdrawAndCheckFees(
        uint8 vaultSeed,
        uint8 userSeed,
        uint priceSeed,
        bool isLong
    ) internal {
        (address vault, , , ) = _gamma_getVault(vaultSeed);
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
            _gammaAfter();

            gammaGeneralPostconditions(vault, priceSeed);
            _invariant_GAMMA_01(userSeed, vaultSeed, initialDepositAmount);
            _invariant_GAMMA_07(vault, depositTimestamp);
        }
    }

    function test_DonateAndCheckExecution() public {
        uint8 seed = 2;
        uint8 userSeed = 1;
        uint priceSeed = 10000e6 * 2 + 1;

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(seed, priceSeed, true); // Open long
        console.log("Increase order (long) done");

        _mintAndSendTokensTo(
            _getRandomUser(userSeed),
            address(orderVault),
            10e18,
            1000e6,
            address(WETH),
            address(USDC),
            0,
            false
        );
        console.log("Tokens minted and sent");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done(finalize)");

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_openAndLiquidatePosition() public {
        uint8 userSeed = 1;
        uint8 vaultSeed = 2;
        (address vault, , , ) = _gamma_getVault(vaultSeed);

        uint priceSeed = 5000e4 * 2 + 1;
        GammaDeposit(vaultSeed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(vaultSeed, priceSeed, true); // Open long
        console.log("Increase order (long) done");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #1 done");

        LiquidateVault(vaultSeed);
        console.log("Vault liquidated");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction done");

        (bool success, , ) = GammaWithdraw(vaultSeed, userSeed, priceSeed);
        fl.t(success, "GAMMA-15: Withdraw failed after liquidation");
        console.log("Withdrawal attempted");

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_openAndDepositNewWhileLiquidating() public {
        uint8 userSeed = 1;
        uint8 vaultSeed = 2;
        (address vault, , , ) = _gamma_getVault(vaultSeed);

        uint priceSeed = 5000e4 * 2 + 1;
        GammaDeposit(vaultSeed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(vaultSeed, priceSeed, true); // Open long
        console.log("Increase order (long) done");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction done(finalize)");

        priceSeed = 5000e4 * 2 + 1;
        GammaDeposit(vaultSeed, userSeed, priceSeed);
        console.log("Deposit #2 done");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction #1 done");

        LiquidateVault(vaultSeed);
        console.log("Vault liquidated");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction #2 done");

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_openAndDepositNewWhileLiquidating_1() public {
        uint8 userSeed = 1;
        uint8 vaultSeed = 2;
        (address vault, , , ) = _gamma_getVault(vaultSeed);

        uint priceSeed = 5000e4 * 2 + 1;
        GammaDeposit(vaultSeed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(vaultSeed, priceSeed, true); // Open long
        console.log("Increase order (long) done");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction done(finalize)");

        priceSeed = 5000e4 * 2 + 1;
        GammaDeposit(vaultSeed, userSeed, priceSeed);
        console.log("Deposit #2 done");

        LiquidateVault(vaultSeed);
        console.log("Vault liquidated");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction #1 done");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction #2 done");

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_openAndWithdrawWhileLiquidating() public {
        uint8 userSeed = 1;
        uint8 vaultSeed = 2;
        (address vault, , , ) = _gamma_getVault(vaultSeed);

        uint priceSeed = 5000e4 * 2 + 1;
        GammaDeposit(vaultSeed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(vaultSeed, priceSeed, true); // Open long
        console.log("Increase order (long) done");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction done(finalize)");

        GammaWithdraw(vaultSeed, userSeed, priceSeed);
        console.log("Withdrawal done");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction #1 done");

        LiquidateVault(vaultSeed);
        console.log("Vault liquidated");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #3 done");

        NextActionPerps(vaultSeed, priceSeed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_openAndWithdrawWhileLiquidating_1() public {
        uint8 userSeed1 = 1;
        uint8 userSeed2 = 1;
        uint8 vaultSeed = 2;
        (address vault, , , ) = _gamma_getVault(vaultSeed);

        uint priceSeed = 5000e4 * 2 + 1;
        GammaDeposit(vaultSeed, userSeed1, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(vaultSeed, priceSeed, true); // Open long
        console.log("Increase order (long) done");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction done(finalize)");

        GammaDeposit(vaultSeed, userSeed2, priceSeed);
        console.log("Deposit done");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction done");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction done(finalize)");

        GammaWithdraw(vaultSeed, userSeed1, priceSeed);
        console.log("Withdrawal done");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #3 done");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction #1 done");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #3 done");

        LiquidateVault(vaultSeed);
        console.log("Vault liquidated");

        NextActionPerps(vaultSeed, priceSeed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_openAndADLVault() public {
        uint8 userSeed = 1;
        uint8 vaultSeed = 2;
        (address vault, , , ) = _gamma_getVault(vaultSeed);

        uint priceSeed = 1000e4;

        GammaDepositAmount(vaultSeed, userSeed, priceSeed, 83000e6);
        console.log("Deposit done");

        IncreaseOrder(vaultSeed, priceSeed, true);
        console.log("Increase order done");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction done(finalize)");

        ExecuteADLonVault(vaultSeed, 999999e4);
        console.log("ADL executed on vault");

        (bool success, , ) = GammaWithdraw(vaultSeed, userSeed, priceSeed);
        fl.t(success, "GAMMA-16: WIthdraw failed afted ADL");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(vaultSeed, priceSeed);
        console.log("NextAction done");

        ExecuteOrder(vaultSeed, priceSeed, false);
        console.log("Execute order #3 done");
        NextActionPerps(vaultSeed, priceSeed);
        gammaGeneralPostconditions(vault, priceSeed);
    }

    /*
     *
     * GAMMA REMEDIATIONS COVERAGE GUIDANCE
     *
     */

    function test_GammaDepositOpenCloseDonateWETH_Finalize() public {
        (address vault, , , ) = _gamma_getVault(2);

        GammaDeposit(2, 2, 10_000e6);

        IncreaseOrder(2, 50000e4, true); //isLong
        ExecuteOrder(2, 50000e4, false); //isAtomic
        NextActionPerps(2, 50000e4);

        DecreasePosition(2, 4000e4, true);
        ExecuteOrder(2, 50000e4, false); //isAtomic
        NextActionPerps(2, 50000e4);

        _mintAndSendTokensTo(
            _getRandomUser(1),
            address(vault),
            10e17,
            0,
            address(WETH),
            address(0),
            0,
            false
        );
        console.log("Tokens minted and sent");
    }
    function test_GammaDepositWithOpenPositionDonateWETH() public {
        uint8 seed = 2;
        uint8 userSeed = 1;
        uint priceSeed = 5000e4;

        GammaDeposit(seed, userSeed, 50000e4);
        console.log("Deposit #1 done");

        (address vault, , , ) = _gamma_getVault(2);

        _mintAndSendTokensTo(
            _getRandomUser(1),
            address(vault),
            10e17,
            0,
            address(WETH),
            address(0),
            0,
            false
        );
        console.log("Tokens minted and sent");

        IncreaseOrder(seed, priceSeed, false);
        console.log("Increase order done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(seed, priceSeed);
        console.log("Nextaction done(finalize)");

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("Nextaction #1 done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("Nextaction done(finalize)");

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_Coverage01_SwitchPositionType_Donate() public {
        uint8 seed = 2;
        uint8 userSeed = 1;
        uint priceSeed = 5000e4;
        (address vault, , , ) = _gamma_getVault(seed);

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");
        _mintAndSendTokensTo(
            _getRandomUser(1),
            address(vault),
            10e17,
            0,
            address(WETH),
            address(0),
            0,
            false
        );
        IncreaseOrder(seed, priceSeed, true); // Open long
        console.log("Increase order (long) done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done(finalize)");

        gammaGeneralPostconditions(vault, priceSeed);

        bool isLong = false;
        IncreaseOrder(seed, priceSeed, isLong);
        console.log("Increase order (close) done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #2 done");

        _mintAndSendTokensTo(
            _getRandomUser(1),
            address(vault),
            10e17,
            0,
            address(WETH),
            address(0),
            0,
            false
        );

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done");
        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #3 done");
        NextActionPerps(seed, priceSeed);
        console.log("NextAction done(finalize)");

        // IncreaseOrder(seed, priceSeed, isLong);
        // console.log("Increase order (short) done");

        // ExecuteOrder(seed, priceSeed, false);
        // console.log("Execute order #3 done");

        // NextActionPerps(seed, priceSeed);
        // console.log("NextAction done");

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_GammaCloseOneLeveragePosition_Remed() public {
        uint8 seed = 6;
        uint8 userSeed = 1;
        uint priceSeed = 100000e6 + 1;

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        SwapOrder(true, true, seed, priceSeed, 10000e6);
        console.log("Swap order done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        DecreasePosition(seed, priceSeed, true);
        console.log("Decrease position done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("NextAction done(finalize)");

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_AfterOrderExecution_CompoundSwapToCollateral() public {
        uint8 seed = 6;
        uint8 userSeed = 1;
        uint priceSeed = 100000e6 + 1;
        uint swapAmount = 10000e6;

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        SwapOrder(true, true, seed, priceSeed, swapAmount);
        ExecuteOrder(seed, priceSeed, false);

        (address vault, , , ) = _gamma_getVault(seed);

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_GammaCompoundPositionDonateWETH_1x() public {
        uint8 seed = 6;
        uint8 userSeed = 1;
        uint priceSeed = 5000e4;

        GammaDeposit(seed, userSeed, 50000e4);
        console.log("Deposit #1 done");

        (address vault, , , ) = _gamma_getVault(seed);

        IncreaseOrder(seed, priceSeed, true);
        console.log("Increase order done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        _mintAndSendTokensTo(
            _getRandomUser(1),
            address(vault),
            0,
            1000e6,
            address(0),
            address(USDC),
            0,
            false
        );
        console.log("Tokens minted and sent");
        NextActionPerps(seed, priceSeed);
        console.log("Nextaction #1 done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #2 done");

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_GammaCompoundPositionDonateWETH_3x() public {
        uint8 seed = 2;
        uint8 userSeed = 1;
        uint priceSeed = 5000e4;

        GammaDeposit(seed, userSeed, 50000e4);
        console.log("Deposit #1 done");

        (address vault, , , ) = _gamma_getVault(seed);

        IncreaseOrder(seed, priceSeed, false);
        console.log("Increase order done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        NextActionPerps(seed, priceSeed);
        console.log("Nextaction done(finalize)");

        _mintAndSendTokensTo(
            _getRandomUser(1),
            address(vault),
            0,
            1000e6,
            address(0),
            address(USDC),
            0,
            false
        );

        console.log("Tokens minted and sent");
        NextActionPerps(seed, priceSeed);
        console.log("Nextaction #1 done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("Nextaction done(finalize)");

        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_GammaAfterOrderExecutionDeposit() public {
        uint8 seed = 6;
        uint8 userSeed = 1;
        uint priceSeed = 5000e4;

        (address vault, , , ) = _gamma_getVault(seed);

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(seed, priceSeed, true); // Open long
        console.log("Increase order (long) done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        GammaDepositAmount(seed, userSeed, 50000e4, 1000e6);
        console.log("Deposit #2 done");

        NextActionPerps(seed, priceSeed);
        console.log("Swap create done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Swap exec done");
        gammaGeneralPostconditions(vault, priceSeed);
    }

    function test_GammaAfterOrderExecutionWithdraw() public {
        uint8 seed = 6;
        uint8 userSeed = 1;
        uint priceSeed = 5000e4;

        (address vault, , , ) = _gamma_getVault(seed);

        GammaDeposit(seed, userSeed, priceSeed);
        console.log("Deposit done");

        IncreaseOrder(seed, priceSeed, true); // Open long
        console.log("Increase order (long) done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Execute order #1 done");

        GammaWithdraw(seed, userSeed, 50000e4);
        console.log("Withdraw done");

        NextActionPerps(seed, priceSeed);
        console.log("Swap create done");

        ExecuteOrder(seed, priceSeed, false);
        console.log("Swap exec done");
        gammaGeneralPostconditions(vault, priceSeed);
    }

    // function test_GammaWithdrawHandlereturn() public {
    //         uint8 seed = 2;
    //         uint8 userSeed = 1;
    //         uint priceSeed = 5000e4;

    //         GammaDeposit(seed, userSeed, 50000e4);
    //         console.log("Deposit #1 done");

    //         (address vault, , , ) = _gamma_getVault(seed);

    //         IncreaseOrder(seed, priceSeed, false);
    //         console.log("Increase order done");

    //         ExecuteOrder(seed, priceSeed, false);
    //         console.log("Execute order #1 done");

    //         _mintAndSendTokensTo(
    //             _getRandomUser(1),
    //             address(vault),
    //             0,
    //             1000e6,
    //             address(0),
    //             address(USDC),
    //             0,
    //             false
    //         );

    //         console.log("Tokens minted and sent");
    //         NextActionPerps(seed, priceSeed);
    //         console.log("Nextaction #1 done");

    //         ExecuteOrder(seed, priceSeed, false);
    //         console.log("Execute order #2 done");

    //         NextActionPerps(seed, priceSeed);

    //         gammaGeneralPostconditions(vault, priceSeed);
    //     }

    /*
     *
     * GAMMA REPRODUCERS
     *   */

    function test_repro_1() public {
        fuzz_GammaDepositTwiceRunNextActionWithdraw(2, 0, 0);
        GammaDeposit(2, 0, 0);
        fuzz_GammaDepositWithOpenPositionDonateWETH(0, 0, 0);
    }

    function test_repro_2() public {
        GammaDeposit(0, 0, 0);
        GammaDepositAmount(3, 0, 47654714, 100480594);
        IncreaseOrder(3, 0, false);
        fuzz_DonateAndCheckExecution(3, 0, 0);
    }
    function test_repro_3() public {
        fuzz_GammaDepositWithOpenPositionDonateWETH(0, 0, 0);
        fuzz_DonateAndCheckExecution(0, 0, 705709976243);
        SwapOrder(
            0,
            0,
            0,
            50002941298112524874146358841539193,
            5,
            false,
            171540775384921815137
        );
    }
    function test_repro_4() public {
        GammaDeposit(1, 0, 0);
        fuzz_GammaAfterOrderExecutionDeposit(1, 0, 0);
    }

    function test_repro_5() public {
        GammaDeposit(1, 0, 0);
        fuzz_GammaAfterOrderExecutionDeposit(
            1,
            0,
            5934489017468350883856402165029223355504162875051693592408052
        );
    }
    function test_repro_6() public {
        GammaDeposit(1, 0, 0);
        fuzz_GammaDepositOpenCloseDonateWETH_Finalize(1, 0, 27321050);
    }
    function test_repro_7() public {
        fuzz_SwitchPositionType_Donate(7, 0, 26225403);
        console.log('fuzz_GammaCloseNonOneLeveragePosition');
        fuzz_GammaCloseNonOneLeveragePosition(1, 0, 0);
    }
    function test_repro_8() public {
        GammaDeposit(1, 0, 0);
        fuzz_GammaAfterOrderExecutionDeposit(1, 0, 0);
    }
    receive() external payable {}
}
