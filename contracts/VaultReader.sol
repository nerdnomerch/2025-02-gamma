// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./libraries/StructData.sol";
import "./libraries/gmx/MarketUtils.sol";
import "./interfaces/IPerpetualVault.sol";
import "./interfaces/IGmxProxy.sol";
import "./interfaces/IVaultReader.sol";
import "./PerpetualVault.sol";

contract VaultReader is IVaultReader {
  using SafeCast for uint256;

  bytes32 public constant SIZE_IN_USD = keccak256(abi.encode("SIZE_IN_USD"));
  bytes32 public constant SIZE_IN_TOKENS = keccak256(abi.encode("SIZE_IN_TOKENS"));
  bytes32 public constant POSITION_FEE_FACTOR = keccak256(abi.encode("POSITION_FEE_FACTOR"));

  uint256 public constant PRECISION = 1e30;

  address public orderHandler;
  IDataStore public dataStore;
  address public orderVault;
  IGmxReader public gmxReader;
  address public referralStorage;

  constructor(
    address _orderHandler,
    address _dataStore,
    address _orderVault,
    address _reader,
    address _referralStorage
  ) {
    orderHandler = _orderHandler;
    dataStore = IDataStore(_dataStore);
    orderVault = address(_orderVault);
    gmxReader = IGmxReader(_reader);
    referralStorage = address(_referralStorage);
  }

  /**
  * @notice Retrieves the position information for a given key and market prices.
  * @param key The key representing the position.
  * @param prices The current market prices for the relevant tokens.
  * @return PositionData The data structure containing detailed information about the position.
  */
  function getPositionInfo(
    bytes32 key,
    MarketPrices memory prices
  ) external view returns (PositionData memory) {
    uint256 sizeInTokens = getPositionSizeInUsd(key);
    if (sizeInTokens == 0) {
      return PositionData({
        sizeInUsd: 0,
        sizeInTokens: 0,
        collateralAmount: 0,
        netValue: 0,
        pnl: 0,
        isLong: true
      });
    }
    PositionInfo memory positionInfo = gmxReader.getPositionInfo(
      address(dataStore),
      referralStorage,
      key,
      prices,
      uint256(0),
      address(0),
      true
    );
    uint256 netValue = 
      positionInfo.position.numbers.collateralAmount * prices.shortTokenPrice.min +
      positionInfo.fees.funding.claimableLongTokenAmount * prices.longTokenPrice.min +
      positionInfo.fees.funding.claimableShortTokenAmount * prices.shortTokenPrice.min -
      positionInfo.fees.borrowing.borrowingFeeUsd -
      positionInfo.fees.funding.fundingFeeAmount * prices.shortTokenPrice.min -
      positionInfo.fees.positionFeeAmount * prices.shortTokenPrice.min;
    
    if (positionInfo.basePnlUsd >= 0) {
      netValue = netValue + uint256(positionInfo.basePnlUsd);
    } else {
      netValue = netValue - uint256(-positionInfo.basePnlUsd);
    }

    return PositionData({
      sizeInUsd: positionInfo.position.numbers.sizeInUsd,
      sizeInTokens: positionInfo.position.numbers.sizeInTokens,
      collateralAmount: positionInfo.position.numbers.collateralAmount,
      netValue: netValue,
      pnl: positionInfo.basePnlUsd,
      isLong: positionInfo.position.flags.isLong
    });
  }

  function getNegativeFundingFeeAmount(
    bytes32 key,
    MarketPrices memory prices
  ) external view returns (uint256) {
    uint256 sizeInTokens = getPositionSizeInUsd(key);
    if (sizeInTokens == 0) return 0;
    PositionInfo memory positionInfo = gmxReader.getPositionInfo(
      address(dataStore),
      referralStorage,
      key,
      prices,
      uint256(0),
      address(0),
      true
    );

    return positionInfo.fees.funding.fundingFeeAmount;
  }

  function willPositionCollateralBeInsufficient(
    MarketPrices memory prices,
    bytes32 positionKey,
    address market,
    bool isLong,
    uint256 sizeDeltaUsd,
    uint256 collateralDeltaAmount
  ) external view returns (bool) {
    if (getPositionSizeInUsd(positionKey) == 0) return true;
    PositionInfo memory positionInfo = gmxReader.getPositionInfo(
      address(dataStore),
      referralStorage,
      positionKey,
      prices,
      uint256(0),
      address(0),
      true
    );
    int256 realizedPnlUsd;
    if (positionInfo.basePnlUsd > 0) {
      realizedPnlUsd = (uint256(positionInfo.basePnlUsd) * sizeDeltaUsd / positionInfo.position.numbers.sizeInUsd).toInt256();
    } else {
      realizedPnlUsd = -(uint256(-positionInfo.basePnlUsd) * uint256(sizeDeltaUsd) / uint256(positionInfo.position.numbers.sizeInUsd)).toInt256();
    }
    MarketUtils.WillPositionCollateralBeSufficientValues memory values = MarketUtils.WillPositionCollateralBeSufficientValues({
      positionSizeInUsd: positionInfo.position.numbers.sizeInUsd - sizeDeltaUsd,
      positionCollateralAmount: positionInfo.position.numbers.collateralAmount - collateralDeltaAmount,
      realizedPnlUsd: realizedPnlUsd,
      openInterestDelta: -int256(sizeDeltaUsd)
    });
    MarketProps memory marketInfo = getMarket(market);
    (bool willBeSufficient, ) = MarketUtils.willPositionCollateralBeSufficient(
      dataStore,
      marketInfo,
      prices,
      isLong,
      values
    );

    return !willBeSufficient;
  }

  function getPriceImpactInCollateral(
    bytes32 positionKey,
    uint256 sizeDeltaInUsd,
    uint256 prevSizeInTokens,
    MarketPrices memory prices
  ) external view returns (int256) {
    uint256 expectedSizeInTokensDelta = sizeDeltaInUsd / prices.indexTokenPrice.min;
    uint256 curSizeInTokens = getPositionSizeInTokens(positionKey);
    uint256 realSizeInTokensDelta = curSizeInTokens - prevSizeInTokens;
    int256 priceImpactInTokens = expectedSizeInTokensDelta.toInt256() - realSizeInTokensDelta.toInt256();
    int256 priceImpactInCollateralTokens = priceImpactInTokens * prices.indexTokenPrice.min.toInt256() / prices.shortTokenPrice.min.toInt256();
    return priceImpactInCollateralTokens;
  }

  function getPnl(
    bytes32 key,
    MarketPrices memory prices,
    uint256 sizeDeltaUsd
  ) external view returns (int256) {
    uint256 sizeInTokens = getPositionSizeInUsd(key);
    if (sizeInTokens == 0) return 0;
    
    PositionInfo memory positionInfo = gmxReader.getPositionInfo(
      address(dataStore),
      referralStorage,
      key,
      prices,
      sizeDeltaUsd,
      address(0),
      true
    );

    return positionInfo.pnlAfterPriceImpactUsd;
  }

  /**
  * @notice Retrieves the position size in USD for a given key.
  * @param key The key representing the position.
  * @return sizeInUsd The size of the position in USD.
  */
  function getPositionSizeInUsd(bytes32 key) public view returns (uint256 sizeInUsd) {
    sizeInUsd = dataStore.getUint(keccak256(abi.encode(key, SIZE_IN_USD)));
  }

  /**
  * @notice Retrieves the position size in tokens for a given key.
  * @param key The key representing the position.
  * @return sizeInTokens The size of the position in tokens.
  */
  function getPositionSizeInTokens(bytes32 key) public view returns (uint256 sizeInTokens) {
    sizeInTokens = dataStore.getUint(keccak256(abi.encode(key, SIZE_IN_TOKENS)));
  }

  /**
  * @notice Retrieves the market properties for a given market address.
  * @param market The address of the market to retrieve properties for.
  * @return MarketProps The data structure containing properties of the specified market.
  */
  function getMarket(address market) public view returns (MarketProps memory) {
    return gmxReader.getMarket(address(dataStore), market);
  }

  /**
  * @notice Calculates the position fee in USD for a given market and size delta.
  * @param market The address of the market.
  * @param sizeDeltaUsd The USD value of the size delta.
  * @param forPositiveImpact Indicates if the order action balances open interest (true) or not (false).
  * @return positionFeeAmount The calculated position fee amount in USD.
  */
  function getPositionFeeUsd(address market, uint256 sizeDeltaUsd, bool forPositiveImpact) external view returns (uint256 positionFeeAmount) {
    uint256 positionFeeFactor = dataStore.getUint(keccak256(abi.encode(
      POSITION_FEE_FACTOR,
      market,
      forPositiveImpact
    )));
    positionFeeAmount = sizeDeltaUsd * positionFeeFactor / PRECISION;
  }
}
