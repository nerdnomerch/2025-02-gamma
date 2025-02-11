// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../contracts/oracle/IOracleProvider.sol";

contract ChainlinkMock is IOracleProvider {
    event TokenPriceSet(address token, uint min, uint max);

    struct TokenPrice {
        uint min;
        uint max;
    }

    mapping(address => TokenPrice) private tokenPrices;

    function setOraclePrice(address token, uint min, uint max, uint precisions) public {
        uint minPrice = min * (10 ** precisions);
        uint maxPrice = max * (10 ** precisions);
        tokenPrices[token] = TokenPrice(minPrice, maxPrice);
        emit TokenPriceSet(token, minPrice, maxPrice);
    }
    function getOraclePrice(
        address token,
        bytes memory data
    ) external view returns (OracleUtils.ValidatedPrice memory) {
        TokenPrice memory tokenPrice = tokenPrices[token];

        return
            OracleUtils.ValidatedPrice({
                token: token,
                min: tokenPrice.min,
                max: tokenPrice.max,
                timestamp: block.timestamp,
                provider: address(this)
            });
    }
}
