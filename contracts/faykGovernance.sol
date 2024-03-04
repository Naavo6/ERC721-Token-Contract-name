// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Authority} from "contracts/authority.sol";
import "@openzeppelin/contracts/utils/types/Time.sol";






contract faykGovernance is Authority {
    //using Time for *;




    struct CallerInfo {
        bytes32 peopleName_satrap; // be in nokte tavajoh kon ke etelaate peopleName va satrap mitavanad dar yek bitmap Zakhire shavad badha avazesh kon
        uint32 roleId;
        uint48 since;
        Time.Delay delay;
    }

    struct TargetConfig {
        uint32 roleId;
        bytes32 peopleName_satrap;
        Time.Delay adminDelay;
        bool closed;
    }

    struct Role {
        bytes32 roleLabel;
        uint32 admin;
        uint32 guardian;
        Time.Delay grantDelay;
    }

    mapping(address caller => CallerInfo callerInfo) private _callerInfo;
    mapping(bytes32 contractTypeName => mapping (bytes32 peopleName_satrap => address addContract)) private _connectorMapping;
    mapping(uint32 roleId => mapping (bytes32 peopleName_satrap => Role roleInfo)) private _roleinfo;
    mapping(address target => mapping(bytes4 selector => TargetConfig roleAccess)) private _targets;




    
    
   
}