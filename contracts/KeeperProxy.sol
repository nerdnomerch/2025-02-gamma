// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./libraries/StructData.sol";
import "./interfaces/IPerpetualVault.sol";
import "./interfaces/IGmxProxy.sol";
import "./interfaces/IVaultReader.sol";

interface AggregatorV2V3Interface {
  function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
}

interface IERC20Meta {
  function decimals() external view returns (uint8);
}

/**
 * @title KeeperProxy
 * @dev This contract acts as a proxy for executing keeper functions on a PerpetualVault.
 *      It handles price validation and ensures the correct execution of actions.
 */
contract KeeperProxy is Initializable, Ownable2StepUpgradeable, ReentrancyGuardUpgradeable {
  using SafeCast for int256;

  uint256 constant BPS = 10_000;
  uint256 private constant GRACE_PERIOD_TIME = 3600;
  AggregatorV2V3Interface internal sequencerUptimeFeed;
  mapping (address => address) public dataFeed;
  uint256 threshold;
  mapping (address => uint256) public maxTimeWindow;
  mapping (address => bool) public keepers;
  mapping (address => uint256) public  priceDiffThreshold;

  modifier onlyKeeper() {
    require(keepers[msg.sender], "not a keeper");
    _;
  }

  /**
   * @notice Initializes the contract.
   * @dev Sets the initial threshold value and initializes inherited contracts.
   */
  function initialize() external initializer {
    __Ownable2Step_init();
    sequencerUptimeFeed = AggregatorV2V3Interface(0xFdB631F5EE196F0ed6FAa767959853A9F217697D);
  }

  /**
   * @notice Executes a run action on the specified PerpetualVault.
   * @dev Validates the price before executing the run action.
   * @param perpVault The address of the PerpetualVault.
   * @param isOpen Indicates if the position should be opened.
   * @param isLong Indicates if the position is long.
   * @param prices The market prices used for validation.
   * @param _swapData The swap data for the run action.
   */
  function run(
    address perpVault,
    bool isOpen,
    bool isLong,
    MarketPrices memory prices,
    bytes[] memory _swapData
  ) external onlyKeeper {
    _validatePrice(perpVault, prices);
    IPerpetualVault(perpVault).run(isOpen, isLong, prices, _swapData);
  }

  /**
   * @notice Executes the next action on the specified PerpetualVault.
   * @dev Validates the price before executing the next action.
   * @param perpVault The address of the PerpetualVault.
   * @param prices The market prices used for validation.
   * @param _swapData The swap data for the next action.
   */
  function runNextAction(address perpVault, MarketPrices memory prices, bytes[] memory _swapData) external onlyKeeper {
    _validatePrice(perpVault, prices);
    IPerpetualVault(perpVault).runNextAction(prices, _swapData);
  }
  
  /**
   * @notice Call `cancelDeposit` function of a vault
   * @param perpVault The address of the PerpetualVault
   */
  function cancelFlow(address perpVault) external onlyKeeper {
    IPerpetualVault(perpVault).cancelFlow();
  }

  /**
   * @notice
   *  GMX keepers would not always execute orders in a reasonable amount of time.
   *  This function is called when the requested Order is not executed in GMX side.
   */
  function cancelOrder(address perpVault) external onlyKeeper {
    IPerpetualVault(perpVault).cancelOrder();
  }

  function claimCollateralRebates(address perpVault, uint256[] memory timeKeys) external onlyKeeper {
    IPerpetualVault(perpVault).claimCollateralRebates(timeKeys);
  }

  /**
   * @notice Sets the data feed address for a specific token.
   * @dev Can only be called by the owner of the contract.
   * @param token The address of the token.
   * @param feed The address of the data feed.
   * @param _maxTimeWindow allowed update delay for a chainlink price feed
   * @param _threshold price offset threshold
   */
  function setDataFeed(address token, address feed, uint256 _maxTimeWindow, uint256 _threshold) external onlyOwner {
    require(token != address(0), "zero address");
    require(feed != address(0), "zero address");
    dataFeed[token] = feed;
    maxTimeWindow[token] = _maxTimeWindow;
    priceDiffThreshold[token] = _threshold;
  }

  /**
   * @notice Sets the threshold value for price validation.
   * @dev Can only be called by the owner of the contract.
   * @param _threshold The new threshold value.
   */
  function setThreshold(address token, uint256 _threshold) external onlyOwner {
    require(_threshold > 0, "zero value");
    priceDiffThreshold[token] = _threshold;
  }

  /**
   * @notice set maxTimeWindow value for a given token data feed
   * @param token address of token
   * @param _maxTimeWindow value to set
   */
  function setMaxTimeWindow(address token, uint256 _maxTimeWindow) external onlyOwner {
    require(_maxTimeWindow > 0, "zero value");
    maxTimeWindow[token] = _maxTimeWindow;
  }

  /**
   * @notice add or remove keeper account
   * @param _keeper keeper account address to add or remove
   * @param isSet true if add, false if remove
   */
  function setKeeper(address _keeper, bool isSet) external onlyOwner {
    keepers[_keeper] = isSet;
  }

  /**
   * @notice Validates the market prices against the Chainlink data feed.
   * @dev Internal function to check the prices of the market tokens.
   * @param perpVault The address of the PerpetualVault.
   * @param prices The market prices used for validation.
   */
  function _validatePrice(address perpVault, MarketPrices memory prices) internal view {
    // L2 Sequencer check
    (
      /*uint80 roundID*/,
      int256 answer,
      uint256 startedAt,
      /*uint256 updatedAt*/,
      /*uint80 answeredInRound*/
    ) = AggregatorV2V3Interface(sequencerUptimeFeed).latestRoundData();
    bool isSequencerUp = answer == 0;
    require(isSequencerUp, "sequencer is down");
    // Make sure the grace period has passed after the sequencer is back up.
    uint256 timeSinceUp = block.timestamp - startedAt;
    require(timeSinceUp > GRACE_PERIOD_TIME, "Grace period is not over");

    address market = IPerpetualVault(perpVault).market();
    IVaultReader reader = IPerpetualVault(perpVault).vaultReader();
    MarketProps memory marketData = reader.getMarket(market);
    
    _check(marketData.indexToken, prices.indexTokenPrice.min);
    _check(marketData.indexToken, prices.indexTokenPrice.max);
    _check(marketData.longToken, prices.indexTokenPrice.min);
    _check(marketData.longToken, prices.indexTokenPrice.max);
    _check(marketData.shortToken, prices.shortTokenPrice.min);
    _check(marketData.shortToken, prices.shortTokenPrice.max);
  }

  /**
   * @notice Checks the price difference between the given price and the Chainlink price.
   * @dev Internal function to ensure the price difference is within the threshold.
   * @param token The address of the token.
   * @param price The price to be checked.
   */
  function _check(address token, uint256 price) internal view {
    // https://github.com/code-423n4/2021-06-tracer-findings/issues/145
    (, int chainLinkPrice, , uint256 updatedAt, ) = AggregatorV2V3Interface(dataFeed[token]).latestRoundData();
    require(updatedAt > block.timestamp - maxTimeWindow[token], "stale price feed");
    uint256 decimals = 30 - IERC20Meta(token).decimals();
    price = price / 10 ** (decimals - 8); // Chainlink price decimals is always 8.
    require(
      _absDiff(price, chainLinkPrice.toUint256()) * BPS / chainLinkPrice.toUint256() < priceDiffThreshold[token],
      "price offset too big"
    );
  }

  /**
   * @notice Calculates the absolute difference between two numbers.
   * @dev Internal pure function to calculate the absolute difference.
   * @param a The first number.
   * @param b The second number.
   * @return diff The absolute difference between the two numbers.
   */
  function _absDiff(uint256 a, uint256 b) internal pure returns (uint256 diff) {
    if (a > b) return a - b;
    else return b - a;
  }
}
