// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;




contract Republic_S {

    address private _RepublicGAddress;



    function getRepublic_GAddress() public view returns (address RG) {
        return _RepublicGAddress;
    }

}