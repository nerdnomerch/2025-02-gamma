// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FuzzUtils {
    function _getSyntheticTokenAddress(string memory tokenSymbol) internal view returns (address) {
        uint256 chainId = block.chainid;
        bytes32 hashedData = keccak256(abi.encode(chainId, tokenSymbol));
        bytes20 addressBytes = bytes20(hashedData << 96);
        return address(addressBytes);
    }

    function _hashData(
        string memory key,
        address address1,
        address address2
    ) internal pure returns (bytes32) {
        bytes32 hashedKey = keccak256(abi.encode(keccak256(abi.encode(key)), address1, address2));
        return hashedKey;
    }

    function _hashData(
        string memory key,
        address address1,
        bool addedBool
    ) internal pure returns (bytes32) {
        bytes32 hashedKey = keccak256(abi.encode(keccak256(abi.encode(key)), address1, addedBool));
        return hashedKey;
    }
}
