// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./OracleSetup.sol";
import "./MintSetup.sol";
import "../properties/Properties.sol";

contract PropertiesSetup is OracleSetup, MintSetup, Properties {}
