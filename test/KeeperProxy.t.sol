// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/StdCheats.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ArbitrumTest} from "./utils/ArbitrumTest.sol";
import { TransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { GmxProxy } from "../contracts/GmxProxy.sol";
import { KeeperProxy } from "../contracts/KeeperProxy.sol";
import { PerpetualVault } from "../contracts/PerpetualVault.sol";
import { VaultReader } from "../contracts/VaultReader.sol";
import { MarketPrices, PriceProps } from "../contracts/libraries/StructData.sol";
import { MockData } from "./mock/MockData.sol";

interface IExchangeRouter {
  struct SimulatePricesParams {
    address[] primaryTokens;
    PriceProps[] primaryPrices;
    uint256 minTimestamp;
    uint256 maxTimestamp;
  }
  function simulateExecuteOrder(bytes32 key, SimulatePricesParams memory oracleParams) external;
}

interface IOrderHandler {
  function executeOrder(
    bytes32 key,
    MockData.OracleSetPriceParams calldata oracleParams
  ) external;
}

/// @title KeeperProxyTest
/// @notice Test suite for the KeeperProxy contract
/// @dev Uses Forge's standard library for testing Ethereum smart contracts
contract KeeperProxyTest is Test, ArbitrumTest {
  address payable vault;
  address keeper;
  MockData mockData;

  /// @notice Sets up the test environment
  /// @dev Deploys necessary contracts and initializes test data
  function setUp() public {
    address ethUsdcMarket = address(0x70d95587d40A2caf56bd97485aB3Eec10Bee6336);
    address orderHandler = address(0xe68CAAACdf6439628DFD2fe624847602991A31eB);
    // old address orderHandler = address(0xB0Fc2a48b873da40e7bc25658e5E6137616AC2Ee);
    address liquidationHandler = address(0xdAb9bA9e3a301CCb353f18B4C8542BA2149E4010);
    // old address liquidationHandler = address(0x08A902113F7F41a8658eBB1175f9c847bf4fB9D8);
    address adlHandler = address(0x9242FbED25700e82aE26ae319BCf68E9C508451c);
    // old address adlHandler = address(0x26BC03c944A4800299B4bdfB5EdCE314dD497511);
    address gExchangeRouter = address(0x900173A66dbD345006C51fA35fA3aB760FcD843b);
    // old address gExchangeRouter = address(0x69C527fC77291722b52649E45c838e41be8Bf5d5);
    address gmxRouter = address(0x7452c558d45f8afC8c83dAe62C3f8A5BE19c71f6);
    address dataStore = address(0xFD70de6b91282D8017aA4E741e9Ae325CAb992d8);
    address orderVault = address(0x31eF83a530Fde1B38EE9A18093A333D8Bbbc40D5);
    address gmxReader = address(0x5Ca84c34a381434786738735265b9f3FD814b824);
    address referralStorage= address(0xe6fab3F0c7199b0d34d7FbE83394fc0e0D06e99d);

    ProxyAdmin proxyAdmin = new ProxyAdmin();
    
    GmxProxy gmxUtilsLogic = new GmxProxy();
    bytes memory data = abi.encodeWithSelector(
      GmxProxy.initialize.selector,
      orderHandler,
      liquidationHandler,
      adlHandler,
      gExchangeRouter,
      gmxRouter,
      dataStore,
      orderVault,
      gmxReader,
      referralStorage
    );
    address gmxProxy = address(
      new TransparentUpgradeableProxy(
        address(gmxUtilsLogic),
        address(proxyAdmin),
        data
      )
    );
    payable(gmxProxy).transfer(1 ether);

    KeeperProxy keeperLogic = new KeeperProxy();
    data = abi.encodeWithSelector(
      KeeperProxy.initialize.selector
    );
    keeper = address(
      new TransparentUpgradeableProxy(
        address(keeperLogic),
        address(proxyAdmin),
        data
      )
    );
    address owner = KeeperProxy(keeper).owner();
    KeeperProxy(keeper).setKeeper(owner, true);
    KeeperProxy(keeper).setDataFeed(0xaf88d065e77c8cC2239327C5EDb3A432268e5831, 0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3, 86400, 500);
    KeeperProxy(keeper).setDataFeed(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1, 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612, 86400, 500);

    VaultReader reader = new VaultReader(
      orderHandler,
      dataStore,
      orderVault,
      gmxReader,
      referralStorage
    );
    PerpetualVault perpetualVault = new PerpetualVault();
    data = abi.encodeWithSelector(
      PerpetualVault.initialize.selector,
      address(0x70d95587d40A2caf56bd97485aB3Eec10Bee6336), // ethUsdcMarket,
      keeper,
      makeAddr("treasury"),
      gmxProxy,
      reader,
      1e8,
      1e28,
      10_000
    );
    vm.prank(address(this), address(this));
    vault = payable(
      new TransparentUpgradeableProxy(
        address(perpetualVault),
        address(proxyAdmin),
        data
      )
    );

    mockData = new MockData();
  }

  /// @notice Tests that the run function reverts if off-chain price is incorrect
  function test_Run_RevertIf_OffchainPriceIsIncorrect() external {
    address alice = makeAddr("alice");
    payable(alice).transfer(1 ether);
    depositFixture(alice, 1e10);

    MarketPrices memory prices = mockData.getMarketPrices();
    prices.indexTokenPrice.min = 1000;
    prices.indexTokenPrice.max = 1000;
    bytes[] memory data = new bytes[](2);
    data[0] = abi.encode(3380000000000000);
    address owner = KeeperProxy(keeper).owner();
    vm.startPrank(owner);
    KeeperProxy(keeper).setMaxTimeWindow(0xaf88d065e77c8cC2239327C5EDb3A432268e5831, 10);
    KeeperProxy(keeper).setMaxTimeWindow(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1, 10);
    vm.expectRevert("stale price feed");
    KeeperProxy(keeper).run(vault, true, false, prices, data);
    KeeperProxy(keeper).setMaxTimeWindow(0xaf88d065e77c8cC2239327C5EDb3A432268e5831, 86400);
    KeeperProxy(keeper).setMaxTimeWindow(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1, 86400);
    vm.expectRevert("price offset too big");
    KeeperProxy(keeper).run(vault, true, false, prices, data);
  }

  /// @notice Tests that the runNextAction function reverts if off-chain price is incorrect
  function test_RunNextAction_RevertIf_OffchainPriceIsIncorrect() external {
    address alice = makeAddr("alice");
    payable(alice).transfer(1 ether);
    depositFixture(alice, 1e10);

    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory data = new bytes[](2);
    data[0] = abi.encode(3380000000000000);
    address owner = KeeperProxy(keeper).owner();
    console.log(block.timestamp);
    vm.prank(owner);
    KeeperProxy(keeper).run(vault, true, false, prices, data);
    GmxOrderExecuted();
    KeeperProxy(keeper).runNextAction(vault, prices, new bytes[](2));

    IERC20 collateralToken = PerpetualVault(vault).collateralToken();
    uint256 amount = 1e12;
    deal(address(collateralToken), alice, amount);
    uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(true);
    vm.startPrank(alice);
    collateralToken.approve(vault, amount);
    PerpetualVault(vault).deposit{value: executionFee * tx.gasprice}(amount);
    vm.stopPrank();

    bytes[] memory swapData = new bytes[](2);
    swapData[0] = abi.encode(3380000000000000);
    prices.indexTokenPrice.min = 1000;
    prices.indexTokenPrice.max = 1000;
    vm.startPrank(owner);
    vm.expectRevert("price offset too big");
    KeeperProxy(keeper).runNextAction(vault, prices, swapData);

    prices = mockData.getMarketPrices();
    KeeperProxy(keeper).runNextAction(vault, prices, swapData);
    vm.stopPrank();
  }

  function test_CancelDeposit() external {
    address alice = makeAddr("alice");
    payable(alice).transfer(1 ether);
    depositFixture(alice, 1e10);

    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory data = new bytes[](2);
    data[0] = abi.encode(3380000000000000);
    address owner = KeeperProxy(keeper).owner();
    console.log(block.timestamp);
    vm.prank(owner);
    KeeperProxy(keeper).run(vault, true, false, prices, data);
    GmxOrderExecuted();
    vm.prank(owner);
    KeeperProxy(keeper).runNextAction(vault, prices, new bytes[](2));

    uint256 totalDepositAmountBefore = PerpetualVault(vault).totalDepositAmount();

    IERC20 collateralToken = PerpetualVault(vault).collateralToken();
    uint256 amount = 1e12;
    deal(address(collateralToken), alice, amount);
    uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(true);
    vm.startPrank(alice);
    collateralToken.approve(vault, amount);
    PerpetualVault(vault).deposit{value: executionFee * tx.gasprice}(amount);
    vm.stopPrank();

    assertEq(uint8(PerpetualVault(vault).flow()), 1);
    vm.prank(owner);
    KeeperProxy(keeper).cancelFlow(vault);
    vm.stopPrank();

    assertEq(uint8(PerpetualVault(vault).flow()), 5);
    uint256 totalDepositAmountAfter = PerpetualVault(vault).totalDepositAmount();
    assertEq(totalDepositAmountAfter, totalDepositAmountBefore);
    uint256[] memory depositIds = PerpetualVault(vault).getUserDeposits(alice);
    assertEq(depositIds.length, 1);

  }

  function test_CancelOrder() external {
    doShortPositionFixture();

    address alice = makeAddr("alice");
    IERC20 collateralToken = PerpetualVault(vault).collateralToken();
    uint256 amount = 1e12;
    deal(address(collateralToken), alice, amount);
    deal(alice, 1e18);
    uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(true);
    vm.startPrank(alice);
    collateralToken.approve(vault, amount);
    PerpetualVault(vault).deposit{value: executionFee * tx.gasprice}(amount);
    vm.stopPrank();

    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory swapData = new bytes[](2);
    swapData[0] = abi.encode(3380000000000000);
    KeeperProxy(keeper).runNextAction(vault, prices, swapData);

    vm.warp(block.timestamp + 1000);
    KeeperProxy(keeper).cancelOrder(vault);
    
    (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 1);
    // uint8 isNextAction = uint8(PerpetualVault(vault).isNextAction());
    // assertEq(isNextAction, 1);
  }

  /// @notice Helper function to perform a deposit
  /// @param user Address of the user making the deposit
  /// @param amount Amount to deposit
  /// @dev Internal function used across multiple tests
  function depositFixture(address user, uint256 amount) internal {
    IERC20 collateralToken = PerpetualVault(vault).collateralToken();
    vm.startPrank(user);
    deal(address(collateralToken), user, amount);
    uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(true);
    collateralToken.approve(vault, amount);
    PerpetualVault(vault).deposit{value: executionFee * tx.gasprice}(amount);
    vm.stopPrank();
  }

  /// @notice Simulates successful GMX order execution
  /// @dev Internal function to mock successful GMX order execution
  function GmxOrderExecuted() internal {
    address gmxProxy = address(PerpetualVault(vault).gmxProxy());
    (bytes32 requestKey, ) = GmxProxy(payable(gmxProxy)).queue();

    MockData.OracleSetPriceParams memory params = mockData.getOracleParams();
    address gmxKeeper = address(0x6A2B3A13be0c723674BCfd722d4e133b3f356e05);
    address orderHandler = address(0xe68CAAACdf6439628DFD2fe624847602991A31eB);
    vm.prank(gmxKeeper);
    IOrderHandler(orderHandler).executeOrder(requestKey, params);
  }

  function doShortPositionFixture() internal {
    IERC20 collateralToken = PerpetualVault(vault).collateralToken();
    address bob = makeAddr("bob");
    uint256 amount = 1e10;
    vm.startPrank(bob);
    deal(address(collateralToken), bob, amount);
    uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(true);
    collateralToken.approve(vault, amount);
    PerpetualVault(vault).deposit{value: executionFee * tx.gasprice}(amount);
    vm.stopPrank();

    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory data = new bytes[](2);
    data[0] = abi.encode(3380000000000000);
    KeeperProxy(keeper).run(vault, true, false, prices, data);
    GmxOrderExecuted();
    KeeperProxy(keeper).runNextAction(vault, prices, new bytes[](2));
  }
}
