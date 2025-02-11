// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./OrderSetup.sol";
import "../ADLSetup.sol";

contract PositionSetup is OrderSetup, ADLSetup {
    using Price for Price.Props;

    // Function to generate calldata for both exchanges
    function generateBothExchangesCalldata(
        uint8 seed,
        bool isCollateralToIndex,
        uint priceSeed,
        uint amount
    ) internal returns (bytes[] memory) {
        (address vault, uint leverage, address market, ) = _gamma_getVault(
            seed
        );

        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            market
        );
        address tokenIn = isCollateralToIndex
            ? marketProps.shortToken
            : marketProps.indexToken;

        address tokenOut = isCollateralToIndex
            ? marketProps.indexToken
            : marketProps.shortToken;

        bytes[] memory exchangesData = new bytes[](2);
        uint256 halfAmount = amount / 2;
        uint256 remainingAmount = amount - halfAmount;

        exchangesData[0] = constructSwapCalldata(
            tokenIn,
            tokenOut,
            halfAmount,
            1,
            vault
        );
        exchangesData[1] = constructGMXCalldata(seed, remainingAmount);
        return exchangesData;
    }

    // Function to generate calldata for a single exchange
    function generateSingleExchangeCalldata(
        bool onlyParaswap,
        uint8 seed,
        bool isCollateralToIndex,
        uint amount
    ) internal returns (bytes[] memory) {
        (address vault, uint leverage, address market, ) = _gamma_getVault(
            seed
        );

        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            market
        );
        address tokenIn = isCollateralToIndex
            ? marketProps.shortToken
            : marketProps.indexToken;

        address tokenOut = isCollateralToIndex
            ? marketProps.indexToken
            : marketProps.shortToken;

        bytes[] memory exchangesData = new bytes[](1);
        if (onlyParaswap) {
            exchangesData[0] = constructSwapCalldata(
                tokenIn,
                tokenOut,
                amount,
                1,
                vault
            );
        } else {
            exchangesData[0] = constructGMXCalldata(seed, amount);
        }

        return exchangesData;
    }

    function generateAcceptablePriceExchangeCalldata(
        bool includeSwap,
        uint8 seed,
        bool isCollateralToIndex,
        uint amount,
        bool isLong
    ) internal returns (bytes[] memory) {
        (address vault, uint leverage, address market, ) = _gamma_getVault(
            seed
        );

        Market.Props memory marketProps = MarketStoreUtils.get(
            dataStore,
            market
        );
        address tokenIn = isCollateralToIndex
            ? marketProps.shortToken
            : marketProps.indexToken;

        address tokenOut = isCollateralToIndex
            ? marketProps.indexToken
            : marketProps.shortToken;

        bytes[] memory exchangesData = new bytes[](2);

        exchangesData[0] = abi.encode(isLong ? type(uint256).max : 5); //long has infinite price, shorts arbitrary small

        if (includeSwap) {
            exchangesData[1] = constructSwapCalldata(
                tokenIn,
                tokenOut,
                amount,
                1,
                vault
            );
        }

        return exchangesData;
    }

    // Wrapper function to execute the swap
    function executeSwap(
        address vault,
        address market,
        uint leverage,
        uint priceSeed,
        bytes[] memory exchangesData
    ) internal {
        MarketPrices memory convertedPrices = getConvertedMarketPrices(
            market,
            priceSeed
        );

        (, uint256 swappedBefore, ) = PerpetualVaultLens(vault).swapProgressData();

        vm.prank(gammaKeeper);
        try
            PerpetualVaultLens(vault).run(
                true, // isOpen (any)
                true, // isLong (any)
                convertedPrices,
                exchangesData
            )
        {
            (, uint256 swappedAfter, ) = PerpetualVaultLens(vault)
                .swapProgressData();
            if (PerpetualVault(vault).curPositionKey() != bytes32(0)) {
                fl.t(
                    swappedBefore == swappedAfter,
                    "GAMMA-13: The keeper should never be able to do a DEX swap or a GMX swap (any swap) when there is a nonzero curPositionKey"
                );
            }
        } catch {}
    }

    // Main function
    function SwapOrder(
        bool bothExchanges,
        bool onlyParaswap,
        uint8 seed,
        uint priceSeed,
        uint amount
    ) public {
        bytes[] memory exchangesData;
        (
            address vault,
            uint leverage,
            address market,
            address gmxUtils
        ) = _gamma_getVault(seed);

        require(
            PerpetualVaultLens(vault).checkForCleanStart(),
            "Previous call was not executed"
        );
        bool isCollateralToIndex = priceSeed % 2 == 1;

        bothExchanges = false; //NOTE: PARASWAP EXCLUDED
        onlyParaswap = false;

        if (bothExchanges) {
            exchangesData = generateBothExchangesCalldata(
                seed,
                isCollateralToIndex,
                priceSeed,
                amount
            );
        } else {
            exchangesData = generateSingleExchangeCalldata(
                onlyParaswap,
                seed,
                isCollateralToIndex,
                amount
            );
        }

        executeSwap(vault, market, leverage, priceSeed, exchangesData);
    }
    function IncreaseOrder(uint8 seed, uint priceSeed, bool isLong) public {
        (
            address vault,
            uint leverage,
            address market,
            address gmxUtils
        ) = _gamma_getVault(seed);

        IERC20 index = IERC20(PerpetualVault(vault).indexToken());

        require(
            PerpetualVaultLens(vault).checkForCleanStart(),
            "Previous call was not executed"
        );

        (, uint256 swappedBefore, ) = PerpetualVaultLens(vault).swapProgressData();
        MarketPrices memory convertedPrices = getConvertedMarketPrices(
            market,
            priceSeed
        );

        bytes[] memory data;
        if (leverage == 1) {
            bool bothExchanges = false; //NOTE: PARASWAP EXCLUDED
            bool onlyParaswap = false;

            if (bothExchanges) {
                data = generateBothExchangesCalldata(
                    seed,
                    true, //isCollateralToIndex
                    priceSeed,
                    isLong ? USDC.balanceOf(vault) : index.balanceOf(vault)
                );
            } else {
                data = generateSingleExchangeCalldata(
                    onlyParaswap,
                    seed,
                    true, //isCollateralToIndex
                    isLong ? USDC.balanceOf(vault) : index.balanceOf(vault)
                );
            }
        } else {
            data = generateAcceptablePriceExchangeCalldata(
                seed % 2 == 0 ? true : false, //includeSwap rand
                seed,
                true, //isCollateralToIndex
                isLong ? USDC.balanceOf(vault) : index.balanceOf(vault),
                isLong
            );
        }

        vm.prank(gammaKeeper);
        try
            PerpetualVaultLens(vault).run(
                true, //isOpen
                isLong, //isLong
                convertedPrices, // MarketPrices memory prices
                data
            )
        {
            (, uint256 swappedAfter, ) = PerpetualVaultLens(vault)
                .swapProgressData();
            if (PerpetualVault(vault).curPositionKey() != bytes32(0)) {
                fl.t(
                    swappedBefore == swappedAfter,
                    "GAMMA-13: The keeper should never be able to do a DEX swap or a GMX swap (any swap) when there is a nonzero curPositionKey"
                );
            }
        } catch {
            require(false, "Increase Order Run call failed");
        }
    }

    function DecreasePosition(uint8 seed, uint priceSeed, bool isLong) public {
        (
            address vault,
            uint leverage,
            address market,
            address gmxUtils
        ) = _gamma_getVault(seed);

        IERC20 index = IERC20(PerpetualVault(vault).indexToken());

        require(
            PerpetualVaultLens(vault).checkForCleanStart(),
            "Previous call was not executed"
        );
        MarketPrices memory convertedPrices = getConvertedMarketPrices(
            market,
            priceSeed
        );

        (, uint256 swappedBefore, ) = PerpetualVaultLens(vault).swapProgressData();

        bytes[] memory data;
        if (leverage == 1) {
            bool bothExchanges = false; //NOTE: PARASWAP EXCLUDED
            bool onlyParaswap = false;

            if (bothExchanges) {
                data = generateBothExchangesCalldata(
                    seed,
                    false, //isCollateralToIndex
                    priceSeed,
                    isLong ? index.balanceOf(vault) : USDC.balanceOf(vault)
                ); //priceSeed is amount seed
            } else {
                data = generateSingleExchangeCalldata(
                    onlyParaswap,
                    seed,
                    false, //isCollateralToIndex
                    isLong ? index.balanceOf(vault) : USDC.balanceOf(vault)
                );
            }
        } else {
            data = new bytes[](2);

            data[0] = abi.encode(isLong ? 5 : type(uint256).max); // inverse when decreasing
        }
        vm.prank(gammaKeeper);

        try
            PerpetualVaultLens(vault).run(
                false, //isOpen
                isLong, //isLong
                convertedPrices, // MarketPrices memory prices
                data
            )
        {
            (, uint256 swappedAfter, ) = PerpetualVaultLens(vault)
                .swapProgressData();
            if (PerpetualVault(vault).curPositionKey() != bytes32(0)) {
                fl.t(
                    swappedBefore == swappedAfter,
                    "GAMMA-13: The keeper should never be able to do a DEX swap or a GMX swap (any swap) when there is a nonzero curPositionKey"
                );
            }
        } catch {
            require(false, "DecreasePosition Run call failed");
        }
    }

    struct NextActionPerpsCache {
        IERC20 index;
        address vault;
        uint leverage;
        address market;
        address gmxUtils;
        uint256 swappedBefore;
        uint256 swappedAfter;
        bytes[] data;
        bool bothExchanges;
        bool onlyParaswap;
        bool isCollateralToIndex;
        PerpetualVault.FLOW currentFlow;
        MarketPrices convertedPrices;
    }

    function NextActionPerps(uint8 seed, uint priceSeed) public {
        NextActionPerpsCache memory cache;

        (
            cache.vault,
            cache.leverage,
            cache.market,
            cache.gmxUtils
        ) = _gamma_getVault(seed);

        cache.index = IERC20(PerpetualVault(cache.vault).indexToken());

        (, cache.swappedBefore, ) = PerpetualVaultLens(cache.vault)
            .swapProgressData();

        if (!isNextNoAction(cache.vault)) {
            if (!isNextFinalize(cache.vault) && !isNextSettle(cache.vault)) {
                if (isNextWithdraw(cache.vault)) {
                    cache.data = generateAcceptablePriceExchangeCalldata(
                        cache.index.balanceOf(cache.vault) > 0,
                        seed,
                        false, //isCollateralToIndex, false, weth => usdc
                        cache.index.balanceOf(cache.vault),
                        false //short
                    );
                } else if (cache.leverage == 1) {
                    console.log("leverage == 1");
                    if (isNextSwap(cache.vault)) {
                        console.log("isNextSwap");
                        cache.data = generateSingleExchangeCalldata(
                            false, // onlyParaswap, doing gmx
                            seed,
                            false, //isCollateralToIndex, hardcoded
                            cache.index.balanceOf(cache.vault)
                        );
                    } else if (checkNextAction(cache.vault)) {
                        //isLong

                        cache.bothExchanges = false; //NOTE: PARASWAP EXCLUDED
                        cache.onlyParaswap = false;

                        cache.isCollateralToIndex = priceSeed % 3 == 0
                            ? false
                            : true;
                        if (cache.bothExchanges) {
                            cache.data = generateBothExchangesCalldata(
                                seed,
                                cache.isCollateralToIndex,
                                priceSeed,
                                getPositionCollateral(cache.vault)
                            );
                        } else {
                            cache.data = generateSingleExchangeCalldata(
                                cache.onlyParaswap,
                                seed,
                                cache.isCollateralToIndex,
                                getPositionCollateral(cache.vault)
                            );
                        }

                        cache.currentFlow = PerpetualVault(cache.vault).flow();

                        if (cache.currentFlow == PerpetualVault.FLOW.DEPOSIT) {
                            cache.data = generateSingleExchangeCalldata(
                                false, // onlyParaswap, doing gmx
                                seed,
                                true, //isCollateralToIndex, hardcoded
                                USDC.balanceOf(cache.vault)
                            );
                        }
                    } else {
                        cache.data = generateAcceptablePriceExchangeCalldata(
                            cache.index.balanceOf(cache.vault) > 0,
                            seed,
                            false, //isCollateralToIndex weth => usdc
                            cache.index.balanceOf(cache.vault),
                            false //short
                        );
                    }
                } else {
                    cache.data = generateAcceptablePriceExchangeCalldata(
                        cache.index.balanceOf(cache.vault) > 0, //includeSwap rand
                        seed,
                        false, //isCollateralToIndex WETH => USDC
                        cache.index.balanceOf(cache.vault),
                        checkNextAction(cache.vault)
                    );
                }
            } else {
                if (
                    isNextFinalize(cache.vault) &&
                    cache.index.balanceOf(address(cache.vault)) > 0
                ) {
                    cache.data = generateAcceptablePriceExchangeCalldata(
                        cache.index.balanceOf(cache.vault) > 0,
                        seed,
                        false, //isCollateralToIndex, false, weth => usdc
                        cache.index.balanceOf(cache.vault),
                        false //short
                    );
                    // cache.bothExchanges = false; //NOTE: PARASWAP INCLUDED
                    // cache.onlyParaswap = true;

                    // cache.isCollateralToIndex = false; //hardcoded in a PerpetualVault  _runSwap(metadata, false);

                    // if (cache.bothExchanges) {
                    //     cache.data = generateBothExchangesCalldata(
                    //         seed,
                    //         cache.isCollateralToIndex,
                    //         priceSeed,
                    //         cache.index.balanceOf(address(cache.vault))
                    //     );
                    // } else {
                    //     cache.data = generateSingleExchangeCalldata(
                    //         cache.onlyParaswap,
                    //         seed,
                    //         cache.isCollateralToIndex,
                    //         cache.index.balanceOf(address(cache.vault))
                    //     );
                    // }
                }
            }
        } else {
            //NO ACTION branch, will trigger compound
            if (cache.leverage == 1) {
                cache.bothExchanges = false; //NOTE: PARASWAP INCLUDED
                cache.onlyParaswap = false;

                cache.isCollateralToIndex = true; //hardcoded in a PerpetualVault  _runSwap(metadata, true);

                if (cache.bothExchanges) {
                    cache.data = generateBothExchangesCalldata(
                        seed,
                        cache.isCollateralToIndex,
                        priceSeed,
                        USDC.balanceOf(address(cache.vault))
                    );
                } else {
                    cache.data = generateSingleExchangeCalldata(
                        cache.onlyParaswap,
                        seed,
                        cache.isCollateralToIndex,
                        USDC.balanceOf(address(cache.vault))
                    );
                }
            } else {
                cache.data = generateAcceptablePriceExchangeCalldata(
                    false, //we need just an acceptable price in this case
                    seed,
                    false,
                    0,
                    false
                );
            }
        }
        cache.convertedPrices = getConvertedMarketPrices(
            cache.market,
            priceSeed
        );
        vm.prank(gammaKeeper);
        try
            PerpetualVaultLens(cache.vault).runNextAction(
                cache.convertedPrices,
                cache.data
            )
        {
            (, cache.swappedAfter, ) = PerpetualVaultLens(cache.vault)
                .swapProgressData();
            if (PerpetualVault(cache.vault).curPositionKey() != bytes32(0)) {
                fl.t(
                    cache.swappedBefore == cache.swappedAfter,
                    "GAMMA-13: The keeper should never be able to do a DEX swap or a GMX swap (any swap) when there is a nonzero curPositionKey"
                );
            }
        } catch {
            require(false, "Next action run call failed");
        }
    }

    function ExecuteOrder(
        uint8 seed,
        uint priceSeed,
        bool isAtomicExec
    ) public {
        (address vault, , , address gmxUtils) = _gamma_getVault(seed);

        (bytes32 requestKey, ) = GmxUtils(payable(gmxUtils)).queue();

        TokenPrices memory tokenPrices = _setTokenPrices(priceSeed);

        OracleUtils.SetPricesParams memory oracleParams = SetOraclePrices(
            tokenPrices.tokens,
            tokenPrices.maxPrices,
            tokenPrices.minPrices
        );

        if (requestKey != 0) {
            PerpetualVault.FLOW currentFlow = PerpetualVault(vault).flow();
            (
                PerpetualVault.NextActionSelector currentAction,

            ) = PerpetualVault(vault).nextAction();
            _gammaBefore();

            if (currentFlow == PerpetualVault.FLOW.DEPOSIT) {
                _executeOrder(requestKey, oracleParams);
                _gammaAfter();

                _invariant_GAMMA_02(vault);
                _invariant_GAMMA_08(vault, priceSeed);
            }
            if (currentFlow == PerpetualVault.FLOW.SIGNAL_CHANGE) {
                _executeOrder(requestKey, oracleParams);
                _gammaAfter();

                _invariant_GAMMA_02(vault);
                _invariant_GAMMA_03(vault);
            }
            if (currentFlow == PerpetualVault.FLOW.WITHDRAW) {
                _executeOrder(requestKey, oracleParams);
                _gammaAfter();
                _invariant_GAMMA_02(vault);

                if (PerpetualVault(vault).curPositionKey() != bytes32(0)) {
                    fl.t(
                        currentFlow == PerpetualVault.FLOW.WITHDRAW,
                        "GAMMA-11: If withdraw function is called on a open GMX position, callback should always hit the settle case in the afterOrderExecution and afterOrderCancellation function."
                    );
                }
            }
            if (currentFlow == PerpetualVault.FLOW.COMPOUND) {
                _executeOrder(requestKey, oracleParams);
                _gammaAfter();
                _invariant_GAMMA_02(vault);
            }
            if (currentFlow == PerpetualVault.FLOW.NONE) {
                _executeOrder(requestKey, oracleParams);
                _gammaAfter();

                _invariant_GAMMA_03(vault);
            }
        } else {
            require(false, "Execute order failed");
        }

        logNextAction(vault);
    }
    function _executeOrder(
        bytes32 requestKey,
        OracleUtils.SetPricesParams memory oracleParams
    ) internal {
        bytes memory callData_ExecuteOrder = abi.encodeWithSelector(
            orderHandler.executeOrder.selector,
            requestKey,
            oracleParams
        );
        vm.prank(DEPLOYER);

        (
            bool success_ExecuteOrder,
            bytes memory returnData_ExecuteOrder
        ) = address(orderHandler).call{gas: 30_000_000}(callData_ExecuteOrder);
    }

    function CancelOrder(uint8 seed, uint priceSeed, bool isAtomicExec) public {
        (address vault, , , address gmxUtils) = _gamma_getVault(seed);

        (bytes32 requestKey, ) = GmxUtils(payable(gmxUtils)).queue();

        TokenPrices memory tokenPrices = _setTokenPrices(priceSeed);

        OracleUtils.SetPricesParams memory oracleParams = SetOraclePrices(
            tokenPrices.tokens,
            tokenPrices.maxPrices,
            tokenPrices.minPrices
        );

        if (requestKey != 0) {
            PerpetualVault.FLOW currentFlow = PerpetualVault(vault).flow();
            (
                PerpetualVault.NextActionSelector currentAction,

            ) = PerpetualVault(vault).nextAction();
            _gammaBefore();

            bytes memory callData_CancelOrder = abi.encodeWithSelector(
                orderHandler.cancelOrder.selector,
                requestKey
            );
            vm.prank(DEPLOYER);

            (
                bool success_CancelOrder,
                bytes memory returnData_CancelOrder
            ) = address(orderHandler).call{gas: 30_000_000}(
                    callData_CancelOrder
                );

            if (success_CancelOrder) {
                if (currentFlow == PerpetualVault.FLOW.WITHDRAW) {
                    fl.t(
                        currentAction ==
                            PerpetualVault.NextActionSelector.SETTLE_ACTION,
                        "GAMMA-11: If withdraw function is called on a open GMX position, callback should always hit the settle case in the afterOrderExecution and afterOrderCancellation function."
                    );
                }
            }
        }
    }
}
