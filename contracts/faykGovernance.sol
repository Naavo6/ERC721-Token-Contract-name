// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Authority} from "contracts/authority.sol";
import "@openzeppelin/contracts/utils/types/Time.sol";






contract faykGovernance is Authority {
    //using Time for *;

    struct People {
        bytes32 commName;
        mapping(bytes32 targetName => address targetAddress) Targets;
        //mapping()
    }
    mapping(address caller => people.commName) private pep;
    
    struct TargetConfig {
        mapping(bytes4 selector => uint32 rolId) allowedRols;
        Time.Delay adminDelay;
        bool closed;
    }

    struct Status {
        uint48 since;
        Time.Delay delay;
    }

    struct Rol {
        mapping(address user => Status status) members;
        bytes32 rolLabel;
        bytes32 peopleName;
        uint32 admin;
        uint32 guardian;
        Time.Delay grantDelay;
    }

    address _pendingPrimeMinister;
    access private _primeMinister;
    //mapping()
}