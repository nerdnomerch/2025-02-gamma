// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/FuzzUtils.sol";
import "./FuzzGMXConfig.sol";

/**
 * 0_0 *
 * --- Libraries imports ---
 */

//ADL
import "../../contracts/adl/AdlUtils.sol";

//Gas
// import "../../contracts/gas/GasUtils.sol";

//Fee
import "../../contracts/fee/FeeUtils.sol";
import "../../contracts/fee/FeeBatch.sol";

//Order
import "../../contracts/order/BaseOrderUtils.sol";
import "../../contracts/order/OrderStoreUtils.sol";
import "../../contracts/order/OrderEventUtils.sol";
import "../../contracts/order/IncreaseOrderUtils.sol";
import "../../contracts/order/DecreaseOrderUtils.sol";
import "../../contracts/order/SwapOrderUtils.sol";
import "../../contracts/order/OrderUtils.sol";

// Market
import "../../contracts/market/MarketStoreUtils.sol";
import "../../contracts/market/MarketEventUtils.sol";
import "../../contracts/market/MarketUtils.sol";

//Pricing
import "../../contracts/pricing/SwapPricingUtils.sol";

//Swap
import "../../contracts/swap/SwapUtils.sol";

//Position
import "../../contracts/position/PositionStoreUtils.sol";
import "../../contracts/pricing/PositionPricingUtils.sol";
import "../../contracts/position/PositionUtils.sol";
import "../../contracts/position/PositionEventUtils.sol";
import "../../contracts/position/IncreasePositionUtils.sol";
import "../../contracts/position/DecreasePositionSwapUtils.sol";
import "../../contracts/position/DecreasePositionCollateralUtils.sol";
import "../../contracts/position/DecreasePositionUtils.sol";

//Referral
import "../../contracts/referral/ReferralEventUtils.sol";

//Other libs
import "../../contracts/token/TokenUtils.sol";
import "../../contracts/fee/FeeSwapUtils.sol";
import "../../contracts/order/Order.sol";
import "../../contracts/order/AutoCancelUtils.sol";
import "../../contracts/referral/ReferralTier.sol";
import "../../contracts/role/Role.sol";
import "../../contracts/deposit/Deposit.sol";
import "../../contracts/nonce/NonceUtils.sol";
import "../../contracts/fee/FeeBatchStoreUtils.sol";
import "../../contracts/test/ArrayTest.sol";
import "../../contracts/liquidation/LiquidationUtils.sol";
import "../../contracts/position/Position.sol";
import "../../contracts/position/DecreasePositionSwapUtils.sol";
import "../../contracts/position/PositionUtils.sol";
import "../../contracts/position/DecreasePositionUtils.sol";
import "../../contracts/position/PositionStoreUtils.sol";
import "../../contracts/position/PositionStoreUtils.sol";
import "../../contracts/position/DecreasePositionCollateralUtils.sol";
import "../../contracts/position/PositionEventUtils.sol";
import "../../contracts/position/IncreasePositionUtils.sol";
import "../../contracts/withdrawal/WithdrawalStoreUtils.sol";
import "../../contracts/withdrawal/ExecuteWithdrawalUtils.sol";
import "../../contracts/withdrawal/WithdrawalEventUtils.sol";
import "../../contracts/withdrawal/Withdrawal.sol";
import "../../contracts/withdrawal/WithdrawalUtils.sol";
import "../../contracts/oracle/ChainlinkPriceFeedUtils.sol";
import "../../contracts/oracle/OracleUtils.sol";
import "../../contracts/oracle/GmOracleUtils.sol";
import "../../contracts/utils/Uint256Mask.sol";
import "../../contracts/utils/Bits.sol";
import "../../contracts/utils/Cast.sol";
import "../../contracts/utils/AccountUtils.sol";
import "../../contracts/utils/Array.sol";
import "../../contracts/utils/Calc.sol";
import "../../contracts/utils/Precision.sol";
import "../../contracts/utils/Printer.sol";
import "../../contracts/utils/EnumerableValues.sol";
import "../../contracts/chain/Chain.sol";
import "../../contracts/adl/AdlUtils.sol";
import "../../contracts/price/Price.sol";
import "../../contracts/subaccount/SubaccountUtils.sol";
import "../../contracts/market/MarketPoolValueInfo.sol";
import "../../contracts/market/MarketUtils.sol";
import "../../contracts/market/MarketEventUtils.sol";
import "../../contracts/market/MarketStoreUtils.sol";
import "../../contracts/market/Market.sol";
import "../../contracts/feature/FeatureUtils.sol";
import "../../contracts/callback/CallbackUtils.sol";
import "../../contracts/data/Keys.sol";
import "../../contracts/error/ErrorUtils.sol";
import "../../contracts/error/Errors.sol";
import "../../contracts/pricing/PositionPricingUtils.sol";
import "../../contracts/pricing/PricingUtils.sol";
import "../../contracts/pricing/SwapPricingUtils.sol";
import "../../contracts/event/EventUtils.sol";

