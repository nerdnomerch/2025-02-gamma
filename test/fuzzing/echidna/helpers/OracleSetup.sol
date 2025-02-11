// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./BaseSetup.sol";

contract OracleSetup is BaseSetup {
    mapping(address => uint256) private minTokenPrices;
    mapping(address => uint256) private maxTokenPrices;

    function SetOraclePrices(
        address[] memory tokens,
        uint256[] memory maxPrices,
        uint256[] memory minPrices
    ) internal returns (OracleUtils.SetPricesParams memory) {
        require(
            tokens.length == minPrices.length && tokens.length == maxPrices.length,
            "Tokens, minPrices, and maxPrices arrays must have the same length"
        );

        for (uint256 i = 0; i < tokens.length; i++) {
            _setMinPrice(tokens[i], minPrices[i]);
            _setMaxPrice(tokens[i], maxPrices[i]);
        }

        OracleUtils.SetPricesParams memory oracleParams = _setupOracleParams(tokens);
        return oracleParams;
    }

    function SetOraclePrices(
        address[] memory tokens,
        uint[] memory prices
    ) internal returns (OracleUtils.SetPricesParams memory) {
        require(
            tokens.length == prices.length,
            "Tokens and prices arrays must have the same length"
        );

        for (uint256 i = 0; i < tokens.length; i++) {
            _setMinPrice(tokens[i], prices[i]);
            _setMaxPrice(tokens[i], prices[i]);
        }

        OracleUtils.SetPricesParams memory oracleParams = _setupOracleParams(tokens);

        return oracleParams;
    }

    function _setMinPrice(address token, uint256 price) internal {
        require(price > 0, "Zero price is not supported");
        require(
            token == address(WETH) ||
                token == address(WBTC) ||
                token == address(USDC) ||
                token == address(USDT) ||
                token == SOL,
            "Unsupported token"
        );
        minTokenPrices[token] = price;
    }

    function _setMaxPrice(address token, uint256 price) internal {
        require(
            token == address(WETH) ||
                token == address(WBTC) ||
                token == address(USDC) ||
                token == address(USDT) ||
                token == address(SOL),
            "Unsupported token"
        );
        maxTokenPrices[token] = price;
    }

    function _setupOracleParams(
        address[] memory tokens
    ) internal returns (OracleUtils.SetPricesParams memory) {
        uint256[] memory precisions = _getPrecisions(tokens);
        uint256[] memory minPrices = _getMinPrices(tokens);
        uint256[] memory maxPrices = _getMaxPrices(tokens);
        address[] memory providers = _getProviders(tokens);

        _setTokenPrices(tokens, minPrices, maxPrices, precisions, providers);

        OracleUtils.SetPricesParams memory oracleParams = OracleUtils.SetPricesParams({
            tokens: tokens,
            providers: providers,
            data: new bytes[](tokens.length)
        });

        return oracleParams;
    }

    function _setTokenPrices(
        address[] memory tokens,
        uint256[] memory minPrices,
        uint256[] memory maxPrices,
        uint256[] memory precisions,
        address[] memory providers
    ) internal {
        for (uint256 i = 0; i < tokens.length; i++) {
            chainlinkMock.setOraclePrice(tokens[i], minPrices[i], maxPrices[i], precisions[i]);
        }
    }

    function _getPrecisions(address[] memory tokens) internal view returns (uint256[] memory) {
        uint256[] memory precisions = new uint[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            precisions[i] = _getPrecision(tokens[i]);
        }
        return precisions;
    }

    function _getMinPrices(address[] memory tokens) internal view returns (uint256[] memory) {
        uint256[] memory minPrices = new uint[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            minPrices[i] = _getMinPrice(tokens[i]);
        }
        return minPrices;
    }

    function _getMaxPrices(address[] memory tokens) internal view returns (uint256[] memory) {
        uint256[] memory maxPrices = new uint[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            maxPrices[i] = _getMaxPrice(tokens[i]);
        }
        return maxPrices;
    }

    function _getProviders(address[] memory tokens) internal view returns (address[] memory) {
        address[] memory providers = new address[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            providers[i] = address(chainlinkMock);
        }
        return providers;
    }

    function _getMinPrice(address token) internal view returns (uint256) {
        uint256 price = minTokenPrices[token];

        require(price != 0, "Min price not set for token");
        return price;
    }

    function _getMaxPrice(address token) internal view returns (uint256) {
        uint256 price = maxTokenPrices[token];

        require(price != 0, "Max price not set for token");
        return price;
    }
}
