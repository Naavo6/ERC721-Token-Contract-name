// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;




interface Igovernance_set {
    function accessControl(address caller, address target, bytes4 Fselector) external returns (bool accessed);
    function setCaller(bool deletedOldCaller, address oldCaller, address newCaller, bytes32 peopleName_satrap, uint32 roleId, uint48 periodTime) external;
    function setBaned(bool baned, uint32 roleId, bytes32 peopleName_satrap) external;
}





contract Authority {

    error TheAddressIsNotValidForRAddress(address newRGAddress);
    error AccessOnlyForThePendig();
    error TheAddressIsNotValidForGC(address NewGCAddress);
    error RemainingTimeUntilTheConfirmationDeadline(uint48 reminingTime);


    event TheNextPresidentWasElected(address indexed newPresidentAdd);
    event TheNewPresidentWasConfirmed(address indexed presidentAdd, uint32 indexed nonce);
    event TheNextGCAddressWasElected(address indexed newGCAddress);
    event TheNewGCAddressWasConfirmed(address indexed GCAddress, uint32 indexed version);
    event TheStatusOfBanningAllActivitiesAndDone(bool indexed baned, bool indexed done);
    event TheNextRepublicGAddressWasElected(address indexed newRepublicGAddress);
    event TheNewRepublicGAddressWasConfirmed(address indexed RepublicGAddress, uint32 indexed version);
    event TheNextRepublicGAddressWasCancelled(address indexed PRGAddress);
    event TheNextPrimeMinisterWasElected(address indexed newPrimeMinister);
    event TheNewPrimeMinisterWasConfirmed(address indexed primeMinisterAdd, uint32 indexed nonce);

    
    

    address private _pendigRepublicGAddress;
    address private _pendingGCAddress;
    address private _pendigPresident;
    address _pendingPrimeMinister;
    address immutable Republic = address(0); // in hatman bayad tagyir konad be address contract Republic
    uint48 immutable TimeFirstElection;
    uint48 private _delayConfirmRepublicGAddress;


    struct access {
        address roleAdd;
        bool baned;
        uint32 nonce;
    }

        
    access private _president;
    access private _primeMinister;
    access private _governance;
    access private _RepublicG;
    // access private _primeMinister;


    modifier onlyRepublic() {
        if (TimeFirstElection < block.timestamp) {
            require(msg.sender == getRepublicAddress(), "Access is not valid");

        } else require(msg.sender == getPresidentAdd() && !getPresidentBan(), "Access is not valid");

        _;
    }

    
    modifier onlyRepublicG() {
        if (TimeFirstElection < block.timestamp) {
            require(msg.sender == getRepublicGAddress(), "Access is not valid");

        } else require(msg.sender == getPresidentAdd() && !getPresidentBan(), "Access is not valid");

        _;
    }

    modifier onlyPresident() {
        require(msg.sender == getPresidentAdd() && !getPresidentBan(), "Access is not valid");

        _;
    }

    modifier AccessCheck(address caller) {
       Igovernance_set(_governance.roleAdd).accessControl(caller, msg.sender, msg.sig);
        
        _;
    }

    constructor() {
        TimeFirstElection = uint48(block.timestamp + 4383 days);
        _president.roleAdd = msg.sender;
        _president.nonce++;
    }

    function setPendingRepublicGAddress(address newRGAddress) public onlyRepublic {
        if (newRGAddress.code.length > 0) {
            if (_president.roleAdd == msg.sender) {
                _transferRepublicGAddress(newRGAddress);

            } else {
                _delayConfirmRepublicGAddress = uint48(block.timestamp + 15 days);
                _pendigRepublicGAddress = newRGAddress;
                emit TheNextRepublicGAddressWasElected(newRGAddress);
            }

        } else revert TheAddressIsNotValidForRAddress(newRGAddress);

    }

    function transferRepublicGAddress(address RGAddress) public onlyRepublic {
        if (_delayConfirmRepublicGAddress < block.timestamp) {
            require(_delayConfirmRepublicGAddress != 0,"The request is invalid");
            if (_pendigRepublicGAddress == RGAddress) {
                delete _delayConfirmRepublicGAddress;
                delete _pendigRepublicGAddress;
                _transferRepublicGAddress(RGAddress);

            } else revert TheAddressIsNotValidForRAddress(RGAddress);

        } else revert RemainingTimeUntilTheConfirmationDeadline(_delayConfirmRepublicGAddress - uint48(block.timestamp));
    }

    function cancelPendingRepublicGAddress(address PRGAdress) public onlyRepublic {
        if (_pendigRepublicGAddress == PRGAdress) {
                delete _delayConfirmRepublicGAddress;
                delete _pendigRepublicGAddress;
                emit  TheNextRepublicGAddressWasCancelled(PRGAdress);

        } else revert TheAddressIsNotValidForRAddress(PRGAdress);
    }

    function getRepublicAddress() public view returns (address R) {
            return Republic;
        }

    function getRepublicGAddress() public view returns (address RG) {
            return _RepublicG.roleAdd;
        }

        function getAuthorityAddress() public view returns (address) {
            return  address(this);
        }

    function setPendigPresident(address newPresident) public onlyRepublic {
        _pendigPresident = newPresident;
        _setPresidentBaned(true);
        _setPrimeMinisterBaned(true);

        emit TheNextPresidentWasElected(newPresident);
    }

    function transferPresident() public {
        if (_pendigPresident == msg.sender) {
            delete _pendigPresident;
            _president.roleAdd = msg.sender;
            _president.nonce++;
            _setPresidentBaned(false);

            emit TheNewPresidentWasConfirmed(_president.roleAdd, _president.nonce);

        } else revert AccessOnlyForThePendig();
    }

    function getPresidentAdd() public view returns (address) {
        return _president.roleAdd;
    }

    function getPresidentBan() public view returns (bool) {
        return _president.baned;
    }

    function setPendingPrimeMinister(address newPM) public onlyPresident {
        _pendingPrimeMinister = newPM;

        emit TheNextPrimeMinisterWasElected(newPM);
    }

    function transferPrimeMinister() public {
        if (_pendingPrimeMinister == msg.sender) {
            delete _pendingPrimeMinister;
            if (_governance.roleAdd != address(0)) {
            Igovernance_set(_governance.roleAdd).setCaller(true, _primeMinister.roleAdd, msg.sender, "All", 4, 1 days);
            }
            _primeMinister.roleAdd = msg.sender;
            _primeMinister.nonce++;
            if (_primeMinister.baned){
                _setPrimeMinisterBaned(false);
            }
            emit TheNewPrimeMinisterWasConfirmed(_primeMinister.roleAdd, _primeMinister.nonce);

        } else revert AccessOnlyForThePendig();
    }

    function getPrimeMinisterAdd() public view returns (address) {
        return _primeMinister.roleAdd;
    }

    function getPrimeMinisterBan() public view returns (bool) {
        return _primeMinister.baned;
    }


    function setPendingGovernanceContractAddress(address newGCAddress) public onlyRepublic {
        if (newGCAddress.code.length > 0) {
            _pendingGCAddress = newGCAddress;
            emit TheNextGCAddressWasElected(newGCAddress);

        } else revert TheAddressIsNotValidForGC(newGCAddress);

    }

    function transferGovernanceContractAddress(address pendingGCAdd) public onlyPresident {
        if (_pendingGCAddress == pendingGCAdd) {
            delete _pendingGCAddress;
            _governance.roleAdd = pendingGCAdd;
            _governance.nonce++;
            emit TheNewGCAddressWasConfirmed(_governance.roleAdd, _governance.nonce);

        } else revert TheAddressIsNotValidForGC(pendingGCAdd);
    }

    function getGovernance() public view returns (address) {
        return _governance.roleAdd;
    }

    function getgovernanceVersion() public view returns (uint32) {
        return _governance.nonce;
    }

    function setPresidentBaned(bool baned) public onlyRepublic {
        _setPresidentBaned(baned);
        _setPrimeMinisterBaned(baned);
    }

    function setPrimeMinisterBaned(bool baned) public onlyPresident {
        _setPrimeMinisterBaned(baned);
    }



    function _transferRepublicGAddress(address RGAddress) private {
        Igovernance_set(_governance.roleAdd).setCaller(true, _RepublicG.roleAdd, RGAddress, "All", 2, 1 days);
        _RepublicG.roleAdd = RGAddress;
        _RepublicG.nonce++;
        emit TheNewRepublicGAddressWasConfirmed(_RepublicG.roleAdd, _RepublicG.nonce);
    }

    function _setPresidentBaned(bool baned) private {
        _president.baned = baned;
    }

    function _setPrimeMinisterBaned(bool baned) private {
        _primeMinister.baned = baned;
        Igovernance_set(_governance.roleAdd).setBaned(baned, 4, "All");
        
    }


}