# Solidity API

## Igovernance_set

### Contract
Igovernance_set : contracts/authority.sol

 --- 
### Functions:
### accessControl

```solidity
function accessControl(address caller, address target, bytes4 Fselector) external returns (bool accessed)
```

### setCaller

```solidity
function setCaller(bool deletedOldCaller, address oldCaller, address newCaller, bytes32 peopleName_satrap, uint32 roleId, uint48 periodTime) external
```

### setBaned

```solidity
function setBaned(bool baned, uint32 roleId, bytes32 peopleName_satrap) external
```

## Authority

### Contract
Authority : contracts/authority.sol

 --- 
### Modifiers:
### onlyRepublic

```solidity
modifier onlyRepublic()
```

### onlyRepublicG

```solidity
modifier onlyRepublicG()
```

### onlyPresident

```solidity
modifier onlyPresident()
```

### AccessCheck

```solidity
modifier AccessCheck(address caller)
```

 --- 
### Functions:
### constructor

```solidity
constructor() public
```

### setPendingRepublicGAddress

```solidity
function setPendingRepublicGAddress(address newRGAddress) public
```

### transferRepublicGAddress

```solidity
function transferRepublicGAddress(address RGAddress) public
```

### cancelPendingRepublicGAddress

```solidity
function cancelPendingRepublicGAddress(address PRGAdress) public
```

### getRepublicAddress

```solidity
function getRepublicAddress() public view returns (address R)
```

### getRepublicGAddress

```solidity
function getRepublicGAddress() public view returns (address RG)
```

### getAuthorityAddress

```solidity
function getAuthorityAddress() public view returns (address)
```

### setPendigPresident

```solidity
function setPendigPresident(address newPresident) public
```

### transferPresident

```solidity
function transferPresident() public
```

### getPresidentAdd

```solidity
function getPresidentAdd() public view returns (address)
```

### getPresidentBan

```solidity
function getPresidentBan() public view returns (bool)
```

### setPendingPrimeMinister

```solidity
function setPendingPrimeMinister(address newPM) public
```

### transferPrimeMinister

```solidity
function transferPrimeMinister() public
```

### getPrimeMinisterAdd

```solidity
function getPrimeMinisterAdd() public view returns (address)
```

### getPrimeMinisterBan

```solidity
function getPrimeMinisterBan() public view returns (bool)
```

### setPendingGovernanceContractAddress

```solidity
function setPendingGovernanceContractAddress(address newGCAddress) public
```

### transferGovernanceContractAddress

```solidity
function transferGovernanceContractAddress(address pendingGCAdd) public
```

### getGovernance

```solidity
function getGovernance() public view returns (address)
```

### getgovernanceVersion

```solidity
function getgovernanceVersion() public view returns (uint32)
```

### setPresidentBaned

```solidity
function setPresidentBaned(bool baned) public
```

### setPrimeMinisterBaned

```solidity
function setPrimeMinisterBaned(bool baned) public
```

 --- 
### Events:
### TheNextPresidentWasElected

```solidity
event TheNextPresidentWasElected(address newPresidentAdd)
```

### TheNewPresidentWasConfirmed

```solidity
event TheNewPresidentWasConfirmed(address presidentAdd, uint32 nonce)
```

### TheNextGCAddressWasElected

```solidity
event TheNextGCAddressWasElected(address newGCAddress)
```

### TheNewGCAddressWasConfirmed

```solidity
event TheNewGCAddressWasConfirmed(address GCAddress, uint32 version)
```

### TheStatusOfBanningAllActivitiesAndDone

```solidity
event TheStatusOfBanningAllActivitiesAndDone(bool baned, bool done)
```

### TheNextRepublicGAddressWasElected

```solidity
event TheNextRepublicGAddressWasElected(address newRepublicGAddress)
```

### TheNewRepublicGAddressWasConfirmed

```solidity
event TheNewRepublicGAddressWasConfirmed(address RepublicGAddress, uint32 version)
```

### TheNextRepublicGAddressWasCancelled

```solidity
event TheNextRepublicGAddressWasCancelled(address PRGAddress)
```

