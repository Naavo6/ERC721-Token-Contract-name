// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;




contract Republic {

    address private _RepublicAddress;
    address private _pendigRepublicAddress;
 

    function getRepublicAddress() public view returns (address RG) {
        return _RepublicAddress;
    }

}