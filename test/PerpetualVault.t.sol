// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/StdCheats.sol";
import {ArbitrumTest} from "./utils/ArbitrumTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { TransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { PerpetualVault } from "../contracts/PerpetualVault.sol";
import { GmxProxy } from "../contracts/GmxProxy.sol";
import { VaultReader } from "../contracts/VaultReader.sol";
import { KeeperProxy } from "../contracts/KeeperProxy.sol";
import { MarketPrices, PriceProps } from "../contracts/libraries/StructData.sol";
import { MockData } from "./mock/MockData.sol";
import { Error } from "../contracts/libraries/Error.sol";

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


interface IGmxUtils {
  function setSlippage(uint256 _slippage) external;
}

/// @title PerpetualVaultTest
/// @notice Test suite for the PerpetualVault contract
/// @dev Uses Forge's standard library for testing Ethereum smart contracts
contract PerpetualVaultTest is Test, ArbitrumTest {
  enum PROTOCOL {
    DEX,
    GMX
  }

  address payable vault;
  address payable vault2x;
  VaultReader reader;
  MockData mockData;

  event GmxPositionCallbackCalled(bytes32 requestKey, bool success);

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
    address gmxReader = address(0x0537C767cDAC0726c76Bb89e92904fe28fd02fE1);
    // address gmxReader = address(0x5Ca84c34a381434786738735265b9f3FD814b824);
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

    address keeper = makeAddr("keeper");

    reader = new VaultReader(
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

    data = abi.encodeWithSelector(
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
    address gmxProxy2x = address(
      new TransparentUpgradeableProxy(
        address(gmxUtilsLogic),
        address(proxyAdmin),
        data
      )
    );
    payable(gmxProxy2x).transfer(1 ether);

    data = abi.encodeWithSelector(
      PerpetualVault.initialize.selector,
      address(0x70d95587d40A2caf56bd97485aB3Eec10Bee6336), // ethUsdcMarket,
      keeper,
      makeAddr("treasury"),
      gmxProxy2x,
      reader,
      1e8,
      1e28,
      20_000
    );
    vm.prank(address(this), address(this));
    vault2x = payable(
      new TransparentUpgradeableProxy(
        address(perpetualVault),
        address(proxyAdmin),
        data
      )
    );

    mockData = new MockData();
  }
  /// @notice Fuzz test for deposit functionality
  /// @param amount The amount to deposit (fuzzed input)
  function testFuzz_Deposit(uint96 amount) external {
    IERC20 collateralToken = PerpetualVault(vault).collateralToken();
    address alice = makeAddr("alice");
    vm.startPrank(alice);
    deal(address(collateralToken), alice, amount);
    uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(true);
    uint256 maxDeposit = PerpetualVault(vault).maxDepositAmount();
    uint256 minDeposit = PerpetualVault(vault).minDepositAmount();
    collateralToken.approve(vault, amount);
    if (amount > maxDeposit) {
      vm.expectRevert(Error.ExceedMaxDepositCap.selector);
      PerpetualVault(vault).deposit{value: executionFee * tx.gasprice}(amount);
    } else if (amount < minDeposit) {
      vm.expectRevert(Error.InsufficientAmount.selector);
      PerpetualVault(vault).deposit{value: executionFee * tx.gasprice}(amount);
    } else {
      PerpetualVault(vault).deposit{value: executionFee * tx.gasprice}(amount);
      uint256[] memory depositIds = PerpetualVault(vault).getUserDeposits(alice);
      assertEq(depositIds.length, 1);
    }
    vm.stopPrank();

    assertEq(uint8(PerpetualVault(vault).flow()), 0);
    assertEq(PerpetualVault(vault).positionIsClosed(), true);
    (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 0);
  }
  /// @notice Tests the withdrawal process
  function test_Withdraw() external {
    address alice = makeAddr("alice");
    depositFixture(alice, 1e12);
    vm.startPrank(alice);

    uint256[] memory depositIds = PerpetualVault(vault).getUserDeposits(alice);
    uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(false);
    vm.expectRevert(Error.Locked.selector);
    PerpetualVault(vault).withdraw{value: executionFee * tx.gasprice}(alice, depositIds[0]);

    // simulate profit just by sending some tokens to the vault.
    uint256 profit = 1e7;
    IERC20 collateralToken = PerpetualVault(vault).collateralToken();
    deal(address(collateralToken), alice, profit);
    collateralToken.transfer(vault, profit);

    uint256 lockTime = PerpetualVault(vault).lockTime();
    vm.warp(block.timestamp + lockTime + 1);
    PerpetualVault(vault).withdraw{value: executionFee * tx.gasprice}(alice, depositIds[0]);


    uint256 feePercent = PerpetualVault(vault).governanceFee();
    address treasury = PerpetualVault(vault).treasury();
    uint256 collectedFee = collateralToken.balanceOf(treasury);
    assertEq(collectedFee * 10_000 / feePercent, profit);       // check fee amount
    vm.stopPrank();

    assertEq(uint8(PerpetualVault(vault).flow()), 0);
    assertEq(PerpetualVault(vault).positionIsClosed(), true);
    (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 0);
    // assertEq(uint8(PerpetualVault(vault).isNextAction()), 0);
  }

  /// @notice Tests opening a GMX position
  function test_Run_GmxPosition() external {
    address keeper = PerpetualVault(vault).keeper();
    address alice = makeAddr("alice");
    depositFixture(alice, 1e8);
    
    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory data = new bytes[](1);
    data[0] = abi.encode(3380000000000000);
    vm.prank(keeper);
    PerpetualVault(vault).run(true, false, prices, data);
    PerpetualVault.FLOW flow = PerpetualVault(vault).flow();
    assertEq(uint8(flow), 2);
    assertEq(PerpetualVault(vault).positionIsClosed(), true);
    (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 0);
    // assertEq(uint8(PerpetualVault(vault).isNextAction()), 0);

    GmxOrderExecuted(true);
    bytes32 curPositionKey = PerpetualVault(vault).curPositionKey();
    assertTrue(curPositionKey != bytes32(0));
    assertEq(PerpetualVault(vault).beenLong(), false);
  }
  /// @notice Tests opening a 2x long position
  function test_Run_Open2xLongPosition() external {
    address keeper = PerpetualVault(vault2x).keeper();
    address alice = makeAddr("alice");
    depositFixtureInto2x(alice, 1e8);
    
    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory data = new bytes[](1);
    data[0] = abi.encode(3390000000000000);
    vm.prank(keeper);
    PerpetualVault(vault2x).run(true, true, prices, data);
    PerpetualVault.FLOW flow = PerpetualVault(vault2x).flow();
    assertEq(uint8(flow), 2);
    assertEq(PerpetualVault(vault2x).positionIsClosed(), true);
    (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(vault2x).nextAction();
    assertEq(uint8(selector), 0);
    // assertEq(uint8(PerpetualVault(vault).isNextAction()), 0);

    GmxOrderExecuted2x(true);
    bytes32 curPositionKey = PerpetualVault(vault2x).curPositionKey();
    assertTrue(curPositionKey != bytes32(0));
    assertEq(PerpetualVault(vault2x).beenLong(), true);
  }
  
  /// @notice Tests swapping using Paraswap
  function test_Run_Paraswap() external {
    address keeper = PerpetualVault(vault).keeper();
    address alice = makeAddr("alice");
    depositFixture(alice, 1e10);

    MarketPrices memory prices = mockData.getMarketPrices();
    bytes memory paraSwapData = mockData.getParaSwapData(vault);
    bytes[] memory swapData = new bytes[](1);
    swapData[0] = abi.encode(PROTOCOL.DEX, paraSwapData);
    vm.prank(keeper);
    PerpetualVault(vault).run(true, true, prices, swapData);
    
    assertEq(uint8(PerpetualVault(vault).flow()), 0);
    assertEq(PerpetualVault(vault).positionIsClosed(), false);
    (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 0);
    // assertEq(uint8(PerpetualVault(vault).isNextAction()), 0);
  }

  /// @notice Tests order cancellation when GMX swap doesn't meet minOutputAmount
  function test_OrderCancellation_GmxSwapDoesNotMeetMinOutputAmount() external {
    uint256 amountIn = 1e10;
    address keeper = PerpetualVault(vault).keeper();
    address alice = makeAddr("alice");
    depositFixture(alice, amountIn);

    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory swapData = new bytes[](1);
    address[] memory gmxPath = new address[](1);
    gmxPath[0] = address(0x70d95587d40A2caf56bd97485aB3Eec10Bee6336);
    uint256 minOutputAmount = amountIn * prices.shortTokenPrice.min / prices.longTokenPrice.min;
    swapData[0] = abi.encode(PROTOCOL.GMX, abi.encode(gmxPath, amountIn, minOutputAmount));

    vm.prank(keeper);
    PerpetualVault(vault).run(true, true, prices, swapData);
    assertNotEq(uint8(PerpetualVault(vault).flow()), 0);
    // assertEq(PerpetualVault(vault).isBusy(), true);

    GmxOrderExecuted(false);
    address indexToken = PerpetualVault(vault).indexToken();
    uint256 indexTokenBalance = IERC20(indexToken).balanceOf(vault);
    assertEq(indexTokenBalance, 0);
    (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 2);
    // assertEq(uint8(PerpetualVault(vault).isNextAction()), 2);   // SWAP_ACTION
    assertEq(uint8(PerpetualVault(vault).flow()), 2);     // SIGNAL_CHANGE
  }

  /// @notice Tests swapping directly on GMX
  function test_Run_GmxSwap() external {
    uint256 amountIn = 1e10;
    address keeper = PerpetualVault(vault).keeper();
    address alice = makeAddr("alice");
    depositFixture(alice, amountIn);

    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory swapData = new bytes[](1);
    address[] memory gmxPath = new address[](1);
    gmxPath[0] = address(0x70d95587d40A2caf56bd97485aB3Eec10Bee6336);
    uint256 minOutputAmount = amountIn * prices.shortTokenPrice.min / prices.longTokenPrice.min * 95 / 100;   // 5% slippage
    swapData[0] = abi.encode(PROTOCOL.GMX, abi.encode(gmxPath, amountIn, minOutputAmount));

    vm.prank(keeper);
    PerpetualVault(vault).run(true, true, prices, swapData);
    assertNotEq(uint8(PerpetualVault(vault).flow()), 0);
    // assertEq(PerpetualVault(vault).isBusy(), true);

    GmxOrderExecuted(true);
    address indexToken = PerpetualVault(vault).indexToken();
    uint256 indexTokenBalance = IERC20(indexToken).balanceOf(vault);
    assertApproxEqRel(indexTokenBalance * prices.indexTokenPrice.min, amountIn * prices.shortTokenPrice.min, 1e17);   // 10%
  }

  /// @notice Tests combined Paraswap and GMX swap
  function test_Run_GmxParaswap() external {
    address keeper = PerpetualVault(vault).keeper();
    address alice = makeAddr("alice");
    depositFixture(alice, 2e10);
    
    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory swapData = new bytes[](2);
    bytes memory paraSwapData = mockData.getParaSwapData(vault);
    swapData[0] = abi.encode(PROTOCOL.DEX, paraSwapData);
    address[] memory gmxPath = new address[](1);
    gmxPath[0] = address(0x70d95587d40A2caf56bd97485aB3Eec10Bee6336);
    uint256 minOutputAmount = 1e10 * prices.shortTokenPrice.min / prices.longTokenPrice.min * 95 / 100;   // 5% slippage
    swapData[1] = abi.encode(PROTOCOL.GMX, abi.encode(gmxPath, 1e10, minOutputAmount));

    vm.prank(keeper);
    PerpetualVault(vault).run(true, true, prices, swapData);
    assertNotEq(uint8(PerpetualVault(vault).flow()), 0);
    // assertEq(PerpetualVault(vault).isBusy(), true);

    GmxOrderExecuted(true);
    assertEq(uint8(PerpetualVault(vault).flow()), 0);
    assertEq(PerpetualVault(vault).positionIsClosed(), false);
    (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 0);
    // assertEq(uint8(PerpetualVault(vault).isNextAction()), 0);
  }

  /// @notice Tests changing position signal
  function test_Run_SignalChange() external {
    address keeper = PerpetualVault(vault).keeper();
    address alice = makeAddr("alice");
    depositFixture(alice, 2e10);

    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory swapData = new bytes[](2);
    bytes memory paraSwapData = mockData.getParaSwapData(vault);
    swapData[0] = abi.encode(PROTOCOL.DEX, paraSwapData);
    address[] memory gmxPath = new address[](1);
    gmxPath[0] = address(0x70d95587d40A2caf56bd97485aB3Eec10Bee6336);
    uint256 minOutputAmount = 1e10 * prices.shortTokenPrice.min / prices.longTokenPrice.min * 95 / 100;   // 5% slippage
    swapData[1] = abi.encode(PROTOCOL.GMX, abi.encode(gmxPath, 1e10, minOutputAmount));

    vm.prank(keeper);
    PerpetualVault(vault).run(true, true, prices, swapData);

    assertEq(PerpetualVault(vault).isLock(), true);
    GmxOrderExecuted(true);
    
    assertEq(uint8(PerpetualVault(vault).flow()), 0);
    assertEq(PerpetualVault(vault).positionIsClosed(), false);
    (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 0);
    // assertEq(uint8(PerpetualVault(vault).isNextAction()), 0);

    gmxPath[0] = address(0x70d95587d40A2caf56bd97485aB3Eec10Bee6336);
    address indexToken = PerpetualVault(vault).indexToken();
    uint256 indexTokenBalance = IERC20(indexToken).balanceOf(vault);
    bytes[] memory newSwapData = new bytes[](1);
    minOutputAmount = indexTokenBalance * prices.longTokenPrice.min / prices.shortTokenPrice.min * 95 / 100;   // 5% slippage
    newSwapData[0] = abi.encode(PROTOCOL.GMX, abi.encode(gmxPath, indexTokenBalance, minOutputAmount));
    vm.prank(keeper);
    PerpetualVault(vault).run(true, false, prices, newSwapData);

    GmxOrderExecuted(true);
    assertEq(uint8(PerpetualVault(vault).flow()), 2);
    assertEq(PerpetualVault(vault).positionIsClosed(), true);
    (selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 1);
    // assertEq(uint8(PerpetualVault(vault).isNextAction()), 1);

    swapData[0] = abi.encode(3380000000000000);
    swapData[1] = hex'';
    vm.prank(keeper);
    PerpetualVault(vault).runNextAction(prices, swapData);


    assertEq(PerpetualVault(vault).isLock(), true);
    GmxOrderExecuted(true);
    vm.prank(keeper);
    PerpetualVault(vault).runNextAction(prices, new bytes[](0));

    assertEq(uint8(PerpetualVault(vault).flow()), 0);
    assertEq(PerpetualVault(vault).positionIsClosed(), false);
    (selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 0);
    // assertEq(uint8(PerpetualVault(vault).isNextAction()), 0);

    uint256 total = PerpetualVault(vault).totalAmount(prices);
    emit log_named_decimal_uint("Total Amount", total, 6);
    bytes32 positionKey = PerpetualVault(vault).curPositionKey();
    VaultReader.PositionData memory positionData = reader.getPositionInfo(positionKey, prices);
    emit log_named_decimal_uint("Size In USD", positionData.sizeInUsd, 30);
    emit log_named_decimal_uint("Size In Tokens", positionData.sizeInTokens, 6);
    emit log_named_decimal_uint("Collateral Amount", positionData.collateralAmount, 6);
    emit log_named_decimal_uint("Net Value", positionData.netValue, 30);
    assertEq(positionData.isLong, false);
  }

  /// @notice Tests withdrawing from a GMX position
  function test_Withdraw_FromGmxPosition() external {
    address keeper = PerpetualVault(vault).keeper();
    address alice = makeAddr("alice");
    depositFixture(alice, 1e10);
    
    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory data = new bytes[](1);
    data[0] = abi.encode(3380000000000000);
    vm.prank(keeper);
    PerpetualVault(vault).run(true, false, prices, data);
    PerpetualVault.FLOW flow = PerpetualVault(vault).flow();
    assertEq(uint8(flow), 2);

    GmxOrderExecuted(true);
    vm.prank(keeper);
    PerpetualVault(vault).runNextAction(prices, new bytes[](0));

    uint256[] memory depositIds = PerpetualVault(vault).getUserDeposits(alice);
    uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(false);

    uint256 lockTime = 1;
    PerpetualVault(vault).setLockTime(lockTime);
    vm.warp(block.timestamp + lockTime + 1);
    vm.expectRevert(Error.InvalidUser.selector);
    PerpetualVault(vault).withdraw{value: executionFee * tx.gasprice}(alice, depositIds[0]);
    payable(alice).transfer(1 ether);
    vm.prank(alice);
    PerpetualVault(vault).withdraw{value: executionFee * tx.gasprice}(alice, depositIds[0]);

    GmxOrderExecuted(true);

    bytes[] memory swapData = new bytes[](2);
    swapData[0] = abi.encode(3390000000000000);
    vm.prank(keeper);
    PerpetualVault(vault).runNextAction(prices, swapData);

    GmxOrderExecuted(true);

    (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 6);
    // uint8 isNextAction = uint8(PerpetualVault(vault).isNextAction());
    // assertEq(isNextAction, 6);

    bytes[] memory metadata = new bytes[](0);
    vm.prank(keeper);
    PerpetualVault(vault).runNextAction(prices, metadata);

    IERC20 collateralToken = PerpetualVault(vault).collateralToken();
    uint256 balance = IERC20(collateralToken).balanceOf(alice);
    emit log_named_decimal_uint("Withdrawn Amount", balance, 6);

    address treasury = PerpetualVault(vault).treasury();
    uint256 collectedFee = IERC20(collateralToken).balanceOf(treasury);
    assertEq(collectedFee, 0);
  }

  /// @notice Tests depositing into an existing GMX position
  function test_DepositIntoGmx() external {
    address alice = makeAddr("alice");
    payable(alice).transfer(1 ether);
    depositFixture(alice, 1e10);

    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory data = new bytes[](2);
    data[0] = abi.encode(3380000000000000);
    address keeper = PerpetualVault(vault).keeper();
    vm.prank(keeper);
    PerpetualVault(vault).run(true, false, prices, data);
    GmxOrderExecuted(true);
    bytes[] memory metadata = new bytes[](0);
    vm.prank(keeper);
    PerpetualVault(vault).runNextAction(prices, metadata);

    IERC20 collateralToken = PerpetualVault(vault).collateralToken();
    uint256 amount = 1e12;
    deal(address(collateralToken), alice, amount);
    uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(true);
    vm.startPrank(alice);
    collateralToken.approve(vault, amount);
    PerpetualVault(vault).deposit{value: executionFee * tx.gasprice}(amount);
    vm.stopPrank();

    uint8 flow = uint8(PerpetualVault(vault).flow());
    assertEq(flow, 1);
    (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 1);
    // uint8 isNextAction = uint8(PerpetualVault(vault).isNextAction());
    // assertEq(isNextAction, 1);

    data[0] = abi.encode(3380000000000000);
    vm.prank(keeper);
    PerpetualVault(vault).runNextAction(prices, data);

    GmxOrderExecuted(true);

    uint256[] memory depositIds = PerpetualVault(vault).getUserDeposits(alice);
    assertEq(depositIds.length, 2);
    
    (selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 6);
    // isNextAction = uint8(PerpetualVault(vault).isNextAction());
    // assertEq(isNextAction, 6);
    flow = uint8(PerpetualVault(vault).flow());
    assertNotEq(flow, 0);
    // bool isBusy = PerpetualVault(vault).isBusy();
    // assertEq(isBusy, true);
    vm.prank(keeper);
    delete data;
    PerpetualVault(vault).runNextAction(prices, data);
    (selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 0);
    // isNextAction = uint8(PerpetualVault(vault).isNextAction());
    // assertEq(isNextAction, 0);
    flow = uint8(PerpetualVault(vault).flow());
    assertEq(flow, 0);
    // isBusy = PerpetualVault(vault).isBusy();
    // assertEq(isBusy, false);
  }

  /// @notice Tests cancelling a deposit
  function test_CancelDeposit() external {
    address alice = makeAddr("alice");
    payable(alice).transfer(1 ether);
    depositFixture(alice, 1e10);

    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory data = new bytes[](1);
    data[0] = abi.encode(3380000000000000);
    address keeper = PerpetualVault(vault).keeper();
    vm.prank(keeper);
    PerpetualVault(vault).run(true, false, prices, data);
    GmxOrderExecuted(true);
    vm.prank(keeper);
    PerpetualVault(vault).runNextAction(prices, data);

    IERC20 collateralToken = PerpetualVault(vault).collateralToken();
    uint256 amount = 1e12;
    deal(address(collateralToken), alice, amount);
    uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(true);
    vm.startPrank(alice);
    collateralToken.approve(vault, amount);
    PerpetualVault(vault).deposit{value: executionFee * tx.gasprice}(amount);
    vm.stopPrank();

    bool isLock = PerpetualVault(vault).isLock();
    assertEq(isLock, false);

    uint256 ethBalBefore = alice.balance;
    vm.prank(keeper);
    PerpetualVault(vault).cancelFlow();
    assertTrue(ethBalBefore < alice.balance);

    (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 6);
    // uint8 isNextAction = uint8(PerpetualVault(vault).isNextAction());
    // assertEq(isNextAction, 6);
    uint8 flow = uint8(PerpetualVault(vault).flow());
    assertEq(flow, 5);
  }

  /// @notice Tests deposit revert when paused
  function test_Revert_DepositIf_Paused() external {
    address owner = PerpetualVault(vault).owner();
    vm.prank(owner);
    PerpetualVault(vault).setDepositPaused(true);

    address alice = makeAddr("alice");
    payable(alice).transfer(1 ether);
    IERC20 collateralToken = PerpetualVault(vault).collateralToken();
    uint256 amount = 1e12;
    deal(address(collateralToken), alice, amount);
    uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(true);
    vm.startPrank(alice);
    collateralToken.approve(vault, amount);
    vm.expectRevert(Error.Paused.selector);
    PerpetualVault(vault).deposit{value: executionFee * tx.gasprice}(amount);
    vm.stopPrank();
  }

  function test_ExecutionFeeGasLimit() external {
    // executionFeeGasLimit should be zero if there's no active position
    uint256 executionGasLimit = PerpetualVault(vault).getExecutionGasLimit(true);
    assertEq(executionGasLimit, 0);
    executionGasLimit = PerpetualVault(vault).getExecutionGasLimit(false);
    assertEq(executionGasLimit, 0);

    // Otherwise, executionGasLimit should be over zero
    address alice = makeAddr("alice");
    payable(alice).transfer(1 ether);
    depositFixture(alice, 1e10);

    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory data = new bytes[](1);
    data[0] = abi.encode(3380000000000000);
    address keeper = PerpetualVault(vault).keeper();
    vm.prank(keeper);
    PerpetualVault(vault).run(true, false, prices, data);
    GmxOrderExecuted(true);

    executionGasLimit = PerpetualVault(vault).getExecutionGasLimit(true);
    assertTrue(executionGasLimit > 0);
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

    uint8 flow = uint8(PerpetualVault(vault).flow());
    assertEq(flow, 1);
    (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 1);
    // uint8 isNextAction = uint8(PerpetualVault(vault).isNextAction());
    // assertEq(isNextAction, 1);

    MarketPrices memory prices = mockData.getMarketPrices();
    bytes[] memory data = new bytes[](2);
    data[0] = abi.encode(3380000000000000);
    address keeper = PerpetualVault(vault).keeper();
    vm.prank(keeper);
    PerpetualVault(vault).runNextAction(prices, data);

    vm.warp(block.timestamp + 1000);
    vm.prank(keeper);
    PerpetualVault(vault).cancelOrder();

    (selector, ) = PerpetualVault(vault).nextAction();
    assertEq(uint8(selector), 1);
    // isNextAction = uint8(PerpetualVault(vault).isNextAction());
    // assertEq(isNextAction, 1);
    prices = mockData.getMarketPrices();
    vm.prank(keeper);
    PerpetualVault(vault).runNextAction(prices, data);
  }

  function test_RefundGas_When_Using_Paraswap_Only() external {
    address keeper = PerpetualVault(vault).keeper();
    address alice = makeAddr("alice");
    depositFixture(alice, 1e10);

    MarketPrices memory prices = mockData.getMarketPrices();
    bytes memory paraSwapData = mockData.getParaSwapData(vault);
    bytes[] memory swapData = new bytes[](1);
    swapData[0] = abi.encode(PROTOCOL.DEX, paraSwapData);
    vm.prank(keeper);
    PerpetualVault(vault).run(true, true, prices, swapData);

    IERC20 collateralToken = PerpetualVault(vault).collateralToken();
    uint256 amount = 1e10;
    deal(address(collateralToken), alice, amount);
    deal(alice, 1e18);
    uint256 executionFee = PerpetualVault(vault).getExecutionGasLimit(true);
    vm.startPrank(alice);
    collateralToken.approve(vault, amount);
    PerpetualVault(vault).deposit{value: executionFee * tx.gasprice}(amount);
    vm.stopPrank();

    prices = mockData.getMarketPrices();
    uint256 ethBalBefore = alice.balance;
    vm.prank(keeper);
    PerpetualVault(vault).runNextAction(prices, swapData);
    assertTrue(ethBalBefore < alice.balance);
  }

  /// @notice Simulates GMX order execution
  /// @dev Internal function to mock GMX order execution
  function simulateGmxOrderExecution() internal {
    address gmxProxy = address(PerpetualVault(vault).gmxProxy());
    (bytes32 requestKey, ) = GmxProxy(payable(gmxProxy)).queue();

    address[] memory primaryTokens = new address[](2);
    primaryTokens[0] = address(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    primaryTokens[1] = address(0xaf88d065e77c8cC2239327C5EDb3A432268e5831);
    PriceProps[] memory primaryPrices = mockData.getOraclePrices();
    uint256 minTimestamp = block.timestamp;
    uint256 maxTimestamp = minTimestamp + 100;
    IExchangeRouter.SimulatePricesParams memory params = IExchangeRouter.SimulatePricesParams({
      primaryTokens: primaryTokens,
      primaryPrices: primaryPrices,
      minTimestamp: minTimestamp,
      maxTimestamp: maxTimestamp
    });

    address exchangeRouter = address(0x900173A66dbD345006C51fA35fA3aB760FcD843b);
    bytes4 error = hex'4e48dcda';     // EndOfSimulation Error
    vm.expectRevert(error);
    IExchangeRouter(exchangeRouter).simulateExecuteOrder(requestKey, params);
  }

  /// @notice Simulates successful GMX order execution
  /// @param success Whether the order execution was successful
  /// @dev Internal function to mock successful GMX order execution
  function GmxOrderExecuted(bool success) internal {
    address gmxProxy = address(PerpetualVault(vault).gmxProxy());
    (bytes32 requestKey, ) = GmxProxy(payable(gmxProxy)).queue();

    MockData.OracleSetPriceParams memory params = mockData.getOracleParams();
    address gmxKeeper = address(0x6A2B3A13be0c723674BCfd722d4e133b3f356e05);
    address orderHandler = address(0xe68CAAACdf6439628DFD2fe624847602991A31eB);
    vm.expectEmit();
    emit GmxPositionCallbackCalled(requestKey, success);
    vm.prank(gmxKeeper);
    IOrderHandler(orderHandler).executeOrder(requestKey, params);
  }

  function GmxOrderExecuted2x(bool success) internal {
    address gmxProxy = address(PerpetualVault(vault2x).gmxProxy());
    (bytes32 requestKey, ) = GmxProxy(payable(gmxProxy)).queue();

    MockData.OracleSetPriceParams memory params = mockData.getOracleParams();
    address gmxKeeper = address(0x6A2B3A13be0c723674BCfd722d4e133b3f356e05);
    address orderHandler = address(0xe68CAAACdf6439628DFD2fe624847602991A31eB);
    vm.expectEmit();
    emit GmxPositionCallbackCalled(requestKey, success);
    vm.prank(gmxKeeper);
    IOrderHandler(orderHandler).executeOrder(requestKey, params);
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

  function depositFixtureInto2x(address user, uint256 amount) internal {
    IERC20 collateralToken = PerpetualVault(vault2x).collateralToken();
    vm.startPrank(user);
    deal(address(collateralToken), user, amount);
    uint256 executionFee = PerpetualVault(vault2x).getExecutionGasLimit(true);
    collateralToken.approve(vault2x, amount);
    PerpetualVault(vault2x).deposit{value: executionFee * tx.gasprice}(amount);
    vm.stopPrank();
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
    address keeper = PerpetualVault(vault).keeper();
    vm.prank(keeper);
    PerpetualVault(vault).run(true, false, prices, data);
    GmxOrderExecuted(true);

    delete data;
    vm.prank(keeper);
    PerpetualVault(vault).runNextAction(prices, data);
  }
}
