// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/FuzzActors.sol";

contract FuzzSetup is FuzzActors {
    function deployment(address deployerContract) internal {
        /**
         * 0_0 *
         * --- Deploying libraries using cryticArgs in fuzzer config ---
         *
         * --- DEPLOYING CONTRACTS ---
         */

        //Role
        //for foundry
        DEPLOYER = deployerContract;

        roleStore = new RoleStore();
        roleStore.grantRole(FOUNDRY_INITIAL_ADDRESS, Role.ROLE_ADMIN); //going from contract to EOA
        roleStore.grantRole(DEPLOYER, Role.ROLE_ADMIN); //going from contract to EOA
        roleStore.grantRole(HEVM_INITIAL_ADDRESS, Role.ROLE_ADMIN); //going from contract to EOA

        /**
         * 0_0 *
         * --- Config for roles ---
         */

        _roleChangingCall(DEPLOYER, DEPLOYER, Role.CONTROLLER);
        _roleChangingCall(DEPLOYER, DEPLOYER, Role.ORDER_KEEPER);
        _roleChangingCall(DEPLOYER, DEPLOYER, Role.ADL_KEEPER);
        _roleChangingCall(DEPLOYER, DEPLOYER, Role.LIQUIDATION_KEEPER);
        _roleChangingCall(DEPLOYER, DEPLOYER, Role.MARKET_KEEPER);
        _roleChangingCall(DEPLOYER, DEPLOYER, Role.FROZEN_ORDER_KEEPER);

        _roleChangingCall(
            HEVM_INITIAL_ADDRESS,
            HEVM_INITIAL_ADDRESS,
            Role.CONTROLLER
        ); //To avoid unnesessary prank calls
        _roleChangingCall(
            HEVM_INITIAL_ADDRESS,
            HEVM_INITIAL_ADDRESS,
            Role.ORDER_KEEPER
        );
        _roleChangingCall(
            HEVM_INITIAL_ADDRESS,
            HEVM_INITIAL_ADDRESS,
            Role.ADL_KEEPER
        );
        _roleChangingCall(
            HEVM_INITIAL_ADDRESS,
            HEVM_INITIAL_ADDRESS,
            Role.LIQUIDATION_KEEPER
        );
        _roleChangingCall(
            HEVM_INITIAL_ADDRESS,
            HEVM_INITIAL_ADDRESS,
            Role.MARKET_KEEPER
        );
        _roleChangingCall(
            HEVM_INITIAL_ADDRESS,
            HEVM_INITIAL_ADDRESS,
            Role.FROZEN_ORDER_KEEPER
        );

        /**
         * 0_0 *
         * --- Deploy and mock tokens ---
         */
        dataStore = new DataStore(roleStore);

        WETH = new WNT();
        // vm.label(address(WETH), "WETH");

        WBTC = new MintableToken("Wrapped Bitcoin", "WBTC", 8);
        // vm.label(address(WBTC), "WBTC");

        USDC = new MintableToken("USD Circle", "USDC", 6);
        // vm.label(address(USDC), "USDC");

        USDT = new MintableToken("USD Tether", "USDT", 6);
        // vm.label(address(USDT), "USDT");

        /**
         * 0_0 *
         * --- Configure Data Store ---
         */
        _setUintDataStoreCall(
            DEPLOYER,
            "TOKEN_TRANSFER_GAS_LIMIT",
            WETH_TOKEN_TRANSFER_GAS_LIMIT,
            address(WETH)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "TOKEN_TRANSFER_GAS_LIMIT",
            WBTC_TOKEN_TRANSFER_GAS_LIMIT,
            address(WBTC)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "TOKEN_TRANSFER_GAS_LIMIT",
            USDC_TOKEN_TRANSFER_GAS_LIMIT,
            address(USDC)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "TOKEN_TRANSFER_GAS_LIMIT",
            USDT_TOKEN_TRANSFER_GAS_LIMIT,
            address(USDT)
        );

        _setAddressDataStoreCall(DEPLOYER, "WNT", address(WETH), address(0));
        _setAddressDataStoreCall(
            DEPLOYER,
            "FEE_RECEIVER",
            address(0),
            address(0)
        );
        _setAddressDataStoreCall(
            DEPLOYER,
            "HOLDING_ADDRESS",
            address(0),
            address(0)
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_UI_FEE_FACTOR",
            MAX_UI_FEE_FACTOR,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_AUTO_CANCEL_ORDERS",
            MAX_AUTO_CANCEL_ORDERS,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_HANDLE_EXECUTION_ERROR_GAS",
            MIN_HANDLE_EXECUTION_ERROR_GAS,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_HANDLE_EXECUTION_ERROR_GAS_TO_FORWARD",
            MIN_HANDLE_EXECUTION_ERROR_GAS_TO_FORWARD,
            address(0)
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_ADDITIONAL_GAS_FOR_EXECUTION",
            MIN_ADDITIONAL_GAS_FOR_EXECUTION,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_CALLBACK_GAS_LIMIT",
            MAX_CALLBACK_GAS_LIMIT,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_SWAP_PATH_LENGTH",
            MAX_SWAP_PATH_LENGTH,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_COLLATERAL_USD",
            MIN_COLLATERAL_USD,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_POSITION_SIZE_USD",
            MIN_POSITION_SIZE_USD,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "SWAP_FEE_RECEIVER_FACTOR",
            SWAP_FEE_RECEIVER_FACTOR,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "POSITION_FEE_RECEIVER_FACTOR",
            POSITION_FEE_RECEIVER_FACTOR,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "CLAIMABLE_COLLATERAL_TIME_DIVISOR",
            CLAIMABLE_COLLATERAL_TIME_DIVISOR,
            address(0)
        );
        _setUintWithBoolDataStoreCall(
            DEPLOYER,
            "DEPOSIT_GAS_LIMIT",
            DEPOSIT_GAS_LIMIT,
            true
        );
        _setUintWithBoolDataStoreCall(
            DEPLOYER,
            "DEPOSIT_GAS_LIMIT",
            DEPOSIT_GAS_LIMIT,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "WITHDRAWAL_GAS_LIMIT",
            WITHDRAWAL_GAS_LIMIT,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "SINGLE_SWAP_GAS_LIMIT",
            SINGLE_SWAP_GAS_LIMIT,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "INCREASE_ORDER_GAS_LIMIT",
            INCREASE_ORDER_GAS_LIMIT,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "DECREASE_ORDER_GAS_LIMIT",
            DECREASE_ORDER_GAS_LIMIT,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "SWAP_ORDER_GAS_LIMIT",
            SWAP_ORDER_GAS_LIMIT,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "NATIVE_TOKEN_TRANSFER_GAS_LIMIT",
            NATIVE_TOKEN_TRANSFER_GAS_LIMIT,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "ESTIMATED_GAS_FEE_BASE_AMOUNT",
            ESTIMATED_GAS_FEE_BASE_AMOUNT,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "ESTIMATED_GAS_FEE_BASE_AMOUNT_V2_1",
            ESTIMATED_GAS_FEE_BASE_AMOUNT_V2_1,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "EXECUTION_GAS_FEE_MULTIPLIER_FACTOR",
            EXECUTION_GAS_FEE_MULTIPLIER_FACTOR,
            address(0)
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "REFUND_EXECUTION_FEE_GAS_LIMIT",
            REFUND_EXECUTION_FEE_GAS_LIMIT,
            address(0)
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "EXECUTION_GAS_FEE_PER_ORACLE_PRICE",
            EXECUTION_GAS_FEE_PER_ORACLE_PRICE,
            address(0)
        );

        _setBoolDataStoreCall(
            DEPLOYER,
            "SKIP_BORROWING_FEE_FOR_SMALLER_SIDE",
            SKIP_BORROWING_FEE_FOR_SMALLER_SIDE,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "REQUEST_EXPIRATION_TIME",
            REQUEST_EXPIRATION_TIME,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "ESTIMATED_GAS_FEE_PER_ORACLE_PRICE",
            ESTIMATED_GAS_FEE_PER_ORACLE_PRICE,
            address(0)
        );
        /**
         * 0_0 *
         * --- Setup Timelock Controller ---
         */
        govTimelockController = new GovTimelockController(
            "GovTimelockController", //name
            5 * 24 * 60 * 60, // minDelay
            USERS, //proposer
            USERS, //executor
            DEPLOYER //admin
        );

        bytes32 PROPOSER_ROLE = govTimelockController.PROPOSER_ROLE();
        vm.prank(DEPLOYER);
        govTimelockController.grantRole(
            PROPOSER_ROLE,
            address(protocolGovernor)
        );

        bytes32 CANCELLER_ROLE = govTimelockController.CANCELLER_ROLE();
        vm.prank(DEPLOYER);
        govTimelockController.grantRole(
            CANCELLER_ROLE,
            address(protocolGovernor)
        );

        bytes32 EXECUTOR_ROLE = govTimelockController.EXECUTOR_ROLE();
        vm.prank(DEPLOYER);
        govTimelockController.grantRole(
            EXECUTOR_ROLE,
            address(protocolGovernor)
        );

        // bytes32 TIMELOCK_ADMIN_ROLE = govTimelockController.TIMELOCK_ADMIN_ROLE();
        // vm.prank(DEPLOYER);
        //  govTimelockController.revokeRole(TIMELOCK_ADMIN_ROLE, DEPLOYER);

        /**
         * 0_0 *
         * --- Deploy gov contracts ---
         */
        govToken = new GovToken(
            roleStore,
            "GMX DAO", // name
            "GMX_DAO", // symbol
            18
        ); // decimals

        //@dev all values from ProtocolGovenor.ts test file,
        //@dev test file have much smaller proposalTreshold
        /**
         * values from deployProtocolGovernor.ts
         *  return [
         *   dependencyContracts.GovToken.address, // token
         *   dependencyContracts.GovTimelockController.address, // timelock
         *   "GMX Governor", // name
         *   "v2.0", // version
         *   24 * 60 * 60, // votingDelay
         *   5 * 24 * 60 * 60, // votingPeriod
         *   expandDecimals(30_000, 18), // proposalThreshold
         *   3, // quorumNumeratorValue
         * ];
         */
        protocolGovernor = new ProtocolGovernor(
            govToken,
            govTimelockController, // timelock
            "Governor", // name
            "v1", // version
            24 * 60 * 60, // votingDelay
            6 * 24 * 60 * 60, // votingPeriod
            50_000, // proposalThreshold
            4 // quorumNumeratorValue);
        );

        eventEmitter = new EventEmitter(roleStore);

        /**
         * 0_0 *
         * --- Oracle setup ---
         */
        oracleStore = new OracleStore(roleStore, eventEmitter);
        _roleChangingCall(DEPLOYER, address(oracleStore), Role.CONTROLLER);

        _oracleAddSignerCall(DEPLOYER, USER4);
        _oracleAddSignerCall(DEPLOYER, USER5);
        _oracleAddSignerCall(DEPLOYER, USER6);
        _oracleAddSignerCall(DEPLOYER, USER7);
        _oracleAddSignerCall(DEPLOYER, USER8);
        _oracleAddSignerCall(DEPLOYER, USER9);
        _oracleAddSignerCall(DEPLOYER, USER10);
        _oracleAddSignerCall(DEPLOYER, USER11);
        _oracleAddSignerCall(DEPLOYER, USER12);
        _oracleAddSignerCall(DEPLOYER, USER13);

        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_ORACLE_SIGNERS",
            MIN_ORACLE_SIGNERS,
            address(0)
        );

        USDCPriceFeed = new MockPriceFeed();
        USDCPriceFeed.setAnswer(USDC_INIT_PRICE);

        USDTPriceFeed = new MockPriceFeed();
        USDTPriceFeed.setAnswer(USDT_INIT_PRICE);

        gmOracleProvider = new GmOracleProvider(
            roleStore,
            dataStore,
            oracleStore
        );

        chainlinkMock = new ChainlinkMock();

        _setBoolDataStoreCall(
            DEPLOYER,
            "IS_ORACLE_PROVIDER_ENABLED",
            IS_ORACLE_PROVIDER_ENABLED,
            address(0)
        );

        mockDataStreamVerifier = new MockDataStreamVerifier();
        chainlinkPriceFeedProvider = new ChainlinkPriceFeedProvider(dataStore);

        _setBoolDataStoreCall(
            DEPLOYER,
            "IS_ORACLE_PROVIDER_ENABLED",
            IS_ORACLE_PROVIDER_ENABLED,
            address(chainlinkPriceFeedProvider)
        );
        _setBoolDataStoreCall(
            DEPLOYER,
            "IS_ATOMIC_ORACLE_PROVIDER",
            IS_ATOMIC_ORACLE_PROVIDER,
            address(chainlinkPriceFeedProvider)
        );

        _setBoolDataStoreCall(
            DEPLOYER,
            "IS_ORACLE_PROVIDER_ENABLED",
            IS_ORACLE_PROVIDER_ENABLED,
            address(chainlinkMock)
        );
        _setBoolDataStoreCall(
            DEPLOYER,
            "IS_ATOMIC_ORACLE_PROVIDER",
            IS_ATOMIC_ORACLE_PROVIDER,
            address(chainlinkMock)
        );

        oracle = new Oracle(
            roleStore,
            dataStore,
            eventEmitter,
            AggregatorV2V3Interface(address(0)) //sequencer uptime feed AggregatorV2V3Interface
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_ORACLE_BLOCK_CONFIRMATIONS",
            MIN_ORACLE_BLOCK_CONFIRMATIONS,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_ORACLE_TIMESTAMP_RANGE",
            MAX_ORACLE_TIMESTAMP_RANGE,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_ORACLE_REF_PRICE_DEVIATION_FACTOR",
            MAX_ORACLE_REF_PRICE_DEVIATION_FACTOR,
            address(0)
        );
        _setAddressDataStoreCall(
            DEPLOYER,
            "CHAINLINK_PAYMENT_TOKEN",
            CHAINLINK_PAYMENT_TOKEN,
            address(0)
        );

        _roleChangingCall(DEPLOYER, address(oracle), Role.CONTROLLER);

        chainlinkDataStreamProvider = new ChainlinkDataStreamProvider(
            dataStore,
            address(oracle),
            mockDataStreamVerifier
        );

        _setBoolDataStoreCall(
            DEPLOYER,
            "IS_ORACLE_PROVIDER_ENABLED",
            IS_ORACLE_PROVIDER_ENABLED,
            address(chainlinkDataStreamProvider)
        );

        _setBytes32DataStoreCall(
            DEPLOYER,
            "ORACLE_TYPE",
            address(USDC),
            ORACLE_TYPE_DEFAULT
        );
        _setAddressDataStoreCall(
            DEPLOYER,
            "ORACLE_PROVIDER_FOR_TOKEN",
            address(gmOracleProvider),
            address(USDC)
        ); //KEY is a string + USDC(added address for a key)
        _setAddressDataStoreCall(
            DEPLOYER,
            "PRICE_FEED",
            address(USDCPriceFeed),
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "PRICE_FEED_MULTIPLIER",
            PRICE_FEED_MULTIPLIER,
            address(USDC)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "PRICE_FEED_HEARTBEAT_DURATION",
            PRICE_FEED_HEARTBEAT_DURATION,
            address(USDC)
        );

        _setBytes32DataStoreCall(
            DEPLOYER,
            "ORACLE_TYPE",
            address(USDT),
            ORACLE_TYPE_DEFAULT
        );
        _setAddressDataStoreCall(
            DEPLOYER,
            "ORACLE_PROVIDER_FOR_TOKEN",
            address(gmOracleProvider),
            address(USDT)
        );
        _setAddressDataStoreCall(
            DEPLOYER,
            "PRICE_FEED",
            address(USDTPriceFeed),
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "PRICE_FEED_MULTIPLIER",
            PRICE_FEED_MULTIPLIER,
            address(USDT)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "PRICE_FEED_HEARTBEAT_DURATION",
            PRICE_FEED_HEARTBEAT_DURATION,
            address(USDT)
        );

        _setBytes32DataStoreCall(
            DEPLOYER,
            "ORACLE_TYPE",
            address(WETH),
            ORACLE_TYPE_DEFAULT
        );
        _setAddressDataStoreCall(
            DEPLOYER,
            "ORACLE_PROVIDER_FOR_TOKEN",
            address(gmOracleProvider),
            address(WETH)
        );

        _setBytes32DataStoreCall(
            DEPLOYER,
            "ORACLE_TYPE",
            address(WBTC),
            ORACLE_TYPE_DEFAULT
        );
        _setAddressDataStoreCall(
            DEPLOYER,
            "ORACLE_PROVIDER_FOR_TOKEN",
            address(gmOracleProvider),
            address(WBTC)
        );

        _setBytes32DataStoreCall(
            DEPLOYER,
            "ORACLE_TYPE",
            address(SOL),
            ORACLE_TYPE_DEFAULT
        ); //synthetic address
        _setAddressDataStoreCall(
            DEPLOYER,
            "ORACLE_PROVIDER_FOR_TOKEN",
            address(gmOracleProvider),
            address(SOL)
        );

        /**
         * 0_0 *
         * --- Adding custom ChainLink mock---
         */
        _setBytes32DataStoreCall(
            DEPLOYER,
            "ORACLE_TYPE",
            address(USDT),
            ORACLE_TYPE_DEFAULT
        );
        _setAddressDataStoreCall(
            DEPLOYER,
            "ORACLE_PROVIDER_FOR_TOKEN",
            address(chainlinkMock),
            address(USDT)
        );

        _setBytes32DataStoreCall(
            DEPLOYER,
            "ORACLE_TYPE",
            address(USDC),
            ORACLE_TYPE_DEFAULT
        );
        _setAddressDataStoreCall(
            DEPLOYER,
            "ORACLE_PROVIDER_FOR_TOKEN",
            address(chainlinkMock),
            address(USDC)
        );
        _setBytes32DataStoreCall(
            DEPLOYER,
            "ORACLE_TYPE",
            address(WETH),
            ORACLE_TYPE_DEFAULT
        );
        _setAddressDataStoreCall(
            DEPLOYER,
            "ORACLE_PROVIDER_FOR_TOKEN",
            address(chainlinkMock),
            address(WETH)
        );

        _setBytes32DataStoreCall(
            DEPLOYER,
            "ORACLE_TYPE",
            address(WBTC),
            ORACLE_TYPE_DEFAULT
        );
        _setAddressDataStoreCall(
            DEPLOYER,
            "ORACLE_PROVIDER_FOR_TOKEN",
            address(chainlinkMock),
            address(WBTC)
        );

        _setBytes32DataStoreCall(
            DEPLOYER,
            "ORACLE_TYPE",
            address(SOL),
            ORACLE_TYPE_DEFAULT
        ); //synthetic address
        _setAddressDataStoreCall(
            DEPLOYER,
            "ORACLE_PROVIDER_FOR_TOKEN",
            address(chainlinkMock),
            address(SOL)
        );

        /**
         * 0_0 *
         * --- Deploy order related contracts ---
         */
        orderVault = new OrderVault(roleStore, dataStore);
        swapHandler = new SwapHandler(roleStore);
        _roleChangingCall(DEPLOYER, address(swapHandler), Role.CONTROLLER);

        referralStorage = new ReferralStorage();
        referralStorage.setTier(0, 1000, 5000);
        referralStorage.setTier(1, 2000, 5000);
        referralStorage.setTier(0, 2500, 4000);

        adlHandler = new AdlHandler(
            roleStore,
            dataStore,
            eventEmitter,
            oracle,
            orderVault,
            swapHandler,
            referralStorage
        );
        _roleChangingCall(DEPLOYER, address(adlHandler), Role.CONTROLLER);

        marketFactory = new MarketFactory(roleStore, dataStore, eventEmitter);
        _roleChangingCall(DEPLOYER, address(marketFactory), Role.CONTROLLER);

        config = new Config(roleStore, dataStore, eventEmitter);
        _roleChangingCall(DEPLOYER, address(config), Role.CONTROLLER);

        /**
         * 0_0 *
         * --- Deploy deposit related contracts ---
         */
        depositVault = new DepositVault(roleStore, dataStore);
        depositHandler = new DepositHandler(
            roleStore,
            dataStore,
            eventEmitter,
            oracle,
            depositVault
        );
        _roleChangingCall(DEPLOYER, address(depositHandler), Role.CONTROLLER);

        router = new Router(roleStore);

        /**
         * 0_0 *
         * --- Deploy withdrawal related contracts ---
         */
        withdrawalVault = new WithdrawalVault(roleStore, dataStore);
        withdrawalHandler = new WithdrawalHandler(
            roleStore,
            dataStore,
            eventEmitter,
            oracle,
            withdrawalVault
        );
        _roleChangingCall(
            DEPLOYER,
            address(withdrawalHandler),
            Role.CONTROLLER
        );

        /**
         * 0_0 *
         * --- Deploy shift related contracts ---
         */
        shiftVault = new ShiftVault(roleStore, dataStore);
        shiftHandler = new ShiftHandler(
            roleStore,
            dataStore,
            eventEmitter,
            oracle,
            shiftVault
        );
        _roleChangingCall(DEPLOYER, address(shiftHandler), Role.CONTROLLER);

        orderHandler = new OrderHandler(
            roleStore,
            dataStore,
            eventEmitter,
            oracle,
            orderVault,
            swapHandler,
            referralStorage
        );

        referralStorage.setHandler(address(orderHandler), true);

        _roleChangingCall(DEPLOYER, address(orderHandler), Role.CONTROLLER);

        externalHandler = new ExternalHandler();

        exchangeRouter = new ExchangeRouter(
            router,
            roleStore,
            dataStore,
            eventEmitter,
            depositHandler,
            withdrawalHandler,
            shiftHandler,
            orderHandler,
            externalHandler
        );

        _roleChangingCall(DEPLOYER, address(exchangeRouter), Role.CONTROLLER);
        _roleChangingCall(
            DEPLOYER,
            address(exchangeRouter),
            Role.ROUTER_PLUGIN
        );

        MockVaultGovV1 mockVaultGovV1 = new MockVaultGovV1();
        MockVaultV1 mockVaultV1 = new MockVaultV1(address(mockVaultGovV1));

        feeHandler = new FeeHandler(
            roleStore,
            oracle,
            dataStore,
            eventEmitter,
            IVaultV1(address(mockVaultV1)),
            address(0)      // #error-prone
        );
        _roleChangingCall(DEPLOYER, address(feeHandler), Role.CONTROLLER);

        liquidationHandler = new LiquidationHandler(
            roleStore,
            dataStore,
            eventEmitter,
            oracle,
            orderVault,
            swapHandler,
            referralStorage
        );
        _roleChangingCall(
            DEPLOYER,
            address(liquidationHandler),
            Role.CONTROLLER
        );

        //Simple price feed
        mockPriceFeed = new MockPriceFeed();
        multicall3 = new Multicall3();

        /**
         * 0_0 *
         * --- Deploy reader related contracts ---
         */
        subaccountRouter = new SubaccountRouter(
            router,
            roleStore,
            dataStore,
            eventEmitter,
            orderHandler,
            orderVault
        );
        _roleChangingCall(DEPLOYER, address(subaccountRouter), Role.CONTROLLER);
        _roleChangingCall(
            DEPLOYER,
            address(subaccountRouter),
            Role.ROUTER_PLUGIN
        );

        timelock = new Timelock(
            roleStore,
            dataStore,
            eventEmitter,
            oracleStore,
            24 * 60 * 60 //timelockDelay
        );
        _roleChangingCall(DEPLOYER, address(timelock), Role.CONTROLLER);
        _roleChangingCall(DEPLOYER, address(timelock), Role.ROLE_ADMIN);

        timestampInitializer = new TimestampInitializer(
            roleStore,
            dataStore,
            eventEmitter
        );
        _roleChangingCall(
            DEPLOYER,
            address(timestampInitializer),
            Role.CONTROLLER
        );

        reader = new Reader();
    }

    function marketsSetup() internal {
        /**
         * 0_0 *
         * --- New markets, should include all supported combinations ---
         */
        market_WETH_WETH_USDC = marketFactory
            .createMarket(
                address(WETH),
                address(WETH),
                address(USDC),
                DEFAULT_MARKET_TYPE
            )
            .marketToken;
        // vm.label(address(market_WETH_WETH_USDC), "market_WETH_WETH_USDC");

        market_WETH_WETH_USDT = marketFactory
            .createMarket(
                address(WETH),
                address(WETH),
                address(USDT),
                DEFAULT_MARKET_TYPE
            )
            .marketToken;
        // vm.label(address(market_WETH_WETH_USDT), "market_WETH_WETH_USDT");

        market_0_WETH_USDC = marketFactory
            .createMarket(
                address(0),
                address(WETH),
                address(USDC),
                DEFAULT_MARKET_TYPE
            )
            .marketToken;
        // vm.label(address(market_0_WETH_USDC), "market_0_WETH_USDC");

        market_WBTC_WBTC_USDC = marketFactory
            .createMarket(
                address(WBTC),
                address(WBTC),
                address(USDC),
                DEFAULT_MARKET_TYPE
            )
            .marketToken;
        // vm.label(address(market_WBTC_WBTC_USDC), "market_WBTC_WBTC_USDC");

        /**
         * 0_0 *
         * --- Config for market_WETH_WETH_USDC ---
         */
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_AMOUNT",
            MAX_POOL_AMOUNT_WETH,
            market_WETH_WETH_USDC,
            address(WETH)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_AMOUNT",
            MAX_POOL_AMOUNT_USDC,
            market_WETH_WETH_USDC,
            address(USDC)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_USD_FOR_DEPOSIT",
            MAX_POOL_USD_FOR_DEPOSIT_WETH,
            market_WETH_WETH_USDC,
            address(WETH)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_USD_FOR_DEPOSIT",
            MAX_POOL_USD_FOR_DEPOSIT_USDC,
            market_WETH_WETH_USDC,
            address(USDC)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_COLLATERAL_FACTOR",
            MIN_COLLATERAL_FACTOR,
            market_WETH_WETH_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER",
            MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER_LONG,
            market_WETH_WETH_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER",
            MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER_SHORT,
            market_WETH_WETH_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_OPEN_INTEREST",
            MAX_OPEN_INTEREST_LONG,
            market_WETH_WETH_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_OPEN_INTEREST",
            MAX_OPEN_INTEREST_SHORT,
            market_WETH_WETH_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "RESERVE_FACTOR",
            RESERVE_FACTOR_LONG,
            market_WETH_WETH_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "RESERVE_FACTOR",
            RESERVE_FACTOR_SHORT,
            market_WETH_WETH_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "OPEN_INTEREST_RESERVE_FACTOR",
            OPEN_INTEREST_RESERVE_FACTOR_LONG,
            market_WETH_WETH_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "OPEN_INTEREST_RESERVE_FACTOR",
            OPEN_INTEREST_RESERVE_FACTOR_SHORT,
            market_WETH_WETH_USDC,
            false
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_TRADERS",
            MAX_PNL_FACTOR_FOR_TRADERS_LONG,
            market_WETH_WETH_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_TRADERS",
            MAX_PNL_FACTOR_FOR_TRADERS_SHORT,
            market_WETH_WETH_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_ADL",
            MAX_PNL_FACTOR_FOR_ADL_LONG,
            market_WETH_WETH_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_ADL",
            MAX_PNL_FACTOR_FOR_ADL_SHORT,
            market_WETH_WETH_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_PNL_FACTOR_AFTER_ADL",
            MIN_PNL_FACTOR_AFTER_ADL_LONG,
            market_WETH_WETH_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_PNL_FACTOR_AFTER_ADL",
            MIN_PNL_FACTOR_AFTER_ADL_SHORT,
            market_WETH_WETH_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_DEPOSITS",
            MAX_PNL_FACTOR_FOR_DEPOSITS_LONG,
            market_WETH_WETH_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_DEPOSITS",
            MAX_PNL_FACTOR_FOR_DEPOSITS_SHORT,
            market_WETH_WETH_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_WITHDRAWALS",
            MAX_PNL_FACTOR_FOR_WITHDRAWALS_LONG,
            market_WETH_WETH_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_WITHDRAWALS",
            MAX_PNL_FACTOR_FOR_WITHDRAWALS_SHORT,
            market_WETH_WETH_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "TOKEN_TRANSFER_GAS_LIMIT",
            MARKET_TOKEN_TRANSFER_GAS_LIMIT,
            market_WETH_WETH_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POSITION_IMPACT_FACTOR_FOR_LIQUIDATIONS",
            MAX_POSITION_IMPACT_FACTOR_FOR_LIQUIDATIONS,
            market_WETH_WETH_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "POSITION_IMPACT_FACTOR",
            POSITION_IMPACT_FACTOR_POSITIVE,
            market_WETH_WETH_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "POSITION_IMPACT_FACTOR",
            POSITION_IMPACT_FACTOR_NEGATIVE,
            market_WETH_WETH_USDC,
            false
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "SWAP_FEE_FACTOR",
            SWAP_FEE_FACTOR_POSITIVE_IMPACT,
            market_WETH_WETH_USDC,
            true
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "SWAP_FEE_FACTOR",
            SWAP_FEE_FACTOR_NEGATIVE_IMPACT,
            market_WETH_WETH_USDC,
            false
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "ATOMIC_SWAP_FEE_FACTOR",
            ATOMIC_SWAP_FEE_FACTOR,
            market_WETH_WETH_USDC
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_FACTOR",
            FUNDING_FACTOR,
            market_WETH_WETH_USDC
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_EXPONENT_FACTOR",
            FUNDING_EXPONENT_FACTOR,
            market_WETH_WETH_USDC
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "THRESHOLD_FOR_STABLE_FUNDING",
            THRESHOLD_FOR_STABLE_FUNDING,
            market_WETH_WETH_USDC
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "THRESHOLD_FOR_DECREASE_FUNDING",
            THRESHOLD_FOR_DECREASE_FUNDING,
            market_WETH_WETH_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_INCREASE_FACTOR_PER_SECOND",
            FUNDING_INCREASE_FACTOR_PER_SECOND,
            market_WETH_WETH_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_DECREASE_FACTOR_PER_SECOND",
            FUNDING_DECREASE_FACTOR_PER_SECOND,
            market_WETH_WETH_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_FUNDING_FACTOR_PER_SECOND",
            MAX_FUNDING_FACTOR_PER_SECOND,
            market_WETH_WETH_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_INCREASE_FACTOR_PER_SECOND",
            FUNDING_DECREASE_FACTOR_PER_SECOND,
            market_WETH_WETH_USDC
        );

        /**
         * 0_0 *
         * --- Config for market_WETH_WETH_USDT ---
         */
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_AMOUNT",
            MAX_POOL_AMOUNT_WETH,
            market_WETH_WETH_USDT,
            address(WETH)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_AMOUNT",
            MAX_POOL_AMOUNT_USDT,
            market_WETH_WETH_USDT,
            address(USDT)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_USD_FOR_DEPOSIT",
            MAX_POOL_USD_FOR_DEPOSIT_WETH,
            market_WETH_WETH_USDT,
            address(WETH)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_USD_FOR_DEPOSIT",
            MAX_POOL_AMOUNT_USDT,
            market_WETH_WETH_USDT,
            address(USDT)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_COLLATERAL_FACTOR",
            MIN_COLLATERAL_FACTOR,
            market_WETH_WETH_USDT
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER",
            MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER_LONG,
            market_WETH_WETH_USDT,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER",
            MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER_SHORT,
            market_WETH_WETH_USDT,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_OPEN_INTEREST",
            MAX_OPEN_INTEREST_LONG,
            market_WETH_WETH_USDT,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_OPEN_INTEREST",
            MAX_OPEN_INTEREST_SHORT,
            market_WETH_WETH_USDT,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "RESERVE_FACTOR",
            RESERVE_FACTOR_LONG,
            market_WETH_WETH_USDT,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "RESERVE_FACTOR",
            RESERVE_FACTOR_SHORT,
            market_WETH_WETH_USDT,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "OPEN_INTEREST_RESERVE_FACTOR",
            OPEN_INTEREST_RESERVE_FACTOR_LONG,
            market_WETH_WETH_USDT,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "OPEN_INTEREST_RESERVE_FACTOR",
            OPEN_INTEREST_RESERVE_FACTOR_SHORT,
            market_WETH_WETH_USDT,
            false
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_TRADERS",
            MAX_PNL_FACTOR_FOR_TRADERS_LONG,
            market_WETH_WETH_USDT,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_TRADERS",
            MAX_PNL_FACTOR_FOR_TRADERS_SHORT,
            market_WETH_WETH_USDT,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_ADL",
            MAX_PNL_FACTOR_FOR_ADL_LONG,
            market_WETH_WETH_USDT,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_ADL",
            MAX_PNL_FACTOR_FOR_ADL_SHORT,
            market_WETH_WETH_USDT,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_PNL_FACTOR_AFTER_ADL",
            MIN_PNL_FACTOR_AFTER_ADL_LONG,
            market_WETH_WETH_USDT,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_PNL_FACTOR_AFTER_ADL",
            MIN_PNL_FACTOR_AFTER_ADL_SHORT,
            market_WETH_WETH_USDT,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_DEPOSITS",
            MAX_PNL_FACTOR_FOR_DEPOSITS_LONG,
            market_WETH_WETH_USDT,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_DEPOSITS",
            MAX_PNL_FACTOR_FOR_DEPOSITS_SHORT,
            market_WETH_WETH_USDT,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_WITHDRAWALS",
            MAX_PNL_FACTOR_FOR_WITHDRAWALS_LONG,
            market_WETH_WETH_USDT,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_WITHDRAWALS",
            MAX_PNL_FACTOR_FOR_WITHDRAWALS_SHORT,
            market_WETH_WETH_USDT,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "TOKEN_TRANSFER_GAS_LIMIT",
            MARKET_TOKEN_TRANSFER_GAS_LIMIT,
            market_WETH_WETH_USDT
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POSITION_IMPACT_FACTOR_FOR_LIQUIDATIONS",
            MAX_POSITION_IMPACT_FACTOR_FOR_LIQUIDATIONS,
            market_WETH_WETH_USDT
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "POSITION_IMPACT_FACTOR",
            POSITION_IMPACT_FACTOR_POSITIVE,
            market_WETH_WETH_USDT,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "POSITION_IMPACT_FACTOR",
            POSITION_IMPACT_FACTOR_NEGATIVE,
            market_WETH_WETH_USDT,
            false
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "SWAP_FEE_FACTOR",
            SWAP_FEE_FACTOR_POSITIVE_IMPACT,
            market_WETH_WETH_USDT,
            true
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "SWAP_FEE_FACTOR",
            SWAP_FEE_FACTOR_NEGATIVE_IMPACT,
            market_WETH_WETH_USDT,
            false
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "ATOMIC_SWAP_FEE_FACTOR",
            ATOMIC_SWAP_FEE_FACTOR,
            market_WETH_WETH_USDT
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_FACTOR",
            FUNDING_FACTOR,
            market_WETH_WETH_USDT
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_EXPONENT_FACTOR",
            FUNDING_EXPONENT_FACTOR,
            market_WETH_WETH_USDT
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "THRESHOLD_FOR_STABLE_FUNDING",
            THRESHOLD_FOR_STABLE_FUNDING,
            market_WETH_WETH_USDT
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "THRESHOLD_FOR_DECREASE_FUNDING",
            THRESHOLD_FOR_DECREASE_FUNDING,
            market_WETH_WETH_USDT
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_INCREASE_FACTOR_PER_SECOND",
            FUNDING_INCREASE_FACTOR_PER_SECOND,
            market_WETH_WETH_USDT
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_DECREASE_FACTOR_PER_SECOND",
            FUNDING_DECREASE_FACTOR_PER_SECOND,
            market_WETH_WETH_USDT
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_FUNDING_FACTOR_PER_SECOND",
            MAX_FUNDING_FACTOR_PER_SECOND,
            market_WETH_WETH_USDT
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_INCREASE_FACTOR_PER_SECOND",
            FUNDING_DECREASE_FACTOR_PER_SECOND,
            market_WETH_WETH_USDT
        );
        /**
         * 0_0 *
         * --- Config for market_0_WETH_USDC ---
         */
        _setUintDataStoreCall(
            DEPLOYER,
            "TOKEN_TRANSFER_GAS_LIMIT",
            MARKET_TOKEN_TRANSFER_GAS_LIMIT,
            market_0_WETH_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_AMOUNT",
            MAX_POOL_AMOUNT_WETH,
            market_0_WETH_USDC,
            address(WETH)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_AMOUNT",
            MAX_POOL_AMOUNT_USDC,
            market_0_WETH_USDC,
            address(USDC)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_USD_FOR_DEPOSIT",
            MAX_POOL_USD_FOR_DEPOSIT_WETH,
            market_0_WETH_USDC,
            address(WETH)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_USD_FOR_DEPOSIT",
            MAX_POOL_USD_FOR_DEPOSIT_USDC,
            market_0_WETH_USDC,
            address(USDC)
        );

        /**
         * 0_0 *
         * --- Config for market_WBTC_WBTC_USDC ---
         */
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_AMOUNT",
            MAX_POOL_AMOUNT_WBTC,
            market_WBTC_WBTC_USDC,
            address(WBTC)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_AMOUNT",
            MAX_POOL_AMOUNT_USDC,
            market_WBTC_WBTC_USDC,
            address(USDC)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_USD_FOR_DEPOSIT",
            MAX_POOL_USD_FOR_DEPOSIT_WBTC,
            market_WBTC_WBTC_USDC,
            address(WBTC)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POOL_USD_FOR_DEPOSIT",
            MAX_POOL_USD_FOR_DEPOSIT_USDC,
            market_WBTC_WBTC_USDC,
            address(USDC)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_COLLATERAL_FACTOR",
            MIN_COLLATERAL_FACTOR,
            market_WBTC_WBTC_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER",
            MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER_LONG,
            market_WBTC_WBTC_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER",
            MIN_COLLATERAL_FACTOR_FOR_OPEN_INTEREST_MULTIPLIER_SHORT,
            market_WBTC_WBTC_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_OPEN_INTEREST",
            MAX_OPEN_INTEREST_LONG,
            market_WBTC_WBTC_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_OPEN_INTEREST",
            MAX_OPEN_INTEREST_SHORT,
            market_WBTC_WBTC_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "RESERVE_FACTOR",
            RESERVE_FACTOR_LONG,
            market_WBTC_WBTC_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "RESERVE_FACTOR",
            RESERVE_FACTOR_SHORT,
            market_WBTC_WBTC_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "OPEN_INTEREST_RESERVE_FACTOR",
            OPEN_INTEREST_RESERVE_FACTOR_LONG,
            market_WBTC_WBTC_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "OPEN_INTEREST_RESERVE_FACTOR",
            OPEN_INTEREST_RESERVE_FACTOR_SHORT,
            market_WBTC_WBTC_USDC,
            false
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_TRADERS",
            MAX_PNL_FACTOR_FOR_TRADERS_LONG,
            market_WBTC_WBTC_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_TRADERS",
            MAX_PNL_FACTOR_FOR_TRADERS_SHORT,
            market_WBTC_WBTC_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_ADL",
            MAX_PNL_FACTOR_FOR_ADL_LONG,
            market_WBTC_WBTC_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_ADL",
            MAX_PNL_FACTOR_FOR_ADL_SHORT,
            market_WBTC_WBTC_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_PNL_FACTOR_AFTER_ADL",
            MIN_PNL_FACTOR_AFTER_ADL_LONG,
            market_WBTC_WBTC_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MIN_PNL_FACTOR_AFTER_ADL",
            MIN_PNL_FACTOR_AFTER_ADL_SHORT,
            market_WBTC_WBTC_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_DEPOSITS",
            MAX_PNL_FACTOR_FOR_DEPOSITS_LONG,
            market_WBTC_WBTC_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_DEPOSITS",
            MAX_PNL_FACTOR_FOR_DEPOSITS_SHORT,
            market_WBTC_WBTC_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_WITHDRAWALS",
            MAX_PNL_FACTOR_FOR_WITHDRAWALS_LONG,
            market_WBTC_WBTC_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_PNL_FACTOR",
            "MAX_PNL_FACTOR_FOR_WITHDRAWALS",
            MAX_PNL_FACTOR_FOR_WITHDRAWALS_SHORT,
            market_WBTC_WBTC_USDC,
            false
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "TOKEN_TRANSFER_GAS_LIMIT",
            MARKET_TOKEN_TRANSFER_GAS_LIMIT,
            market_WBTC_WBTC_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_POSITION_IMPACT_FACTOR_FOR_LIQUIDATIONS",
            MAX_POSITION_IMPACT_FACTOR_FOR_LIQUIDATIONS,
            market_WBTC_WBTC_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "POSITION_IMPACT_FACTOR",
            POSITION_IMPACT_FACTOR_POSITIVE,
            market_WBTC_WBTC_USDC,
            true
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "POSITION_IMPACT_FACTOR",
            POSITION_IMPACT_FACTOR_NEGATIVE,
            market_WBTC_WBTC_USDC,
            false
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "SWAP_FEE_FACTOR",
            SWAP_FEE_FACTOR_POSITIVE_IMPACT,
            market_WBTC_WBTC_USDC,
            true
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "SWAP_FEE_FACTOR",
            SWAP_FEE_FACTOR_NEGATIVE_IMPACT,
            market_WBTC_WBTC_USDC,
            false
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "ATOMIC_SWAP_FEE_FACTOR",
            ATOMIC_SWAP_FEE_FACTOR,
            market_WBTC_WBTC_USDC
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_FACTOR",
            FUNDING_FACTOR,
            market_WBTC_WBTC_USDC
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_EXPONENT_FACTOR",
            FUNDING_EXPONENT_FACTOR,
            market_WBTC_WBTC_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "THRESHOLD_FOR_STABLE_FUNDING",
            THRESHOLD_FOR_STABLE_FUNDING,
            market_WBTC_WBTC_USDC
        );

        _setUintDataStoreCall(
            DEPLOYER,
            "THRESHOLD_FOR_DECREASE_FUNDING",
            THRESHOLD_FOR_DECREASE_FUNDING,
            market_WBTC_WBTC_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_INCREASE_FACTOR_PER_SECOND",
            FUNDING_INCREASE_FACTOR_PER_SECOND,
            market_WBTC_WBTC_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_DECREASE_FACTOR_PER_SECOND",
            FUNDING_DECREASE_FACTOR_PER_SECOND,
            market_WBTC_WBTC_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_FUNDING_FACTOR_PER_SECOND",
            MAX_FUNDING_FACTOR_PER_SECOND,
            market_WBTC_WBTC_USDC
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "FUNDING_INCREASE_FACTOR_PER_SECOND",
            FUNDING_DECREASE_FACTOR_PER_SECOND,
            market_WBTC_WBTC_USDC
        );

        //v2.1 remediations
        _setUintDataStoreCall(
            DEPLOYER,
            "MAX_TOTAL_CALLBACK_GAS_LIMIT_FOR_AUTO_CANCEL_ORDERS",
            MAX_TOTAL_CALLBACK_GAS_LIMIT_FOR_AUTO_CANCEL_ORDERS,
            address(0)
        );
        _setUintDataStoreCall(
            DEPLOYER,
            "EXECUTION_GAS_FEE_BASE_AMOUNT_V2_1",
            EXECUTION_GAS_FEE_BASE_AMOUNT_V2_1,
            address(0)
        );
    }

    function userSetup() internal {
        vm.deal(DEPLOYER, 10000e18);
        vm.deal(USER0, 10000e18);
        vm.deal(USER1, 10000e18);
        vm.deal(USER2, 10000e18);
        vm.deal(USER3, 10000e18);
        vm.deal(USER4, 10000e18);
        vm.deal(USER5, 10000e18);
        vm.deal(USER6, 10000e18);
        vm.deal(USER7, 10000e18);
        vm.deal(USER8, 10000e18);
        vm.deal(USER9, 10000e18);
        vm.deal(USER10, 10000e18);
        vm.deal(USER11, 10000e18);
        vm.deal(USER12, 10000e18);
        vm.deal(USER13, 10000e18);
        vm.deal(paraswapDeployer, 10000e18);
    }

    function deployCallbackCotracts() internal {
        callback = new GasFeeCallbackReceiver();
    }

    function deployGammaVault1x_WETHUSDC() internal {
        mockData = new MockData();

        proxyAdmin = new ProxyAdmin();

        gmxUtilsLogic_GammaVault1x_WETHUSDC = new GmxUtils();
        bytes memory data = abi.encodeWithSelector(
            GmxUtils.initialize.selector,
            address(orderHandler),
            address(liquidationHandler),
            address(adlHandler),
            address(exchangeRouter),
            address(router),
            address(dataStore),
            address(orderVault),
            address(reader),
            address(referralStorage)
        );

        gmxUtils_GammaVault1x_WETHUSDC = address(
            new TransparentUpgradeableProxy(
                address(gmxUtilsLogic_GammaVault1x_WETHUSDC),
                address(proxyAdmin),
                data
            )
        );
        payable(gmxUtils_GammaVault1x_WETHUSDC).transfer(10 ether);

        perpetualVault_GammaVault1x_WETHUSDC = new PerpetualVaultLens();
        VaultReader perpReader = new VaultReader(
            address(orderHandler),
            address(dataStore),
            address(orderVault),
            address(reader),
            address(referralStorage)
        );
        data = abi.encodeWithSelector(
            perpetualVault_GammaVault1x_WETHUSDC.initialize.selector,
            market_WETH_WETH_USDC, //_market
            gammaKeeper, //_keeper
            treasury_GammaVault1x_WETHUSDC, //_treasury
            gmxUtils_GammaVault1x_WETHUSDC, //_gmxUtils
            perpReader,
            1e8,
            1e28,
            10_000
        );
        vault_GammaVault1x_WETHUSDC = payable(
            new TransparentUpgradeableProxy(
                address(perpetualVault_GammaVault1x_WETHUSDC),
                address(proxyAdmin),
                data
            )
        );
    }

    function deployGammaVault2x_WETHUSDC() internal {
        proxyAdmin = new ProxyAdmin();

        gmxUtilsLogic_GammaVault2x_WETHUSDC = new GmxUtils();
        bytes memory data = abi.encodeWithSelector(
            GmxUtils.initialize.selector,
            address(orderHandler),
            address(liquidationHandler),
            address(adlHandler),
            address(exchangeRouter),
            address(router),
            address(dataStore),
            address(orderVault),
            address(reader),
            address(referralStorage)
        );

        gmxUtils_GammaVault2x_WETHUSDC = address(
            new TransparentUpgradeableProxy(
                address(gmxUtilsLogic_GammaVault2x_WETHUSDC),
                address(proxyAdmin),
                data
            )
        );
        payable(gmxUtils_GammaVault2x_WETHUSDC).transfer(10 ether);

        VaultReader perpReader = new VaultReader(
            address(orderHandler),
            address(dataStore),
            address(orderVault),
            address(reader),
            address(referralStorage)
        );
        perpetualVault_GammaVault2x_WETHUSDC = new PerpetualVaultLens();
        data = abi.encodeWithSelector(
            perpetualVault_GammaVault2x_WETHUSDC.initialize.selector,
            market_WETH_WETH_USDC, //_market
            gammaKeeper, //_keeper
            treasury_GammaVault2x_WETHUSDC, //_treasury
            gmxUtils_GammaVault2x_WETHUSDC, //_gmxUtils
            perpReader,
            1e8,
            1e28,
            20_000
        );
        vault_GammaVault2x_WETHUSDC = payable(
            new TransparentUpgradeableProxy(
                address(perpetualVault_GammaVault2x_WETHUSDC),
                address(proxyAdmin),
                data
            )
        );
    }

    function deployGammaVault3x_WETHUSDC() internal {
        gmxUtilsLogic_GammaVault3x_WETHUSDC = new GmxUtils();
        bytes memory data = abi.encodeWithSelector(
            GmxUtils.initialize.selector,
            address(orderHandler),
            address(liquidationHandler),
            address(adlHandler),
            address(exchangeRouter),
            address(router),
            address(dataStore),
            address(orderVault),
            address(reader),
            address(referralStorage)
        );

        gmxUtils_GammaVault3x_WETHUSDC = address(
            new TransparentUpgradeableProxy(
                address(gmxUtilsLogic_GammaVault3x_WETHUSDC),
                address(proxyAdmin),
                data
            )
        );
        payable(gmxUtils_GammaVault3x_WETHUSDC).transfer(10 ether);

        VaultReader perpReader = new VaultReader(
            address(orderHandler),
            address(dataStore),
            address(orderVault),
            address(reader),
            address(referralStorage)
        );
        perpetualVault_GammaVault3x_WETHUSDC = new PerpetualVaultLens();
        data = abi.encodeWithSelector(
            perpetualVault_GammaVault3x_WETHUSDC.initialize.selector,
            market_WETH_WETH_USDC, //_market
            gammaKeeper, //_keeper
            treasury_GammaVault3x_WETHUSDC, //_treasury
            gmxUtils_GammaVault3x_WETHUSDC, //_gmxUtils
            perpReader,
            1e8,
            1e28,
            30_000
        );
        vault_GammaVault3x_WETHUSDC = payable(
            new TransparentUpgradeableProxy(
                address(perpetualVault_GammaVault3x_WETHUSDC),
                address(proxyAdmin),
                data
            )
        );
    }

    function deployGammaVault1x_WBTCUSDC() internal {
        gmxUtilsLogic_GammaVault1x_WBTCUSDC = new GmxUtils();
        bytes memory data = abi.encodeWithSelector(
            GmxUtils.initialize.selector,
            address(orderHandler),
            address(liquidationHandler),
            address(adlHandler),
            address(exchangeRouter),
            address(router),
            address(dataStore),
            address(orderVault),
            address(reader),
            address(referralStorage)
        );

        gmxUtils_GammaVault1x_WBTCUSDC = address(
            new TransparentUpgradeableProxy(
                address(gmxUtilsLogic_GammaVault1x_WBTCUSDC),
                address(proxyAdmin),
                data
            )
        );
        payable(gmxUtils_GammaVault1x_WBTCUSDC).transfer(10 ether);

        VaultReader perpReader = new VaultReader(
            address(orderHandler),
            address(dataStore),
            address(orderVault),
            address(reader),
            address(referralStorage)
        );
        perpetualVault_GammaVaul1x_WBTCUSDC = new PerpetualVaultLens();
        data = abi.encodeWithSelector(
            perpetualVault_GammaVaul1x_WBTCUSDC.initialize.selector,
            market_WBTC_WBTC_USDC, //_market
            gammaKeeper, //_keeper
            treasury_GammaVault1x_WBTCUSDC, //_treasury
            gmxUtils_GammaVault1x_WBTCUSDC, //_gmxUtils
            perpReader,
            1e8,
            1e28,
            10_000
        );
        vault_GammaVault1x_WBTCUSDC = payable(
            new TransparentUpgradeableProxy(
                address(perpetualVault_GammaVaul1x_WBTCUSDC),
                address(proxyAdmin),
                data
            )
        );
    }

    function deployGammaVault2x_WBTCUSDC() internal {
        gmxUtilsLogic_GammaVault2x_WBTCUSDC = new GmxUtils();
        bytes memory data = abi.encodeWithSelector(
            GmxUtils.initialize.selector,
            address(orderHandler),
            address(liquidationHandler),
            address(adlHandler),
            address(exchangeRouter),
            address(router),
            address(dataStore),
            address(orderVault),
            address(reader),
            address(referralStorage)
        );

        gmxUtils_GammaVault2x_WBTCUSDC = address(
            new TransparentUpgradeableProxy(
                address(gmxUtilsLogic_GammaVault2x_WBTCUSDC),
                address(proxyAdmin),
                data
            )
        );
        payable(gmxUtils_GammaVault2x_WBTCUSDC).transfer(10 ether);

        VaultReader perpReader = new VaultReader(
            address(orderHandler),
            address(dataStore),
            address(orderVault),
            address(reader),
            address(referralStorage)
        );
        perpetualVault_GammaVault2x_WBTCUSDC = new PerpetualVaultLens();
        data = abi.encodeWithSelector(
            perpetualVault_GammaVault2x_WBTCUSDC.initialize.selector,
            market_WBTC_WBTC_USDC, //_market
            gammaKeeper, //_keeper
            treasury_GammaVault2x_WBTCUSDC, //_treasury
            gmxUtils_GammaVault2x_WBTCUSDC, //_gmxUtils
            perpReader,
            1e8,
            1e28,
            20_000
        );
        vault_GammaVault2x_WBTCUSDC = payable(
            new TransparentUpgradeableProxy(
                address(perpetualVault_GammaVault2x_WBTCUSDC),
                address(proxyAdmin),
                data
            )
        );
    }

    function deployGammaVault3x_WBTCUSDC() internal {
        gmxUtilsLogic_GammaVault3x_WBTCUSDC = new GmxUtils();
        bytes memory data = abi.encodeWithSelector(
            GmxUtils.initialize.selector,
            address(orderHandler),
            address(liquidationHandler),
            address(adlHandler),
            address(exchangeRouter),
            address(router),
            address(dataStore),
            address(orderVault),
            address(reader),
            address(referralStorage)
        );

        gmxUtils_GammaVault3x_WBTCUSDC = address(
            new TransparentUpgradeableProxy(
                address(gmxUtilsLogic_GammaVault3x_WBTCUSDC),
                address(proxyAdmin),
                data
            )
        );
        payable(gmxUtils_GammaVault3x_WBTCUSDC).transfer(10 ether);

        VaultReader perpReader = new VaultReader(
            address(orderHandler),
            address(dataStore),
            address(orderVault),
            address(reader),
            address(referralStorage)
        );
        perpetualVault_GammaVault3x_WBTCUSDC = new PerpetualVaultLens();
        data = abi.encodeWithSelector(
            perpetualVault_GammaVault3x_WBTCUSDC.initialize.selector,
            market_WBTC_WBTC_USDC, //_market
            gammaKeeper, //_keeper
            treasury_GammaVault3x_WBTCUSDC, //_treasury
            gmxUtils_GammaVault3x_WBTCUSDC, //_gmxUtils
            perpReader,
            1e8,
            1e28,
            30_000
        );
        vault_GammaVault3x_WBTCUSDC = payable(
            new TransparentUpgradeableProxy(
                address(perpetualVault_GammaVault3x_WBTCUSDC),
                address(proxyAdmin),
                data
            )
        );
    }

    function deployDex() internal {
        // vm.prank(paraswapDeployer); //NOTE: this prank doesnt work in setup, deploying with hevm address
        vm.prank(HEVM_INITIAL_ADDRESS); //for a foundry compatibility
        mockDex = new MockDex();
        if (msg.sender == HEVM_INITIAL_ADDRESS) {
            //echidna
            fl.t(
                address(mockDex) ==
                    address(0x78c362A5690447EA2BBC3E8008502efD13936F79),
                "Address of DEX should be Paraswap V5 Augustus Swapper"
            );
        } else if (msg.sender == FOUNDRY_DEFAULT_ADDRESS) {
            fl.t(
                address(mockDex) ==
                    address(0x731a10897d267e19B34503aD902d0A29173Ba4B1),
                "Address of DEX should be Paraswap V5 Augustus Swapper"
            );
        }

        // fl.t(
        //     address(mockDex) ==
        //         address(0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57),
        //     "Address of DEX should be Paraswap V5 Augustus Swapper"
        // ); //nonce = 1, nonce = 0 was minting WETH in GMXSetup
    }

    function addLiquidityDex() public {
        uint amountWETH = WETH.balanceOf(paraswapDeployer) / 2;
        uint amountUSDC = USDC.balanceOf(paraswapDeployer) / 5;
        uint amountWBTC = WBTC.balanceOf(paraswapDeployer) / 2;

        mockDex.createPair(
            address(WETH),
            address(USDC),
            3, //feePercentage
            100, //maxSwapPercentage
            "WETH/USDC Pair",
            "WETHUSDC"
        );
        vm.prank(paraswapDeployer);
        WETH.approve(address(mockDex), type(uint256).max);
        vm.prank(paraswapDeployer);
        USDC.approve(address(mockDex), type(uint256).max);
        vm.prank(paraswapDeployer);
        mockDex.addLiquidity(
            address(WETH),
            address(USDC),
            amountWETH,
            amountUSDC,
            0,
            0
        );

        mockDex.createPair(
            address(WBTC),
            address(USDC),
            3, //feePercentage
            100, //maxSwapPercentage
            "WBTC/USDC Pair",
            "WBTCUSDC"
        );
        vm.prank(paraswapDeployer);
        WBTC.approve(address(mockDex), type(uint256).max);
        vm.prank(paraswapDeployer);
        USDC.approve(address(mockDex), type(uint256).max);
        vm.prank(paraswapDeployer);
        mockDex.addLiquidity(
            address(WBTC),
            address(USDC),
            amountWBTC,
            amountUSDC,
            0,
            0
        );
    }

    function setVaultsArray() internal {
        VAULTS = [
            vault_GammaVault1x_WETHUSDC,
            vault_GammaVault2x_WETHUSDC,
            vault_GammaVault3x_WETHUSDC,
            vault_GammaVault1x_WBTCUSDC,
            vault_GammaVault2x_WBTCUSDC,
            vault_GammaVault3x_WBTCUSDC
        ];
        // vm.label(vault_GammaVault1x_WBTCUSDC, "vault_GammaVault1x_WBTCUSDC");
        // vm.label(vault_GammaVault2x_WBTCUSDC, "vault_GammaVault2x_WBTCUSDC");
        // vm.label(
        //     gmxUtils_GammaVault3x_WBTCUSDC,
        //     "gmxUtils_GammaVault3x_WBTCUSDC"
        // );
        // vm.label(vault_GammaVault1x_WETHUSDC, "vault_GammaVault1x_WETHUSDC");
        // vm.label(vault_GammaVault2x_WETHUSDC, "vault_GammaVault2x_WETHUSDC");
        // vm.label(vault_GammaVault3x_WETHUSDC, "vault_GammaVault3x_WETHUSDC");
    }

    function fillVaultMarketMap() internal {
        // Map WBTC-USDC vaults to their market
        vaultToMarket[vault_GammaVault1x_WBTCUSDC] = market_WBTC_WBTC_USDC;
        vaultToMarket[vault_GammaVault2x_WBTCUSDC] = market_WBTC_WBTC_USDC;
        vaultToMarket[vault_GammaVault3x_WBTCUSDC] = market_WBTC_WBTC_USDC;

        // Map WETH-USDC vaults to their market
        vaultToMarket[vault_GammaVault1x_WETHUSDC] = market_WETH_WETH_USDC;
        vaultToMarket[vault_GammaVault2x_WETHUSDC] = market_WETH_WETH_USDC;
        vaultToMarket[vault_GammaVault3x_WETHUSDC] = market_WETH_WETH_USDC;
    }

    function setRouterInVault() internal {
        PARASWAP_ROUTER = address(mockDex);

        PerpetualVaultLens(vault_GammaVault1x_WETHUSDC).setRouter(
            PARASWAP_ROUTER
        );
        PerpetualVaultLens(vault_GammaVault2x_WETHUSDC).setRouter(
            PARASWAP_ROUTER
        );
        PerpetualVaultLens(vault_GammaVault3x_WETHUSDC).setRouter(
            PARASWAP_ROUTER
        );
        PerpetualVaultLens(vault_GammaVault1x_WBTCUSDC).setRouter(
            PARASWAP_ROUTER
        );
        PerpetualVaultLens(vault_GammaVault2x_WBTCUSDC).setRouter(
            PARASWAP_ROUTER
        );
        PerpetualVaultLens(vault_GammaVault3x_WBTCUSDC).setRouter(
            PARASWAP_ROUTER
        );
    }
}