### TheNextPrimeMinisterWasElected

```solidity
event TheNextPrimeMinisterWasElected(address newPrimeMinister)
```

### TheNewPrimeMinisterWasConfirmed

```solidity
event TheNewPrimeMinisterWasConfirmed(address primeMinisterAdd, uint32 nonce)
```

## faykGovernance

### Contract
faykGovernance : contracts/faykGovernance.sol

 --- 
### Modifiers:
### onlyPrimeMinister

```solidity
modifier onlyPrimeMinister()
```

### onlyPrimeRepublicG

```solidity
modifier onlyPrimeRepublicG()
```

### onlyAdminOrGuardian

```solidity
modifier onlyAdminOrGuardian(uint8 adminOrGuardian, uint32 roleId, bytes32 peopleName_satrap)
```

 --- 
### Functions:
### constructor

```solidity
constructor() public
```

### setBaned

```solidity
function setBaned(bool baned, uint32 roleId, bytes32 peopleName_satrap) public
```

### getBaned

```solidity
function getBaned(uint32 roleId, bytes32 peopleName_satrap) public view returns (bool)
```

### setDefaultPeriodTime

```solidity
function setDefaultPeriodTime(uint48 newPeriodTime) public
```

### getDefaultPeriodTime

```solidity
function getDefaultPeriodTime() public view returns (uint48)
```

### setJomhorInfo

```solidity
function setJomhorInfo(bytes32 peopleName_satrap, bytes32 contractTypeName, uint32 roleId, bool exist) public
```

### checkExistJomhorInfo

```solidity
function checkExistJomhorInfo(bytes32 peopleName_satrap, bytes32 contractTypeName, uint32 roleId) public view returns (bool)
```

### setCaller

```solidity
function setCaller(bool deletedOldCaller, address oldCaller, address newCaller, bytes32 peopleName_satrap, uint32 roleId, uint48 periodTime) public
```

### transferCaller

```solidity
function transferCaller() public
```

### setConnectorMapping

```solidity
function setConnectorMapping(bytes32 contractTypeName, bytes32 peopleName_satrap, address addContract) public
```

### setRoleInfo

```solidity
function setRoleInfo(bytes32 peopleName_satrap, uint32[] roleId_, struct faykGovernance.Role[] roleInfo_) public
```

### getRoleInfo

```solidity
function getRoleInfo(bytes32 contractTypeName, uint32 roleId) public view returns (bytes32 roleLabel, uint32 admin, uint32 guardian, bool baned)
```

### setTargets

```solidity
function setTargets(address target, bytes4[] selector, struct faykGovernance.TargetConfig[] roleAccess) public
```

### getTargets

```solidity
function getTargets(address target, bytes4 selector) public view returns (struct faykGovernance.TargetConfig)
```

### getConnectorMapping

```solidity
function getConnectorMapping(bytes32 contractTypeName, bytes32 peopleName_satrap) public view returns (address)
```

### getCMWithCallerAddress

```solidity
function getCMWithCallerAddress(address caller, bytes32 contractTypeName) public view returns (address)
```

inherits Authority:
### setPendingRepublicGAddress

```solidity
function setPendingRepublicGAddress(address newRGAddress) public
```

### transferRepublicGAddress

```solidity
function transferRepublicGAddress(address RGAddress) public
```

### cancelPendingRepublicGAddress

```solidity
function cancelPendingRepublicGAddress(address PRGAdress) public
```

### getRepublicAddress

```solidity
function getRepublicAddress() public view returns (address R)
```

### getRepublicGAddress

```solidity
function getRepublicGAddress() public view returns (address RG)
```

### getAuthorityAddress

```solidity
function getAuthorityAddress() public view returns (address)
```

### setPendigPresident

```solidity
function setPendigPresident(address newPresident) public
```

### transferPresident

```solidity
function transferPresident() public
```

### getPresidentAdd

```solidity
function getPresidentAdd() public view returns (address)
```

### getPresidentBan

```solidity
function getPresidentBan() public view returns (bool)
```

### setPendingPrimeMinister

