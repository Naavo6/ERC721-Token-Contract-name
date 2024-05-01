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

    struct Jomhor {
        mapping(bytes32 => bool) existContractTypeName;
        mapping(uint32 => bool) existRoleId;
    }

    mapping(bytes32 peopleName_satrap => Jomhor peopleInfo) private _jomhorInfo;
    mapping(address caller => CallerInfo callerInfo) private _callerInfo;
    mapping(bytes32 contractTypeName => mapping (bytes32 peopleName_satrap => address addContract)) private _connectorMapping; //hatman onlyprimeRepublic
    mapping(uint32 roleId => mapping (bytes32 peopleName_satrap => Role roleInfo)) private _roleInfo; //hatman onlyprimeRepublic
    mapping(address target => mapping(bytes4 selector => TargetConfig roleAccess)) private _targets;


    modifier onlyPrimeMinister() {
        require(msg.sender == getPrimeMinisterAdd() && !getPrimeMinisterBan(), "Access is not valid");

        _;
    }

    modifier onlyPrimeRepublicG() {
         if (TimeFirstElection < block.timestamp) {
            require(msg.sender == getRepublicGAddress(), "Access is not valid");

        } else require(msg.sender == getPrimeMinisterAdd() && !getPrimeMinisterBan(), "Access is not valid");

        _;
    }

    modifier onlyAdminOrGuardian(uint8 adminOrGuardian, uint32 roleId, bytes32 peopleName_satrap) {
        CallerInfo memory caller = _callerInfo[msg.sender];
        if (caller.roleId > 10) {
            require(caller.peopleName_satrap == peopleName_satrap, "Access is not valid");
        }

        require(!getBaned(roleId, caller.peopleName_satrap) && caller.EndSession > block.timestamp, "Access is not valid");

        if (adminOrGuardian == 1) {
            require(caller.roleId == _roleInfo[roleId][peopleName_satrap].admin, "Access is not valid");

        } else require(caller.roleId == _roleInfo[roleId][peopleName_satrap].guardian, "Access is not valid");

        _;
    }

    constructor() {
        _callerInfo[getAuthorityAddress()].peopleName_satrap = "All";
        _callerInfo[getAuthorityAddress()].roleId = 1;
        _callerInfo[getAuthorityAddress()].since = uint48(block.timestamp);
        _callerInfo[getAuthorityAddress()].EndSession = 43830 days;

        _callerInfo[getRepublicGAddress()].peopleName_satrap = "All";
        _callerInfo[getRepublicGAddress()].roleId = 2;
        _callerInfo[getRepublicGAddress()].since = uint48(block.timestamp);
        _callerInfo[getRepublicGAddress()].EndSession = 43830 days;

        _callerInfo[getPrimeMinisterAdd()].peopleName_satrap = "All";
        _callerInfo[getPrimeMinisterAdd()].roleId = 4;
        _callerInfo[getPrimeMinisterAdd()].since = uint48(block.timestamp);
        _callerInfo[getPrimeMinisterAdd()].EndSession = 43830 days;

        _jomhorInfo["All"].existContractTypeName["Authority"] = true;
        _jomhorInfo["All"].existContractTypeName["RepublicG"] = true;
        _jomhorInfo["All"].existRoleId[1] = true;
        _jomhorInfo["All"].existRoleId[2] = true;
        _jomhorInfo["All"].existRoleId[4] = true;

        _roleInfo[1]["All"].admin = 1;
        _roleInfo[1]["All"].guardian = 1;
        _roleInfo[2]["All"].admin = 1;
        _roleInfo[2]["All"].guardian = 1;
        _roleInfo[4]["All"].admin = 1;
        _roleInfo[4]["All"].guardian = 1;

    }

    function setBaned(bool baned, uint32 roleId, bytes32 peopleName_satrap) public onlyAdminOrGuardian(2, roleId, peopleName_satrap) {
        _roleInfo[roleId][peopleName_satrap].baned = baned;

        emit ChangeBanedOfThisRole(baned, roleId, peopleName_satrap);
    }

    function getBaned(uint32 roleId, bytes32 peopleName_satrap) public view returns (bool) {
        return _roleInfo[roleId][peopleName_satrap].baned;
    }

    function setDefaultPeriodTime(uint48 newPeriodTime) public onlyPrimeRepublicG {
        require(newPeriodTime >= 365 days, "The amount must be at least one year");
        _defaultPeriodTime = newPeriodTime;

        emit NewValueForTheDefaultTimePeriod(newPeriodTime);
    }

    function getDefaultPeriodTime() public view returns (uint48) {
        return _defaultPeriodTime;
    }

    function setJomhorInfo() public onlyPrimeRepublicG {
        
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
            if ((newCaller == getAuthorityAddress()) || roleId == 2 || roleId == 4) {  
                _callerInfo[newCaller].EndSession = uint48(block.timestamp) + periodTime;
            }

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


    function setConnectorMapping(bytes32 contractTypeName, bytes32 peopleName_satrap, address addContract) public onlyPrimeRepublicG {
        if (addContract.code.length > 0) {
            _connectorMapping[contractTypeName][peopleName_satrap] = addContract;

            emit AddressConnectedToConnector(contractTypeName, peopleName_satrap, addContract);

        } else revert TheAddressIsInvalid(addContract);
    }

    function setRoleInfo(bytes32 people_satrap, uint32[] memory roleId_, Role[] memory roleInfo_) public view onlyPrimeRepublicG {
        uint256 iL = roleId_.length;
        require(iL == roleInfo_.length, "The length of the arrays is different");

    }

    function getConnectorMapping(bytes32 contractTypeName, bytes32 peopleName_satrap) public view returns (address) {
        return  _connectorMapping[contractTypeName][peopleName_satrap];
    }

    function getCMWitthCallerAddress(address caller, bytes32 contractTypeName) public view returns (address) {
        CallerInfo memory caller_ = _callerInfo[caller];
        return getConnectorMapping(contractTypeName, caller_.peopleName_satrap);
    }
    
   
}