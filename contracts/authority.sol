// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import {Republic_S} from "contracts/Republic_S.sol";





contract Authorrity is Republic_S {

    error AccessOnlyForThePendigPresident();
    error TheAddressIsNotValidForGC(address NewGCAddress);


    event TheNextPresidentWasElected(address indexed newPresidentAdd);
    event TheNewPresidentWasConfirmed(address indexed presidentAdd, uint32 indexed nonce);
    event TheNextGCAddressWasElected(address indexed newGCAddress);
    event TheNewGCAddressWasConfirmed(address indexed GCAddress, uint32 indexed version);


   address private _pendingGCAddress;
   address private _pendigPresident;
   uint48 immutable TimeFirstElection;

   struct access {
    address rolAdd;
    bool baned;
    uint32 nonce;
   }

   access private _president;
   access private _governance;
   // access private _primeMinister;
   
   modifier onlyRepublic() {
    if (TimeFirstElection < block.timestamp) {
        require(msg.sender == getRepublic_GAddress(), "Access is not valid");

    } else require(msg.sender == getPresidentAdd() && getPresidentBan(), "Access is not valid");

    _;
   }

   modifier onlyPresident() {
    require(msg.sender == getPresidentAdd() && getPresidentBan(), "Access is not valid");

    _;
   }

   constructor() {
    TimeFirstElection = uint48(block.timestamp + 4400 days);
    _president.rolAdd = msg.sender;
    _president.nonce++;
   }



   function setPendigPresident(address newPresident) public onlyRepublic {
    _pendigPresident = newPresident;

    emit TheNextPresidentWasElected(newPresident);
   }

   function transferPresident() public {
    if (_pendigPresident == msg.sender) {
        delete _pendigPresident;
        _president.rolAdd = msg.sender;
        _president.nonce++;
        emit TheNewPresidentWasConfirmed(_president.rolAdd, _president.nonce);

    } else revert AccessOnlyForThePendigPresident();
   }

   function getPresidentAdd() public view returns (address) {
    return _president.rolAdd;
   }

   function getPresidentBan() public view returns (bool) {
    return _president.baned;
   }

   function setPendingGovernanceContractAddress(address newGCAddress) public onlyRepublic {
    if (newGCAddress.code.length > 0) {
        _pendingGCAddress = newGCAddress;
        emit TheNextGCAddressWasElected(newGCAddress);

    } else revert TheAddressIsNotValidForGC(newGCAddress);

   }

   function transferGovernanceContractAddress(address pendingGCAdd) public onlyPresident {
    if (_pendingGCAddress == pendingGCAdd) {
        _governance.rolAdd = pendingGCAdd;
        _governance.nonce++;
        emit TheNewGCAddressWasConfirmed(_governance.rolAdd, _governance.nonce);

    } else revert TheAddressIsNotValidForGC(pendingGCAdd);
   }

   function getGovernance() public view returns (address) {
    return _governance.rolAdd;
   }

   function getgovernanceVersion() public view returns (uint32) {
    return _governance.nonce
   }

   function setban










}