// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import {Republic_S} from "contracts/Republic_S.sol";





contract Authorrity is Republic_S {

   address private _president;
   address private _primeMinister;
   address private _governance;
   uint48 immutable TimeFirstElection;


   modifier onlyRepublic() {
    if (TimeFirstElection > block.timestamp) {
        require(msg.sender == getRepublic_GAddress(), "");

    } else require(msg.sender == _president, "");

    _;
   }

   constructor() {
    TimeFirstElection = uint48(block.timestamp + 4400 days);
    _president = msg.sender;
   }



   function setPresident(address newPresident) public {

   }










}