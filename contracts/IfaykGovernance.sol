// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;








interface IfaykeGovernance {

    event AnOfficialWasElected(address indexed newCaller, bytes32 indexed  peopleName_satrap, uint32 indexed roleId);
    event AnOfficialWasConfirmed(address indexed newCaller, bytes32 indexed  peopleName_satrap, uint32 indexed roleId);
    event NewValueForTheDefaultTimePeriod(uint48 indexed newPeriodTime);
    event ChangeBanedOfThisRole(bool baned, uint32 indexed  roleId, bytes32 indexed peopleName_satrap);
    event ChangeClosedOfThisFunction(address indexed  target, bytes4 indexed Fselector, bool indexed closed);
    event AddressConnectedToConnector(bytes32 indexed  contractTypeName, bytes32 indexed  peopleName_satrap, address indexed  addContract);
    event ContractExistenceStateChanged(bytes32 indexed  peopleName_satrap, bytes32 indexed  contractTypeName, bool indexed exist);
    event RoleExistenceStateChanged(bytes32 indexed  peopleName_satrap, uint32 indexed  roleId, bool indexed exist);
    event roleInfoChanged(bytes32 indexed  peopleName_satrap, uint32 indexed  roleId);
    event targetsChanged(address indexed  target, bytes4 indexed  selector,uint32 indexed roleId); 
    event TargetIsNotValid(address indexed target, uint256 index);
    event RoleIdIsNotValid(address indexed target, uint256 index);
    event SelectorIsNotValid(address indexed target, uint256 index);

    error TheAddressIsInvalid(address addContract);
    error RoleIdConflict(uint32 callerRoleId);
    error PeopleName_SatrapConflict(bytes32 caller_peopleName_satrap);
    error YourAccessTimeIsNotValid(uint48 caller_since, uint48 caller_EndSession);
    error ThisFunctionIsClosed(address target, bytes4 Fselector);
    error YouAreBanned(uint32 caller_roleId, bytes32  caller_peopleName_satrap);

    
}