//Test libs
import "../../contracts/test/MarketStoreUtilsTest.sol";
import "../../contracts/test/GasUsageTest.sol";
import "../../contracts/test/WithdrawalStoreUtilsTest.sol";
import "../../contracts/test/PricingUtilsTest.sol";
import "../../contracts/test/DepositStoreUtilsTest.sol";
import "../../contracts/test/OrderStoreUtilsTest.sol";
import "../../contracts/test/PositionStoreUtilsTest.sol";

/**
 * 0_0 *
 * --- Contracts  ---
 */

//Role
import "../../contracts/role/RoleStore.sol";

//Data
import "../../contracts/data/DataStore.sol";

//Mocks
import "../../contracts/mock/MintableToken.sol";
import "../../contracts/mock/WNT.sol";
import "../../contracts/mock/MockPriceFeed.sol";
import "../../contracts/mock/MockDataStreamVerifier.sol";
import "../../contracts/mock/ReferralStorage.sol";
import "../../contracts/mock/Multicall3.sol";
import "../mocks/ChainlinkMock.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV2V3Interface.sol";
import "../../contracts/mock/MockVaultGovV1.sol";
import "../../contracts/mock/MockVaultV1.sol";

//Gov
import "../../contracts/gov/GovTimelockController.sol";
import "../../contracts/gov/GovToken.sol";
import "../../contracts/gov/ProtocolGovernor.sol";

//Events
import "../../contracts/event/EventEmitter.sol";

// Oracle
import "../../contracts/oracle/OracleStore.sol";
import "../../contracts/oracle/GmOracleProvider.sol";
import "../../contracts/oracle/ChainlinkPriceFeedProvider.sol";
import "../../contracts/oracle/Oracle.sol";
import "../../contracts/oracle/ChainlinkDataStreamProvider.sol";

//Order
import "../../contracts/order/OrderVault.sol";

//Market
import "../../contracts/market/MarketFactory.sol";

//Swap
import "../../contracts/swap/SwapHandler.sol";

//Exchange
import "../../contracts/exchange/AdlHandler.sol";
import "../../contracts/exchange/DepositHandler.sol";
import "../../contracts/exchange/WithdrawalHandler.sol";
import "../../contracts/exchange/ShiftHandler.sol";
import "../../contracts/exchange/OrderHandler.sol";
import "../../contracts/exchange/LiquidationHandler.sol";

//External
import "../../contracts/external/ExternalHandler.sol";

//Callback
// import "../../contracts/callback/CallbackUtils.sol";

//Chain
// import "../../contracts/chain/ChainReader.sol";

//Config
import "../../contracts/config/Config.sol";

//Deposit
import "../../contracts/deposit/DepositEventUtils.sol";
import "../../contracts/deposit/DepositVault.sol";
import "../../contracts/deposit/DepositStoreUtils.sol";
import "../../contracts/deposit/DepositUtils.sol";
// import "../../contracts/deposit/ExecuteDepositUtils.sol";

