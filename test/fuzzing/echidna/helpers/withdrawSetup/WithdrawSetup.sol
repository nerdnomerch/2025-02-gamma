// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./../PropertiesSetup.sol";
import "../../../contracts/withdrawal/WithdrawalUtils.sol";

contract WithdrawSetup is PropertiesSetup {
    WithdrawalCreated[] internal withdrawalCreatedArray;

    /**
    //
    // GAMMA withdrawals
    //
    */

    function GammaWithdraw(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed
    ) public returns (bool success, uint depositAmount, uint timestamp) {
        DepositInfo memory deposit;

        (withdrawalAssertionInputs.vault, , , ) = _gamma_getVault(seed);
        require(
            PerpetualVaultLens(withdrawalAssertionInputs.vault)
                .checkForCleanStart(),
            "Previous call was not executed"
        );
        withdrawalAssertionInputs.user = _getRandomUser(userSeed);
        withdrawalAssertionInputs.depositId = _getRandomDepositId(
            seed,
            withdrawalAssertionInputs.user,
            withdrawalAssertionInputs.vault
        );
        uint256 executionFee = PerpetualVault(withdrawalAssertionInputs.vault)
            .getExecutionGasLimit(true);

        (depositAmount, , , , timestamp, ) = PerpetualVault(
            withdrawalAssertionInputs.vault
        ).depositInfo(withdrawalAssertionInputs.depositId);

        vm.warp(
            timestamp +
                PerpetualVault(withdrawalAssertionInputs.vault).lockTime() +
                1
        ); //to satisfy < comparison
        //prank inside:)
        bytes memory returnData;
        (success, returnData) = _gamma_WithdrawCall(
            withdrawalAssertionInputs.user,
            withdrawalAssertionInputs.vault,
            withdrawalAssertionInputs.depositId,
            executionFee
        );

        if (returnData.length > 0) {
            fl.log(
                "Gamma withdraw return data",
                abi.decode(returnData, (string))
            );
        }
    }

    /**
    //
    // GMX withdrawals
    //
    */

    struct WithdrawalCache {
        address[] longSwapPath;
        address[] shortSwapPath;
        address market;
        address user;
    }

    function WithdrawLP(
        uint8 userIndex,
        uint8 marketIndex,
        uint withdrawalAmountSeed,
        uint priceSeed,
        uint8 swapPathSeed,
        uint executionFee,
        bool isAtomic
    ) public {
        WithdrawalCache memory cache;
        executionFee = 0; //In withdrawals, we are not performing an execution fee check because of the implemented method of state change verification

        if (!SWAPS_ENABLED) {
            swapPathSeed = 7;
        }

        cache.longSwapPath = _getSwapPath(swapPathSeed);
        cache.shortSwapPath = _getSwapPath(
            SWAPS_ENABLED ? swapPathSeed / 3 : 7
        ); //another path

        cache.market = _getMarketAddress(marketIndex);
        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            cache.market
        );

        cache.user = _getRandomUser(userIndex);
        uint userBalance = ERC20(cache.market).balanceOf(cache.user);

        WithdrawalUtils.CreateWithdrawalParams
            memory withdrawalParams = _setCreateWithdrawalParams(
                cache.user,
                address(0),
                address(0),
                cache.market,
                cache.longSwapPath, // longTokenSwapPath
                cache.shortSwapPath, // shortTokenSwapPath
                1, //min long token amount
                1, //min short token amount
                false, //unwrap
                executionFee,
                200 * 1000
            );

        WithdrawalState memory stateBefore = _snapWithdrawalState(
            cache.user,
            cache.market
        );

        //Idea is to have bigger value than balance, but not as huge to create lots of empty fuzz runs
        uint amountToWithdraw = clampBetween(
            withdrawalAmountSeed,
            0,
            userBalance * 2
        );

        (
            stateBefore.simulateLongTokenAmountWithdrawal,
            stateBefore.simulateShortTokenAmountWithdrawal
        ) = _simulateWithdrawalAmount(
            marketProps,
            amountToWithdraw,
            priceSeed,
            isAtomic
        );

        WithdrawalCreated memory withdrawalCreated = _withdraw(
            amountToWithdraw,
            withdrawalParams
        );

        Withdrawal.Props memory withdrawalProps = reader.getWithdrawal(
            dataStore,
            withdrawalCreated.withdrawalKey
        );

        if (isAtomic) {
            ExecuteAtomicWithdawal(
                withdrawalParams,
                priceSeed,
                cache.user,
                amountToWithdraw
            );
            _checkExecuteAtomicWithdrawalCoverage(withdrawalProps);
        } else {
            ExecuteWithdrawal(priceSeed, true);
            _checkExecuteWithdrawalCoverage(withdrawalProps);
        }

        WithdrawalState memory stateAfter = _snapWithdrawalState(
            cache.user,
            cache.market
        );

        require(
            stateBefore.userBalance > stateAfter.userBalance,
            "Withdrawal state was not changed"
        );

        invariantWithdrawnTokensMatchSimulatedAmounts(
            stateBefore,
            stateAfter,
            withdrawalCreated
        );
        invariantMarketTokenSupplyDecreases(stateBefore, stateAfter);
    }

    function CreateWithdrawal(
        uint8 userIndex,
        uint8 marketIndex,
        uint withdrawalAmountSeed
    ) public {
        address market = _getMarketAddress(marketIndex);
        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            market
        );

        address user = _getRandomUser(userIndex);
        uint userBalance = ERC20(market).balanceOf(user); //NOTE: not checking if balance != 0, putting it into assertions

        uint amountToWithdraw = clampBetween(
            withdrawalAmountSeed,
            0,
            userBalance * 2
        );

        WithdrawalUtils.CreateWithdrawalParams
            memory withdrawalParams = _setCreateWithdrawalParams(
                user,
                address(0),
                address(0),
                market,
                _getSwapPath(7), //currently empty to check exact output token amounts, // longTokenSwapPath
                _getSwapPath(7), //currently empty to check exact output token amounts,
                1, //min long token amount
                1, //min short token amount
                false, //unwrap
                0,
                200 * 1000
            );

        WithdrawalCreated memory withdrawalCreated = _withdraw(
            amountToWithdraw,
            withdrawalParams
        );

        Withdrawal.Props memory withdrawalProps = reader.getWithdrawal(
            dataStore,
            withdrawalCreated.withdrawalKey
        );
        _checkCreateWithdrawalCoverage(withdrawalProps);
    }

    function _withdraw(
        uint amount,
        WithdrawalUtils.CreateWithdrawalParams memory withdrawalParams
    ) internal returns (WithdrawalCreated memory withdrawalCreated) {
        address user = withdrawalParams.receiver;

        _mintAndSendTokensTo(
            user,
            address(withdrawalVault),
            withdrawalParams.executionFee,
            0,
            address(WETH),
            address(0),
            0,
            true
        );
        require(
            ERC20(withdrawalParams.market).balanceOf(user) > 0,
            "Withdrawal: user has no market tokens"
        );

        vm.prank(user);
        ERC20(withdrawalParams.market).transfer(
            address(withdrawalVault),
            amount
        );

        bytes memory callData_CreateWithdrawal = abi.encodeWithSelector(
            exchangeRouter.createWithdrawal.selector,
            withdrawalParams
        );
        vm.prank(user);

        (
            bool success_CreateWithdrawal,
            bytes memory returnData_CreateWithdrawal
        ) = address(exchangeRouter).call{gas: 30_000_000}(
                callData_CreateWithdrawal
            );

        bytes32 withdrawalKey;
        if (!success_CreateWithdrawal) {
            invariantDoesNotSilentRevert(returnData_CreateWithdrawal);
        } else {
            withdrawalKey = abi.decode(returnData_CreateWithdrawal, (bytes32));
        }

        withdrawalCreated.withdrawalParams = withdrawalParams;
        withdrawalCreated.amount = amount;
        withdrawalCreated.withdrawalKey = withdrawalKey;
        withdrawalCreatedArray.push(withdrawalCreated);
    }

    function ExecuteAtomicWithdawal(
        WithdrawalUtils.CreateWithdrawalParams memory withdrawalParams,
        uint priceSeed,
        address user,
        uint amountToWithdraw
    ) public {
        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            withdrawalParams.market
        );
        TokenPrices memory tokenPrices = _setTokenPrices(priceSeed);

        OracleUtils.SetPricesParams memory oracleParams = SetOraclePrices(
            tokenPrices.tokens,
            tokenPrices.maxPrices,
            tokenPrices.minPrices
        );

        _mintAndSendTokensTo(
            user,
            address(withdrawalVault),
            withdrawalParams.executionFee,
            0,
            address(WETH),
            address(0),
            0,
            true
        );
        uint longTokenBalanceBefore = ERC20(marketProps.longToken).balanceOf(
            withdrawalParams.market
        );
        uint shortTokenBalanceBefore = ERC20(marketProps.shortToken).balanceOf(
            withdrawalParams.market
        );

        require(
            ERC20(withdrawalParams.market).balanceOf(user) > 0,
            "AtomicWithdrawal: user has no market tokens"
        );

        vm.prank(user);
        ERC20(withdrawalParams.market).transfer(
            address(withdrawalVault),
            amountToWithdraw
        );

        bytes memory callData_ExecuteAtomicWithdrawal = abi.encodeWithSelector(
            exchangeRouter.executeAtomicWithdrawal.selector,
            withdrawalParams,
            oracleParams
        );

        vm.prank(user);

        (
            bool success_ExecuteAtomicWithdrawal,
            bytes memory returnData_ExecuteAtomicWithdrawal
        ) = address(exchangeRouter).call{gas: 30_000_000}(
                callData_ExecuteAtomicWithdrawal
            );

        if (!success_ExecuteAtomicWithdrawal) {
            invariantDoesNotSilentRevert(returnData_ExecuteAtomicWithdrawal);
        }

        require(longTokenBalanceBefore != 0 || shortTokenBalanceBefore != 0);
        require(
            longTokenBalanceBefore != 0
                ? longTokenBalanceBefore >
                    ERC20(marketProps.longToken).balanceOf(
                        withdrawalParams.market
                    )
                : shortTokenBalanceBefore >
                    ERC20(marketProps.shortToken).balanceOf(
                        withdrawalParams.market
                    )
        ); //checking if market address has less tokens after execution == some withdrawal succeed
    }

    function ExecuteWithdrawal(uint priceSeed, bool isAtomicExec) public {
        require(
            withdrawalCreatedArray.length > 0,
            "No withdrawals available to execute"
        );

        uint256 randomIndex = isAtomicExec
            ? withdrawalCreatedArray.length - 1
            : clampBetween(priceSeed, 0, withdrawalCreatedArray.length - 1);

        WithdrawalCreated memory withdrawalToExecute = withdrawalCreatedArray[
            randomIndex
        ];
        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            withdrawalToExecute.withdrawalParams.market
        );
        TokenPrices memory tokenPrices = _setTokenPrices(priceSeed);

        OracleUtils.SetPricesParams memory oracleParams = SetOraclePrices(
            tokenPrices.tokens,
            tokenPrices.maxPrices,
            tokenPrices.minPrices
        );

        uint longTokenBalanceBefore = ERC20(marketProps.longToken).balanceOf(
            withdrawalToExecute.withdrawalParams.market
        );
        uint shortTokenBalanceBefore = ERC20(marketProps.shortToken).balanceOf(
            withdrawalToExecute.withdrawalParams.market
        );

        Withdrawal.Props memory withdrawalProps = reader.getWithdrawal(
            dataStore,
            withdrawalToExecute.withdrawalKey
        );

        uint userLongTokenBalanceBefore = ERC20(marketProps.longToken)
            .balanceOf(withdrawalProps.addresses.account);
        uint userShortTokenBalanceBefore = ERC20(marketProps.shortToken)
            .balanceOf(withdrawalProps.addresses.account);

        _executeWithdrawal(
            withdrawalToExecute.withdrawalKey,
            oracleParams,
            withdrawalToExecute.withdrawalParams.executionFee,
            isAtomicExec
        );

        require(longTokenBalanceBefore != 0 || shortTokenBalanceBefore != 0);
        require(
            longTokenBalanceBefore != 0
                ? longTokenBalanceBefore >
                    ERC20(marketProps.longToken).balanceOf(
                        withdrawalToExecute.withdrawalParams.market
                    )
                : shortTokenBalanceBefore >
                    ERC20(marketProps.shortToken).balanceOf(
                        withdrawalToExecute.withdrawalParams.market
                    )
        ); //checking if market address has less tokens after execution == some withdrawal succeed

        _checkExecuteAtomicWithdrawalCoverage(withdrawalProps);

        uint userLongTokenBalanceAfter = ERC20(marketProps.longToken).balanceOf(
            withdrawalProps.addresses.account
        );
        uint userShortTokenBalanceAfter = ERC20(marketProps.shortToken)
            .balanceOf(withdrawalProps.addresses.account);

        fl.gt(
            userLongTokenBalanceAfter,
            userLongTokenBalanceBefore,
            "GAMMA-14: if user withdraws they will get non zero amount in return"
        );

        withdrawalCreatedArray[randomIndex] = withdrawalCreatedArray[
            withdrawalCreatedArray.length - 1
        ];
        withdrawalCreatedArray.pop();
    }
    function CancelWithdrawal(
        uint seed,
        bool isAtomicExec
    )
        public
        returns (
            WithdrawalState memory _before,
            WithdrawalState memory _after,
            WithdrawalCreated memory withdrawalToCancel
        )
    {
        require(
            withdrawalCreatedArray.length > 0,
            "No withdrawals available to execute"
        );

        uint256 randomIndex = isAtomicExec
            ? withdrawalCreatedArray.length - 1
            : clampBetween(seed, 0, withdrawalCreatedArray.length - 1);

        withdrawalToCancel = withdrawalCreatedArray[randomIndex];

        _before = _snapWithdrawalState(
            withdrawalToCancel.withdrawalParams.receiver,
            withdrawalToCancel.withdrawalParams.market
        );
        Withdrawal.Props memory withdrawalProps = reader.getWithdrawal(
            dataStore,
            withdrawalToCancel.withdrawalKey
        );

        bytes memory callData_CancelWithdrawal = abi.encodeWithSelector(
            exchangeRouter.cancelWithdrawal.selector,
            withdrawalToCancel.withdrawalKey
        );
        vm.warp(block.timestamp + REQUEST_EXPIRATION_TIME);

        vm.prank(withdrawalToCancel.withdrawalParams.receiver);

        (
            bool success_CancelWithdrawal,
            bytes memory returnData_CancelWithdrawal
        ) = address(exchangeRouter).call{gas: 30_000_000}(
                callData_CancelWithdrawal
            );

        if (!success_CancelWithdrawal) {
            invariantDoesNotSilentRevert(returnData_CancelWithdrawal);
        }

        _after = _snapWithdrawalState(
            withdrawalToCancel.withdrawalParams.receiver,
            withdrawalToCancel.withdrawalParams.market
        );

        _checkCancelWithdrawalCoverage(withdrawalProps);
    }

    function _executeWithdrawal(
        bytes32 key,
        OracleUtils.SetPricesParams memory oracleParams,
        uint executionFee,
        bool isAtomicExec
    ) internal {
        callback.cleanETHBalance(address(0));
        uint before_callbackBalance_GEN2 = address(callback).balance;

        vm.prank(DEPLOYER);
        withdrawalHandler.executeWithdrawal{gas: 30_000_000}(key, oracleParams);
        if (isAtomicExec) {
            // InvariantExecutionFeeIsAlwaysCovered( //NOTE: this execution fee is checked by callback contract which is not used in GAMMA version
            //     address(0),
            //     before_callbackBalance_GEN2,
            //     address(callback).balance,
            //     executionFee
            // );
        }
    }

    function _simulateWithdrawalAmount(
        Market.Props memory marketProps,
        uint amountToWithdraw,
        uint priceSeed,
        bool isAtomic
    )
        internal
        returns (
            uint simulateLongTokenAmountWithdrawal,
            uint simulateShortTokenAmountWithdrawal
        )
    {
        (
            simulateLongTokenAmountWithdrawal,
            simulateShortTokenAmountWithdrawal
        ) = ReaderWithdrawalUtils.getWithdrawalAmountOut(
            dataStore,
            marketProps,
            _getMarketPrices(
                marketProps.marketToken,
                _setTokenPrices(priceSeed)
            ),
            amountToWithdraw,
            address(0),
            isAtomic
                ? ISwapPricingUtils.SwapPricingType.Atomic
                : ISwapPricingUtils.SwapPricingType.Withdrawal      // #error-prone
        );
    }

    function _setCreateWithdrawalParams(
        address receiver,
        address callbackContract,
        address uiFeeReceiver,
        address market,
        address[] memory longTokenSwapPath,
        address[] memory shortTokenSwapPath,
        uint256 minLongTokenAmount,
        uint256 minShortTokenAmount,
        bool shouldUnwrapNativeToken,
        uint256 executionFee,
        uint256 callbackGasLimit
    ) internal pure returns (WithdrawalUtils.CreateWithdrawalParams memory) {
        WithdrawalUtils.CreateWithdrawalParams memory params = WithdrawalUtils
            .CreateWithdrawalParams({
                receiver: receiver,
                callbackContract: callbackContract,
                uiFeeReceiver: uiFeeReceiver,
                market: market,
                longTokenSwapPath: longTokenSwapPath,
                shortTokenSwapPath: shortTokenSwapPath,
                minLongTokenAmount: minLongTokenAmount,
                minShortTokenAmount: minShortTokenAmount,
                shouldUnwrapNativeToken: shouldUnwrapNativeToken,
                executionFee: executionFee,
                callbackGasLimit: callbackGasLimit
            });

        return params;
    }
}
