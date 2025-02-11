// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../setup/FuzzStorageVars.sol";
import "fuzzlib/FuzzBase.sol";
import {Test, console2} from "forge-std/Test.sol";
import {IHevm} from "fuzzlib/IHevm.sol";

abstract contract FunctionCalls is FuzzStorageVars, FuzzBase, Test {
    // IHevm internal hevm = IHevm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D)); //workaround for direct prank call

    //Events
    event RoleChangingCall(
        address caller,
        address grantedTo,
        bytes32 role,
        bool success
    );
    event OracleSignerAdded(address caller, address addedSigner, bool success);
    event SetUintDataStoreCall(
        address caller,
        bytes32 key,
        uint256 value,
        bool success
    );
    event SetBoolDataStoreCall(
        address caller,
        bytes32 key,
        bool value,
        bool success
    );
    event SetBytes32DataStoreCall(
        address caller,
        bytes32 key,
        bytes32 value,
        bool success
    );
    event SetAddressDataStoreCall(
        address caller,
        bytes32 key,
        address addressTo,
        bool success
    );

    error dataWriteError();

    // GAMMA Functions

    function _gamma_DepositCall(
        address user,
        address vault,
        uint256 amount,
        uint256 executionFee
    ) internal returns (bool success, bytes memory returnData) {
        bytes memory data = abi.encodeWithSelector(
            PerpetualVaultLens.deposit.selector,
            amount
        );

        uint256 value = executionFee * tx.gasprice;
        vm.prank(user);
        (success, returnData) = vault.call{value: value}(data);
    }

    function _gamma_CanceDepositCall(
        address vault,
        address gammaKeeper
    ) internal returns (bool success, bytes memory returnData) {
        bytes memory data = abi.encodeWithSelector(
            PerpetualVault.cancelFlow.selector
        );

        vm.prank(gammaKeeper);
        (success, returnData) = vault.call(data);
    }

    function _gamma_WithdrawCall(
        address user,
        address vault,
        uint256 depositId,
        uint256 executionFee
    ) internal returns (bool success, bytes memory returnData) {
        bytes memory data = abi.encodeWithSelector(
            PerpetualVaultLens.withdraw.selector,
            user,
            depositId
        );

        uint256 value = (executionFee * tx.gasprice) * 2; //NOTE: 2 executions
        vm.prank(user);
        (success, returnData) = vault.call{value: value}(data);
    }

    // GMX Functions
    function _roleChangingCall(
        address caller,
        address to,
        bytes32 role
    ) internal returns (bool success, bytes memory returnData) {
        vm.prank(caller);
        (success, returnData) = address(roleStore).call{gas: 1000000}(
            abi.encodeWithSelector(RoleStore.grantRole.selector, to, role)
        );
        if (!success) {
            revert dataWriteError();
        }
        emit RoleChangingCall(caller, to, role, success);
    }

    function _oracleAddSignerCall(
        address controller,
        address to
    ) internal returns (bool success, bytes memory returnData) {
        vm.prank(controller);
        (success, returnData) = address(oracleStore).call{gas: 1000000}(
            abi.encodeWithSelector(OracleStore.addSigner.selector, to)
        );
        if (!success) {
            revert dataWriteError();
        }
        emit OracleSignerAdded(controller, to, success);
    }

    function _setUintDataStoreCall(
        address caller,
        string memory key,
        uint256 value,
        address addedAddress
    ) internal returns (bool success, bytes memory returnData) {
        bytes32 hashedKey;
        if (addedAddress != address(0)) {
            hashedKey = keccak256(
                abi.encode(keccak256(abi.encode(key)), addedAddress)
            );
        } else {
            hashedKey = keccak256(abi.encode(key));
        }
        vm.prank(caller);
        (success, returnData) = address(dataStore).call{gas: 1000000}(
            abi.encodeWithSelector(DataStore.setUint.selector, hashedKey, value)
        );
        if (!success) {
            revert dataWriteError();
        }
        emit SetUintDataStoreCall(caller, hashedKey, value, success);
    }

    function _setUintDataStoreCall(
        address caller,
        string memory key,
        uint256 value,
        address addr1,
        address addr2
    ) internal returns (bool success, bytes memory returnData) {
        bytes32 hashedKey;
        hashedKey = _hashData(key, addr1, addr2);

        vm.prank(caller);
        (success, returnData) = address(dataStore).call{gas: 1000000}(
            abi.encodeWithSelector(DataStore.setUint.selector, hashedKey, value)
        );
        if (!success) {
            revert dataWriteError();
        }
        emit SetUintDataStoreCall(caller, hashedKey, value, success);
    }

    function _setUintDataStoreCall(
        address caller,
        string memory key,
        uint256 value,
        address addr1,
        bool addedBool
    ) internal returns (bool success, bytes memory returnData) {
        bytes32 hashedKey;
        hashedKey = _hashData(key, addr1, addedBool);

        vm.prank(caller);
        (success, returnData) = address(dataStore).call{gas: 1000000}(
            abi.encodeWithSelector(DataStore.setUint.selector, hashedKey, value)
        );
        if (!success) {
            revert dataWriteError();
        }
        emit SetUintDataStoreCall(caller, hashedKey, value, success);
    }

    function _setUintWithBoolDataStoreCall(
        address caller,
        string memory key,
        uint256 value,
        bool addedBool
    ) internal returns (bool success, bytes memory returnData) {
        bytes32 hashedKey = keccak256(
            abi.encode(keccak256(abi.encode(key)), addedBool)
        );

        vm.prank(caller);
        (success, returnData) = address(dataStore).call{gas: 1000000}(
            abi.encodeWithSelector(DataStore.setUint.selector, hashedKey, value)
        );
        if (!success) {
            revert dataWriteError();
        }
        emit SetUintDataStoreCall(caller, hashedKey, value, success);
    }

    function _setAddressDataStoreCall(
        address caller,
        string memory key,
        address addressAsValue,
        address addedAddress
    ) internal returns (bool success, bytes memory returnData) {
        bytes32 hashedKey;
        if (addedAddress != address(0)) {
            hashedKey = keccak256(
                abi.encode(keccak256(abi.encode(key)), addedAddress)
            );
        } else {
            hashedKey = keccak256(abi.encode(key));
        }
        vm.prank(caller);
        (success, returnData) = address(dataStore).call{gas: 1000000}(
            abi.encodeWithSelector(
                DataStore.setAddress.selector,
                hashedKey,
                addressAsValue
            )
        );
        if (!success) {
            revert dataWriteError();
        }
        emit SetAddressDataStoreCall(
            caller,
            hashedKey,
            addressAsValue,
            success
        );
    }

    function _setUintDataStoreCall(
        address caller,
        string memory string1,
        string memory string2,
        uint256 value,
        address market,
        bool isLong
    ) internal returns (bool success, bytes memory returnData) {
        bytes32 hashedString1 = keccak256(abi.encode(string1));

        bytes32 hashedKey = keccak256(
            abi.encode(
                hashedString1,
                keccak256(abi.encode(string2)),
                market,
                isLong
            )
        );

        vm.prank(caller);
        (success, returnData) = address(dataStore).call{gas: 1000000}(
            abi.encodeWithSelector(DataStore.setUint.selector, hashedKey, value)
        );
        if (!success) {
            revert dataWriteError();
        }
        emit SetUintDataStoreCall(caller, hashedKey, value, success);
    }

    function _setBoolDataStoreCall(
        address caller,
        string memory key,
        bool value,
        address addedAddress
    ) internal returns (bool success, bytes memory returnData) {
        bytes32 hashedKey;
        if (addedAddress != address(0)) {
            hashedKey = keccak256(
                abi.encode(keccak256(abi.encode(key)), addedAddress)
            );
        } else {
            hashedKey = keccak256(abi.encode(key));
        }

        vm.prank(caller);
        (success, returnData) = address(dataStore).call{gas: 1000000}(
            abi.encodeWithSelector(DataStore.setBool.selector, hashedKey, value)
        );
        if (!success) {
            revert dataWriteError();
        }
        emit SetBoolDataStoreCall(caller, hashedKey, value, success);
    }

    function _setBytes32DataStoreCall(
        address caller,
        string memory key,
        address addedAddress,
        bytes32 value
    ) internal returns (bool success, bytes memory returnData) {
        bytes32 hashedKey;
        hashedKey = keccak256(
            abi.encode(keccak256(abi.encode(key)), addedAddress)
        );

        vm.prank(caller);
        (success, returnData) = address(dataStore).call{gas: 1000000}(
            abi.encodeWithSelector(
                DataStore.setBytes32.selector,
                hashedKey,
                value
            )
        );
        if (!success) {
            revert dataWriteError();
        }
        emit SetBytes32DataStoreCall(caller, hashedKey, value, success);
    }
}