//Router
import "../../contracts/router/Router.sol";
import "../../contracts/router/ExchangeRouter.sol";
import "../../contracts/router/SubaccountRouter.sol";

//Withdrawal
import "../../contracts/withdrawal/WithdrawalVault.sol";
import "../../contracts/withdrawal/WithdrawalStoreUtils.sol";
import "../../contracts/withdrawal/WithdrawalEventUtils.sol";
import "../../contracts/withdrawal/WithdrawalUtils.sol";
// import "../../contracts/withdrawal/ExecuteWithdrawalUtils.sol";

//Shift
// import "../../contracts/Shift/ShiftVault.sol";
// import "../../contracts/Shift/ShiftStoreUtils.sol";
// import "../../contracts/Shift/ShiftEventUtils.sol";
// import "../../contracts/Shift/ShiftUtils.sol";
// import "../../contracts/Shift/Shift.sol";

//Referral
import "../../contracts/referral/ReferralUtils.sol";

//Fee
import "../../contracts/fee/FeeHandler.sol";

//Liquidations
import "../../contracts/liquidation/LiquidationUtils.sol";

//Reader
import "../../contracts/reader/ReaderPricingUtils.sol";
import "../../contracts/reader/ReaderUtils.sol";
import "../../contracts/reader/ReaderDepositUtils.sol";
import "../../contracts/reader/ReaderWithdrawalUtils.sol";
import "../../contracts/reader/Reader.sol";

//Timelock
import "../../contracts/config/Timelock.sol";

//Migration
import "../../contracts/migration/TimestampInitializer.sol";

//Callback contract
import "./GasFeeCallbackReceiver.sol";

//Gamma

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {PerpetualVault} from "../../../../contracts/PerpetualVault.sol";
import {VaultReader} from "../../../../contracts/VaultReader.sol";
import {MockGmxUtils as GmxUtils} from "../../../mock/MockGMXUtils.sol";
import {KeeperProxy} from "../../../../contracts/KeeperProxy.sol";
import {MarketPrices, PriceProps} from "../../../../contracts/libraries/StructData.sol";
import {MockData} from "../../../mock/MockData.sol";
import {PerpetualVaultLens} from "../../PerpetualVaultLens.sol";

//MOCK DEX

import {MockDex} from "../mocks/MockDEX.sol";

/**
 *
 *
 *
 *
 */
