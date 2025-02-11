// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../../contracts/market/MarketUtils.sol";
import "../../../contracts/deposit/DepositUtils.sol";
import "./../PropertiesSetup.sol";

contract DepositSetup is PropertiesSetup {
    DepositCreated[] internal depositCreatedArray;

    /**
    //
    // GAMMA deposits
    //
    */

    function GammaDeposit(uint8 seed, uint8 userSeed, uint priceSeed) public {
        //--GAMMA REVERT DEPOSIT START
        //WITHOUT SETTING PRICES IN GMX ORACLE WE CAN NOT DEPOSIT
        TokenPrices memory tokenPrices = _setTokenPrices(priceSeed);

        OracleUtils.SetPricesParams memory oracleParams = SetOraclePrices(
            tokenPrices.tokens,
            tokenPrices.maxPrices,
            tokenPrices.minPrices
        );
        vm.prank(DEPLOYER);
        oracle.setPrices(oracleParams);
        //--GAMMA REVERT DEPOSIT END

        (address vault, , , ) = _gamma_getVault(seed);
        require(
            PerpetualVaultLens(vault).checkForCleanStart(),
            "Previous call was not executed"
        );
        uint256 amount = fl.clamp(
            priceSeed,
            PerpetualVault(vault).minDepositAmount(),
            PerpetualVault(vault).maxDepositAmount()
        );
        IERC20 collateralToken = PerpetualVault(vault).collateralToken();
        address user = _getRandomUser(userSeed);
        uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(true);

        vm.prank(user);
        collateralToken.approve(vault, type(uint256).max);

        //prank inside:)
        (bool success, bytes memory returnData) = _gamma_DepositCall(
            user,
            vault,
            amount,
            executionFee
        );

        if (returnData.length > 0) {
            fl.log(
                "Gamma deposit return data",
                abi.decode(returnData, (string))
            );
        }
        //--GAMMA REVERT DEPOSIT START
        vm.prank(DEPLOYER);
        oracle.clearAllPrices();
        //--GAMMA REVERT DEPOSIT START

        require(success, "Deposit to Gamma failed");
    }

    function GammaCancelDeposit(uint8 seed) public {
        (address vault, , , ) = _gamma_getVault(seed);

        (bool success, bytes memory returnData) = _gamma_CanceDepositCall(
            vault,
            gammaKeeper
        );
        require(success, "Cancel Deposit failed ");
    }
    function GammaDepositAmount(
        uint8 seed,
        uint8 userSeed,
        uint priceSeed,
        uint specificAmount
    ) public {
        //--GAMMA REVERT DEPOSIT START
        TokenPrices memory tokenPrices = _setTokenPrices(priceSeed);

        OracleUtils.SetPricesParams memory oracleParams = SetOraclePrices(
            tokenPrices.tokens,
            tokenPrices.maxPrices,
            tokenPrices.minPrices
        );
        vm.prank(DEPLOYER);
        oracle.setPrices(oracleParams);
        //--GAMMA REVERT DEPOSIT END

        (address vault, , , ) = _gamma_getVault(seed);
        require(
            PerpetualVaultLens(vault).checkForCleanStart(),
            "Previous call was not executed"
        );

        IERC20 collateralToken = PerpetualVault(vault).collateralToken();
        address user = _getRandomUser(userSeed);
        uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(true);

        vm.prank(user);
        collateralToken.approve(vault, type(uint256).max);

        //prank inside:)
        (bool success, bytes memory returnData) = _gamma_DepositCall(
            user,
            vault,
            specificAmount,
            executionFee
        );

        if (returnData.length > 0) {
            fl.log(
                "Gamma deposit return data",
                abi.decode(returnData, (string))
            );
        }
        //--GAMMA REVERT DEPOSIT START
        vm.prank(DEPLOYER);
        oracle.clearAllPrices();
        //--GAMMA REVERT DEPOSIT START

        require(success, "Deposit to Gamma failed");
    }

    /**
    //
    // GMX deposits
    //
    */

    function CreateDeposit(
        uint8 marketIndex,
        uint8 userIndex,
        uint longAmount,
        uint shortAmount,
        uint priceSeed,
        uint executionFee,
        uint8 swapPathSeed
    ) public returns (DepositCreated memory depositCreated) {
        depositCreated = _createDeposit(
            marketIndex,
            userIndex,
            longAmount,
            shortAmount,
            priceSeed,
            SWAPS_ENABLED ? swapPathSeed : 7, //7 is empty swap path
            executionFee,
            false
        );
        return depositCreated;
    }

    function _createDeposit(
        uint8 marketIndex,
        uint8 userIndex,
        uint longAmount,
        uint shortAmount,
        uint priceSeed,
        uint8 swapPathSeed,
        uint executionFee,
        bool InitialDeposit
    ) internal returns (DepositCreated memory depositCreated) {
        executionFee = FIXED_EXECUTION_FEE_AMOUNT;

        if (!SWAPS_ENABLED) {
            swapPathSeed = 7;
        }
        //avoiding stack too deep
        depositCreated.longSwapPath = _getSwapPath(swapPathSeed);
        depositCreated.shortSwapPath = _getSwapPath(
            SWAPS_ENABLED ? swapPathSeed / 5 : 7
        ); //another path

        address user = _getRandomUser(userIndex);
        address market = _getMarketAddress(marketIndex);

        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            market
        );

        (longAmount, shortAmount) = _getTokenAmounts(
            longAmount,
            shortAmount,
            marketProps.longToken,
            marketProps.shortToken,
            user
        );

        bool isWETH = marketProps.longToken == address(WETH) ||
            marketProps.shortToken == address(WETH);

        DepositorParams memory depositorParams = _setDepositorParams(
            user,
            longAmount,
            shortAmount,
            isWETH
        );

        DepositParams memory depositParams = _setDepositParams(
            user,
            address(callback),
            address(0), //uiFeeReceiver
            depositCreated.longSwapPath,
            depositCreated.shortSwapPath,
            1, //minMarketTokens
            false, //isWETH, not wrapping
            InitialDeposit ? 0 : FIXED_EXECUTION_FEE_AMOUNT,
            200 * 1000
        );

        depositCreated.depositorParams = depositorParams;
        depositCreated.depositParams = depositParams;
        depositCreated.beforeDepositExec.marketTotalSupply = ERC20(
            marketProps.marketToken
        ).totalSupply();
        depositCreated.beforeDepositExec.userBalanceMarket = ERC20(
            marketProps.marketToken
        ).balanceOf(depositorParams.user);

        TokenPrices memory tokenPrices = _setTokenPrices(priceSeed);
        depositCreated.tokenPrices = tokenPrices;

        (
            depositCreated.key,
            depositCreated.beforeDepositExec.simulateDepositAmountOut,
            depositCreated.createDepositParams
        ) = _createDeposit(
            depositorParams,
            depositParams,
            marketProps,
            tokenPrices,
            executionFee
        );

        depositCreatedArray.push(depositCreated);

        _checkCreateDepositCoverage(
            depositCreated.createDepositParams.market,
            depositCreated.createDepositParams.initialLongToken,
            depositCreated.createDepositParams.initialShortToken,
            depositCreated.tokenPrices,
            depositCreated.depositorParams.user,
            depositCreated.depositorParams.longAmount,
            depositCreated.depositorParams.shortAmount
        );
    }

    function _createDeposit(
        DepositorParams memory depositorParams,
        DepositParams memory depositParams,
        Market.Props memory marketProps,
        TokenPrices memory tokenPrices,
        uint executionFee
    )
        internal
        returns (
            bytes32 depositKey,
            uint simulateDepositAmountOut,
            DepositUtils.CreateDepositParams memory createDepositParams
        )
    {
        createDepositParams = _setDepositParams(depositParams, marketProps);

        _mintAndSendTokensTo(
            depositorParams.user,
            address(depositVault),
            depositorParams.longAmount,
            depositorParams.shortAmount,
            marketProps.longToken,
            marketProps.shortToken,
            executionFee,
            depositorParams.isWETH
        );

        simulateDepositAmountOut = ReaderDepositUtils.getDepositAmountOut(
            dataStore,
            marketProps,
            _getMarketPrices(marketProps.marketToken, tokenPrices),
            depositorParams.longAmount,
            depositorParams.shortAmount,
            address(0),
            ISwapPricingUtils.SwapPricingType.Deposit, // TwoStep, Shift, Atomic        // #error-prone
            false //includeVirtualInventoryImpact
        );

        bytes memory callData_CreateDeposit = abi.encodeWithSelector(
            exchangeRouter.createDeposit.selector,
            createDepositParams
        );
        vm.prank(depositorParams.user);

        (
            bool success_CreateDeposit,
            bytes memory returnData_CreateDeposit
        ) = address(exchangeRouter).call{gas: 30_000_000}(
                callData_CreateDeposit
            );

        if (!success_CreateDeposit) {
            invariantDoesNotSilentRevert(returnData_CreateDeposit);
        } else {
            depositKey = abi.decode(returnData_CreateDeposit, (bytes32));
        }
    }

    function CancelDeposit(
        uint seed,
        bool isAtomicExec
    )
        public
        returns (
            DepositState memory _before,
            DepositState memory _after,
            DepositCreated memory depositToCancel
        )
    {
        require(
            depositCreatedArray.length > 0,
            "No deposits available to cancel"
        );

        uint256 randomIndex = isAtomicExec
            ? depositCreatedArray.length - 1
            : clampBetween(seed, 0, depositCreatedArray.length - 1);

        depositToCancel = depositCreatedArray[randomIndex];

        _before = _snapDepositState(
            depositToCancel.createDepositParams.receiver,
            depositToCancel.createDepositParams.market
        );

        bytes memory callData_CancelDeposit = abi.encodeWithSelector(
            exchangeRouter.cancelDeposit.selector,
            depositToCancel.key
        );

        vm.warp(block.timestamp + REQUEST_EXPIRATION_TIME);
        vm.prank(depositToCancel.createDepositParams.receiver);

        (
            bool success_CancelDeposit,
            bytes memory returnData_CancelDeposit
        ) = address(exchangeRouter).call{gas: 30_000_000}(
                callData_CancelDeposit
            );

        if (!success_CancelDeposit) {
            invariantDoesNotSilentRevert(returnData_CancelDeposit);
        }

        _after = _snapDepositState(
            depositToCancel.createDepositParams.receiver,
            depositToCancel.createDepositParams.market
        );

        _checkCancelDepositCoverage(
            depositToCancel.createDepositParams.market,
            depositToCancel.createDepositParams.initialLongToken,
            depositToCancel.createDepositParams.initialShortToken,
            depositToCancel.tokenPrices,
            depositToCancel.depositorParams.user,
            depositToCancel.depositorParams.longAmount,
            depositToCancel.depositorParams.shortAmount
        );
    }

    function ExecuteDeposit(
        uint priceSeed,
        bool isAtomicExec
    ) public returns (DepositCreated memory, DepositState memory) {
        require(
            depositCreatedArray.length > 0,
            "No deposits available to execute"
        );

        uint256 randomIndex = isAtomicExec
            ? depositCreatedArray.length - 1
            : clampBetween(priceSeed, 0, depositCreatedArray.length - 1);

        DepositCreated memory depositToExecute = depositCreatedArray[
            randomIndex
        ];

        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            depositToExecute.createDepositParams.market
        );

        TokenPrices memory tokenPrices = _setTokenPrices(priceSeed);

        //state before recorded in DepositCreated struct on create deposit step
        DepositState memory coverageCheck = _snapDepositState(
            depositToExecute.createDepositParams.receiver,
            depositToExecute.createDepositParams.market
        );
        _executeDeposit(depositToExecute, marketProps, tokenPrices);

        //state after
        DepositState memory afterDepositExecution = _snapDepositState(
            depositToExecute.createDepositParams.receiver,
            depositToExecute.createDepositParams.market
        );

        depositCreatedArray[randomIndex] = depositCreatedArray[
            depositCreatedArray.length - 1
        ];
        depositCreatedArray.pop();

        _checkCoverageAfterDepositExecution(
            coverageCheck.market,
            coverageCheck.userBalanceMarket,
            coverageCheck.marketTotalSupply
        );

        return (depositToExecute, afterDepositExecution);
    }

    function _executeDeposit(
        DepositCreated memory depositCreated,
        Market.Props memory marketProps,
        TokenPrices memory tokenPrices
    ) internal {
        OracleUtils.SetPricesParams memory oracleParams = SetOraclePrices(
            tokenPrices.tokens,
            tokenPrices.maxPrices,
            tokenPrices.minPrices
        );

        DepositState memory _before = _snapDepositState(
            depositCreated.depositorParams.user,
            marketProps.marketToken
        );

        bytes memory callData_ExecuteDeposit = abi.encodeWithSelector(
            depositHandler.executeDeposit.selector,
            depositCreated.key,
            oracleParams
        );
        vm.prank(DEPLOYER);

        (
            bool success_ExecuteDeposit,
            bytes memory returnData_ExecuteDeposit
        ) = address(depositHandler).call{gas: 30_000_000}(
                callData_ExecuteDeposit
            );

        if (!success_ExecuteDeposit) {
            invariantDoesNotSilentRevert(returnData_ExecuteDeposit);
        }

        DepositState memory _after = _snapDepositState(
            depositCreated.depositorParams.user,
            marketProps.marketToken
        );

        require(
            _before.userBalanceMarket < _after.userBalanceMarket,
            "Deposit state was not changed"
        );
    }

    function _setDepositorParams(
        address user,
        uint256 longAmount,
        uint256 shortAmount,
        bool isWETH
    ) internal returns (DepositorParams memory) {
        DepositorParams memory depositorParams = DepositorParams({
            user: user,
            longAmount: longAmount,
            shortAmount: shortAmount,
            isWETH: isWETH
        });

        return depositorParams;
    }

    function _setDepositParams(
        address receiver,
        address callbackContract,
        address uiFeeReceiver,
        address[] memory longTokenSwapPath,
        address[] memory shortTokenSwapPath,
        uint256 minMarketTokens,
        bool shouldUnwrapNativeToken,
        uint256 executionFee,
        uint256 callbackGasLimit
    ) internal returns (DepositParams memory) {
        DepositParams memory depositParams = DepositParams({
            receiver: receiver,
            callbackContract: callbackContract,
            uiFeeReceiver: uiFeeReceiver,
            longTokenSwapPath: longTokenSwapPath,
            shortTokenSwapPath: shortTokenSwapPath,
            minMarketTokens: minMarketTokens,
            shouldUnwrapNativeToken: shouldUnwrapNativeToken,
            executionFee: executionFee,
            callbackGasLimit: callbackGasLimit
        });

        return depositParams;
    }

    function _setDepositParams(
        DepositParams memory depositParams,
        Market.Props memory marketProps
    ) internal returns (DepositUtils.CreateDepositParams memory) {
        DepositUtils.CreateDepositParams memory createDepositParams;
        createDepositParams.receiver = depositParams.receiver;
        createDepositParams.callbackContract = depositParams.callbackContract;
        createDepositParams.uiFeeReceiver = depositParams.uiFeeReceiver;
        createDepositParams.market = marketProps.marketToken;
        createDepositParams.initialLongToken = marketProps.longToken;
        createDepositParams.initialShortToken = marketProps.shortToken;
        createDepositParams.longTokenSwapPath = depositParams.longTokenSwapPath;
        createDepositParams.shortTokenSwapPath = depositParams
            .shortTokenSwapPath;
        createDepositParams.minMarketTokens = depositParams.minMarketTokens;
        createDepositParams.shouldUnwrapNativeToken = depositParams
            .shouldUnwrapNativeToken;
        createDepositParams.executionFee = depositParams.executionFee;
        createDepositParams.callbackGasLimit = depositParams.callbackGasLimit;

        return createDepositParams;
    }
}