```solidity
function setPendingPrimeMinister(address newPM) public
```

### transferPrimeMinister

```solidity
function transferPrimeMinister() public
```

### getPrimeMinisterAdd

```solidity
function getPrimeMinisterAdd() public view returns (address)
```

### getPrimeMinisterBan

```solidity
function getPrimeMinisterBan() public view returns (bool)
```

### setPendingGovernanceContractAddress

```solidity
function setPendingGovernanceContractAddress(address newGCAddress) public
```

### transferGovernanceContractAddress

```solidity
function transferGovernanceContractAddress(address pendingGCAdd) public
```

### getGovernance

```solidity
function getGovernance() public view returns (address)
```

### getgovernanceVersion

```solidity
function getgovernanceVersion() public view returns (uint32)
```

### setPresidentBaned

```solidity
function setPresidentBaned(bool baned) public
```

### setPrimeMinisterBaned

```solidity
function setPrimeMinisterBaned(bool baned) public
```

 --- 
### Events:
### AnOfficialWasElected

```solidity
event AnOfficialWasElected(address newCaller, bytes32 peopleName_satrap, uint32 roleId)
```

### AnOfficialWasConfirmed

```solidity
event AnOfficialWasConfirmed(address newCaller, bytes32 peopleName_satrap, uint32 roleId)
```

### NewValueForTheDefaultTimePeriod

```solidity
event NewValueForTheDefaultTimePeriod(uint48 newPeriodTime)
```

### ChangeBanedOfThisRole

```solidity
event ChangeBanedOfThisRole(bool baned, uint32 roleId, bytes32 peopleName_satrap)
```

### AddressConnectedToConnector

```solidity
event AddressConnectedToConnector(bytes32 contractTypeName, bytes32 peopleName_satrap, address addContract)
```

### ContractExistenceStateChanged

```solidity
event ContractExistenceStateChanged(bytes32 peopleName_satrap, bytes32 contractTypeName, bool exist)
```

### RoleExistenceStateChanged

```solidity
event RoleExistenceStateChanged(bytes32 peopleName_satrap, uint32 roleId, bool exist)
```

### roleInfoChanged

```solidity
event roleInfoChanged(bytes32 peopleName_satrap, uint32 roleId)
```

### targetsChanged

```solidity
event targetsChanged(address target, bytes4 selector, uint32 roleId)
```

### TargetIsNotValid

```solidity
event TargetIsNotValid(address target, uint256 index)
```

### RoleIdIsNotValid

```solidity
event RoleIdIsNotValid(address target, uint256 index)
```

### SelectorIsNotValid

```solidity
event SelectorIsNotValid(address target, uint256 index)
```

inherits Authority:
### TheNextPresidentWasElected

```solidity
event TheNextPresidentWasElected(address newPresidentAdd)
```

### TheNewPresidentWasConfirmed

```solidity
event TheNewPresidentWasConfirmed(address presidentAdd, uint32 nonce)
```

### TheNextGCAddressWasElected

```solidity
event TheNextGCAddressWasElected(address newGCAddress)
```

### TheNewGCAddressWasConfirmed

```solidity
event TheNewGCAddressWasConfirmed(address GCAddress, uint32 version)
```

### TheStatusOfBanningAllActivitiesAndDone

```solidity
event TheStatusOfBanningAllActivitiesAndDone(bool baned, bool done)
```

### TheNextRepublicGAddressWasElected

```solidity
event TheNextRepublicGAddressWasElected(address newRepublicGAddress)
```

### TheNewRepublicGAddressWasConfirmed

```solidity
event TheNewRepublicGAddressWasConfirmed(address RepublicGAddress, uint32 version)
```

### TheNextRepublicGAddressWasCancelled

```solidity
event TheNextRepublicGAddressWasCancelled(address PRGAddress)
```

### TheNextPrimeMinisterWasElected

```solidity
event TheNextPrimeMinisterWasElected(address newPrimeMinister)
```

### TheNewPrimeMinisterWasConfirmed

```solidity
event TheNewPrimeMinisterWasConfirmed(address primeMinisterAdd, uint32 nonce)
```

