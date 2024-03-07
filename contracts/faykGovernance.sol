// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Authority} from "contracts/authority.sol";
import "@openzeppelin/contracts/utils/types/Time.sol";






contract faykGovernance is Authority {
    //using Time for *;


    event AnOfficialWasElected(address indexed newCaller, bytes32 indexed  peopleName_satrap, uint32 indexed roleId);
    event AnOfficialWasConfirmed(address indexed newCaller, bytes32 indexed  peopleName_satrap, uint32 indexed roleId);
    event NewValueForTheDefaultTimePeriod(uint48 indexed newPeriodTime);
    event ChangeBanedOfThisRole(bool baned, uint32 indexed  roleId, bytes32 indexed peopleName_satrap);
    event AddressConnectedToConnector(bytes32 indexed  contractTypeName, bytes32 indexed  peopleName_satrap, address indexed  addContract);


    error TheAddressIsInvalid(address addContract);

    uint48 private _defaultPeriodTime;


    struct CallerInfo {
        bytes32 peopleName_satrap; //be in nokte tavajoh kon ke etelaate peopleName va satrap mitavanad dar yek bitmap Zakhire shavad badha avazesh kon
        uint32 roleId;
        uint48 since;
        uint48 EndSession;
        address oldCaller;
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
        bool baned;
    }

    mapping(address caller => CallerInfo callerInfo) private _callerInfo;
    mapping(bytes32 contractTypeName => mapping (bytes32 peopleName_satrap => address addContract)) private _connectorMapping; //hatman onlyprimeRepublic
    mapping(uint32 roleId => mapping (bytes32 peopleName_satrap => Role roleInfo)) private _roleInfo; //hatman onlyprimeRepublic
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

    modifier onlyAdminOrGuardian(uint8 adminOrGuardian, uint32 roleId, bytes32 peopleName_satrap) {
        CallerInfo memory caller = _callerInfo[msg.sender];
        if (adminOrGuardian == 1) {
            require(caller.roleId == _roleInfo[roleId][peopleName_satrap].admin, "Access is not valid");

        } else require(caller.roleId == _roleInfo[roleId][peopleName_satrap].guardian, "Access is not valid");

        require(!getBaned(roleId, peopleName_satrap) && caller.EndSession > block.timestamp, "Access is not valid");

        _;
    }

    function setBaned(bool baned, uint32 roleId, bytes32 peopleName_satrap) public onlyAdminOrGuardian(2, roleId, peopleName_satrap) {
        _roleInfo[roleId][peopleName_satrap].baned = baned;

        emit ChangeBanedOfThisRole(baned, roleId, peopleName_satrap);
    }

    function getBaned(uint32 roleId, bytes32 peopleName_satrap) public view returns (bool) {
        return _roleInfo[roleId][peopleName_satrap].baned;
    }

    function setDefaultPeriodTime(uint48 newPeriodTime) public onlyPrimeRepublic {
        require(newPeriodTime >= 365 days, "The amount must be at least one year");
        _defaultPeriodTime = newPeriodTime;

        emit NewValueForTheDefaultTimePeriod(newPeriodTime);
    }

    function getDefaultPeriodTime() public view returns (uint48) {
        return _defaultPeriodTime;
    }


    function setCaller (
    bool deletedOldCaller,
    address oldCaller,
    address newCaller,
    bytes32 peopleName_satrap,
    uint32 roleId,
    uint48 periodTime) 
    public onlyAdminOrGuardian(1,roleId, peopleName_satrap) {// dar inja bayad deghat shavad ke admin role ha badha republic khahad bod
        if (oldCaller == newCaller) {
            _callerInfo[newCaller].EndSession += periodTime;
            if (getBaned(roleId, peopleName_satrap)) {
                _roleInfo[roleId][peopleName_satrap].baned = false;
            }

        } else if (deletedOldCaller) {
            _callerInfo[newCaller].EndSession = (_callerInfo[oldCaller].EndSession + periodTime);
            _callerInfo[newCaller].since = uint48(block.timestamp);
             delete _callerInfo[oldCaller];

            if (getBaned(roleId, peopleName_satrap)) {
                _roleInfo[roleId][peopleName_satrap].baned = false;
            }

        } else if (_callerInfo[oldCaller].since == 0) {
            _callerInfo[newCaller].since = uint48(block.timestamp);
            _callerInfo[newCaller].EndSession = uint48(block.timestamp) + _defaultPeriodTime;

        } else {
            _callerInfo[newCaller].since = _callerInfo[oldCaller].EndSession;
            _callerInfo[newCaller].oldCaller = oldCaller;
        }

        _callerInfo[newCaller].peopleName_satrap = peopleName_satrap;
        _callerInfo[newCaller].roleId = roleId;

        emit AnOfficialWasElected(newCaller, peopleName_satrap, roleId);
    }

    
    function transferCaller() public {
        CallerInfo memory caller = _callerInfo[msg.sender];
        if (caller.roleId > 0 && caller.since < block.timestamp && caller.EndSession == 0) {
            _callerInfo[msg.sender].EndSession = getDefaultPeriodTime();
            delete _callerInfo[caller.oldCaller];

            emit AnOfficialWasConfirmed(msg.sender, caller.peopleName_satrap, caller.roleId);

        } else revert AccessOnlyForThePendig();
    }


    function setConnectorMapping(bytes32 contractTypeName, bytes32 peopleName_satrap, address addContract) public onlyPrimeRepublic {
        if (addContract.code.length > 0) {
            _connectorMapping[contractTypeName][peopleName_satrap] = addContract;

            emit AddressConnectedToConnector(contractTypeName, peopleName_satrap, addContract);

        } else revert TheAddressIsInvalid(addContract);
    }

    function getConnectorMapping(bytes32 contractTypeName, bytes32 peopleName_satrap) public view returns (address) {
        return  _connectorMapping[contractTypeName][peopleName_satrap];
    }
    
   
}