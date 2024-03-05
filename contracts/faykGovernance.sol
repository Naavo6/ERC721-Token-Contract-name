// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Authority} from "contracts/authority.sol";
import "@openzeppelin/contracts/utils/types/Time.sol";






contract faykGovernance is Authority {
    //using Time for *;


    event AnOfficialWasElected(address indexed newCaller, bytes32 indexed  peopleName_satrap, uint32 indexed roleId);
    event AnOfficialWasConfirmed(address indexed newCaller, bytes32 indexed  peopleName_satrap, uint32 indexed roleId);


    struct CallerInfo {
        bytes32 peopleName_satrap; //be in nokte tavajoh kon ke etelaate peopleName va satrap mitavanad dar yek bitmap Zakhire shavad badha avazesh kon
        uint32 roleId;
        uint48 since;
        uint48 EndSession;
    }

    struct TargetConfig {
        uint32 roleId;
        bytes32 peopleName_satrap;
        uint48 executeDelay;
        bool closed;
    }

    struct Role {
        bytes32 roleLabel;
        uint32 admin;
        uint32 guardian;
        uint48 periodTime;
    }

    mapping(address caller => CallerInfo callerInfo) private _callerInfo;
    mapping(bytes32 contractTypeName => mapping (bytes32 peopleName_satrap => address addContract)) private _connectorMapping;
    mapping(uint32 roleId => mapping (bytes32 peopleName_satrap => Role roleInfo)) private _roleinfo;
    mapping(address target => mapping(bytes4 selector => TargetConfig roleAccess)) private _targets;


    modifier onlyPrimeMinister() {
        require(msg.sender == getPrimeMinisterAdd() && !getPrimeMinisterBan(), "Access is not valid");

        _;
    }

    modifier onlyPrimeRepublic() {
         if (TimeFirstElection < block.timestamp) {
            require(msg.sender == getRepublicAddress(), "Access is not valid");

        } else require(msg.sender == getPrimeMinisterAdd() && !getPrimeMinisterBan(), "Access is not valid");

        _;
    }

    modifier onlyAdmin(uint32 roleId, bytes32 peopleName_satrap) {
        CallerInfo memory _admin = _callerInfo[msg.sender];
        require(_admin.roleId == _roleinfo[roleId][peopleName_satrap].admin && _admin.roleId, "Access is not valid");

        _;
    }

    function setCallerInfo (
    bool deletedOldCaller,
    address oldCaller,
    address newCaller,
    bytes32 peopleName_satrap,
    uint32 roleId) 
    public onlyAdmin(roleId, peopleName_satrap) {
        if (oldCaller == newCaller) {
            _callerInfo[newCaller].EndSession += _roleinfo[roleId][peopleName_satrap].periodTime;

        } else if (deletedOldCaller) {
            _callerInfo[newCaller].EndSession = (_callerInfo[oldCaller].EndSession + _roleinfo[roleId][peopleName_satrap].periodTime);
            _callerInfo[newCaller].since = block.timestamp;
            delete _callerInfo[oldCaller];
        } else if (_callerInfo[oldCaller].since == 0) {
            _callerInfo[newCaller].since = block.timestamp;
            _callerInfo[newCaller].EndSession = (block.timestamp + _roleinfo[roleId][peopleName_satrap].periodTime);
        } else {

        }

            _callerInfo[newCaller].peopleName_satrap = peopleName_satrap;
            _callerInfo[newCaller].roleId = roleId;

        emit AnOfficialWasElected(newCaller, peopleName_satrap, roleId);
    }
    
    function transferCallerInfo() public {
       if (_callerInfo[msg.sender].roleId > 0 && _callerInfo[msg.sender].since == 0) {
        _callerInfo[msg.sender];

        emit AnOfficialWasConfirmed(msg.sender, _callerInfo[msg.sender].peopleName_satrap, _callerInfo[msg.sender].roleId);

       } else revert AccessOnlyForThePendig();
    }
   
}