contract FuzzStorageVars is FuzzGMXConfig {
    //Role
    RoleStore internal roleStore;

    //Data
    DataStore internal dataStore;

    //Mocks
    WNT internal WETH;
    MintableToken internal WBTC;
    MintableToken internal USDC;
    MintableToken internal USDT;
    MockPriceFeed internal USDCPriceFeed;
    MockPriceFeed internal USDTPriceFeed;
    MockPriceFeed internal mockPriceFeed;
    MockDataStreamVerifier internal mockDataStreamVerifier;
    ReferralStorage internal referralStorage;
    Multicall3 internal multicall3;
    AggregatorV2V3Interface internal aggregatorV2V3Interface; //for eventual future deployment, currently address 0 in Oralcle setup

    //Gov
    GovTimelockController internal govTimelockController;
    GovToken internal govToken;
    ProtocolGovernor internal protocolGovernor;

    //Events
    EventEmitter internal eventEmitter;

    //Oracles
    OracleStore internal oracleStore;
    GmOracleProvider internal gmOracleProvider;
    ChainlinkPriceFeedProvider internal chainlinkPriceFeedProvider;
    Oracle internal oracle;
    ChainlinkDataStreamProvider internal chainlinkDataStreamProvider;
    ChainlinkMock internal chainlinkMock;

    //Order
    OrderVault internal orderVault;

    //Market
    MarketFactory internal marketFactory;

    //Swap
    SwapHandler internal swapHandler;

    //Exchange
    AdlHandler internal adlHandler;
    DepositHandler internal depositHandler;
    WithdrawalHandler internal withdrawalHandler;
    ShiftHandler internal shiftHandler;
    OrderHandler internal orderHandler;
    LiquidationHandler internal liquidationHandler;

    //External
    ExternalHandler internal externalHandler;

    //Config
    Config internal config;

    //Deposit
    DepositVault internal depositVault;

    //Router
    Router internal router;
    ExchangeRouter internal exchangeRouter;
    SubaccountRouter internal subaccountRouter;

    //Withdrawal
    WithdrawalVault internal withdrawalVault;

    //Shift
    ShiftVault internal shiftVault;
    // ShiftStoreUtils internal shiftStoreUtils;
    // ShiftEventUtils internal shiftEventUtils;
    // ShiftUtils internal shiftUtils;

    //Fee
    FeeHandler internal feeHandler;

    //Reader

    Reader internal reader;

    //Timelock
    Timelock internal timelock;

    //Migration
    TimestampInitializer internal timestampInitializer;

    /**
     * 0_0 *
     * --- MARKETS ---
     */
    address market_WETH_WETH_USDC;
    address market_WETH_WETH_USDT;
    address market_0_WETH_USDC;
    address market_WBTC_WBTC_USDC;

    /**
     * 0_0 *
     * --- CALLBACKS ---
     */

    GasFeeCallbackReceiver internal callback;

    /**
     * 0_0 *
     * --- GAMMA ---
     */
    mapping(address => address) public vaultToMarket;

    ProxyAdmin public proxyAdmin;

    GmxUtils public gmxUtilsLogic_GammaVault1x_WETHUSDC;
    GmxUtils public gmxUtilsLogic_GammaVault2x_WETHUSDC;
    GmxUtils public gmxUtilsLogic_GammaVault3x_WETHUSDC;

    //  PerpetualVault public perpetualVault_GammaVaul1x_WETHUSDC;
    //     PerpetualVault public perpetualVault_GammaVaul2x_WETHUSDC;
    //     PerpetualVault public perpetualVault_GammaVault3x_WETHUSDC; //NOTE: using lens

    PerpetualVaultLens public perpetualVault_GammaVault1x_WETHUSDC;
    PerpetualVaultLens public perpetualVault_GammaVault2x_WETHUSDC;
    PerpetualVaultLens public perpetualVault_GammaVault3x_WETHUSDC;

    address gmxUtils_GammaVault1x_WETHUSDC;
    address gmxUtils_GammaVault2x_WETHUSDC;
    address gmxUtils_GammaVault3x_WETHUSDC;
    address payable vault_GammaVault1x_WETHUSDC;
    address payable vault_GammaVault2x_WETHUSDC;
    address payable vault_GammaVault3x_WETHUSDC;

    GmxUtils public gmxUtilsLogic_GammaVault1x_WBTCUSDC;
    GmxUtils public gmxUtilsLogic_GammaVault2x_WBTCUSDC;
    GmxUtils public gmxUtilsLogic_GammaVault3x_WBTCUSDC;

    PerpetualVaultLens public perpetualVault_GammaVaul1x_WBTCUSDC;
    PerpetualVaultLens public perpetualVault_GammaVault2x_WBTCUSDC;
    PerpetualVaultLens public perpetualVault_GammaVault3x_WBTCUSDC;

    // PerpetualVault public perpetualVault_GammaVaul1x_WBTCUSDC;
    // PerpetualVault public perpetualVault_GammaVault2x_WBTCUSDC;
    // PerpetualVault public perpetualVault_GammaVault3x_WBTCUSDC;

    address gmxUtils_GammaVault1x_WBTCUSDC;
    address gmxUtils_GammaVault2x_WBTCUSDC;
    address gmxUtils_GammaVault3x_WBTCUSDC;

    address payable vault_GammaVault1x_WBTCUSDC;
    address payable vault_GammaVault2x_WBTCUSDC;
    address payable vault_GammaVault3x_WBTCUSDC;

    address[6] internal VAULTS;

    MockData public mockData;
    /**
     * 0_0 *
     * --- DEX Mock ---
     */

    MockDex public mockDex;
    address PARASWAP_ROUTER;

    bool DEBUG = true;
}
