// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import {Authority} from "contracts/authority.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC721TCNReceiver} from "contracts/IERc721TokenContractNameReceiver.sol";




contract ERC721TokenContractName is Authority, Context, IERC721Errors, IERC721TCNReceiver {
    event Approval(address indexed owner, address indexed approved, uint16 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Transfer(address indexed from, address indexed to, uint16 indexed tokenId);
    event updatemintInfo(uint16 indexed newmaxMint, uint256 indexed newregistrationStartTime, address newexecutor, address newbankAddress, uint256 newmintPrice);
    event updateActivityTimeTransfer(uint16 indexed tokenId, uint256 indexed time);

    // error ERC721NonexistentToken(uint16 tokenId);
    error ERC721NoNewRegistrants(uint16 nRegistrants);
    error Erc721InvalidTotalNewTokenId(uint16 total);
    error Erc721InvalidTokenInNewTokenId(uint16 token);
    error ERC721AccessIsNotApproved(address sender);
    error ERC721CantMoreThan1200(uint16 newMaxMint);
    error ERC721ParamArentAcceptable(uint16 newmaxMint,uint256 newregistrationStartTime);
    error ERC721InvalidGovernanceAddress(address governance);


    using Address for address;
    using Strings for uint16;


    bytes20 private _name;


    bytes10 private _symbol;

    struct MintInfo {
        uint16 maxMint;
        uint16 currentTokens;
        uint16 nRegistrants;
        address executor;
        address bankAddress;
        uint256 registrationStartTime;
        uint256 mintPrice;
        uint48[1201] salts;
        address[1201] registrants;
    }



    MintInfo private mintInfo;


    address[1201] private _owners;

    bool[1201] private _ban;

    mapping(address owner => uint16[1201]) private _balanceAndTokId;


    mapping(uint16 tokenId => address operator) private _tokenApprovals;


    mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;




    constructor(bytes20 name_, bytes10 symbol_, address storageContract_) {
        _name = name_;
        _symbol = symbol_;
    }


    function name() public view returns (bytes20) {
        return _name;
    }


    function symbol() public view returns (bytes10) {
        return _symbol;
    }


    function balanceOf(address owner) public view returns (uint16) {
        require(owner != address(0),"The input address cannot be zero");
        return _balanceAndTokId[owner][0];
    }


    function ownerOf(uint16 tokenId) public view returns (address) {
        return _requireOwned(tokenId);
    }


    function tokenURI(uint16 tokenId) public view returns (string memory) {
        _requireOwned(tokenId);
        string memory base = _baseURI();
        return bytes(base).length > 0 ? string.concat(base, tokenId.toString()) : "";
    }


    function approve(address to, uint16 tokenId) public {
        address owner = _requireOwned(tokenId);

        require(owner != to, "The address of the owner and the operator must be different");

       if (owner != _msgSender() && !isApprovedForAll(owner, _msgSender())){
        revert ERC721InvalidApprover(_msgSender());
       }

        _aprove(to, tokenId, owner);
    }

    function getApproved(uint16 tokenId) public view virtual returns (address) {
        _requireOwned(tokenId);

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(_msgSender() != operator, "The address of the owner and the operator must be different");

        if (operator == address(0)) {
            revert ERC721InvalidOperator(operator);
        }
        
        _operatorApprovals[_msgSender()][operator] = approved;
         emit ApprovalForAll(_msgSender(), operator, approved);
    }


    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint16 tokenId) public {
         if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }

        address previousOwner = _requireOwned(tokenId);

        require(!_ban[tokenId], "The transfer of this token is currently banned");

        if (!(_msgSender() == previousOwner || isApprovedForAll(previousOwner, _msgSender()) || getApproved(tokenId) == _msgSender())) {
            revert ERC721InsufficientApproval(_msgSender(), tokenId);
        }

        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }

        _aprove(address(0), tokenId, previousOwner);
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        _update(to, tokenId, previousOwner);
    }

    function safeTransferFrom(address from, address to, uint16 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint16 tokenId, bytes memory data) public {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    function setBallotForupdateMintInfo(
        uint256 value,
        address ballotAddress) public AccessCheck(msg.sender) returns (uint256 proposalId) {

            (,bytes memory data) = getGovernance().call(
                abi.encodeWithSignature(
                "propose(uint256,address,address,address)",
                value, address(this), msg.sender, ballotAddress
                )
                );
                proposalId = abi.decode(data, (uint256));
                return proposalId;
        }


    function updateMintInfo(
    uint16 newmaxMint,
    uint256 newregistrationStartTime,
    address newexecutor,
    address newbankAddress,
    uint256 newmintPrice,
    uint16[1201] memory newTokenId,
    bytes32 descriptionHash,
    address governance) public payable AccessCheck(msg.sender) {

        require(msg.sender == newexecutor, "Discrepancy in newexecutor address");
        if (0 < newmaxMint && newmaxMint <= 1000) {
                if (newmaxMint > mintInfo.nRegistrants && newregistrationStartTime >= block.timestamp) {
                    revert ERC721ParamArentAcceptable(newmaxMint, newregistrationStartTime);
                } else if ((newmaxMint - mintInfo.currentTokens) != newTokenId[0]) {
                    revert Erc721InvalidTotalNewTokenId(newTokenId[0]);
                }
        } else if (newmaxMint <= 1200) {
            if (governance != getGovernance()) {
                    revert ERC721InvalidGovernanceAddress(governance);
                }
            bytes memory callData = abi.encodeWithSignature("updateMintInfo(uint16,uint256,address,address,uint256,uint16[],bytes32,address)", newmaxMint, newregistrationStartTime, newexecutor, newbankAddress, newmintPrice, newTokenId, descriptionHash, governance);
            (bool suc,) = governance.call(abi.encodeWithSignature("execute(address,uint256,bytes,bytes32)", address(this), msg.value, callData, descriptionHash));
            require(suc,"execute permission function failed");
        } else revert ERC721CantMoreThan1200(newmaxMint);

        mintInfo.maxMint = newmaxMint;
        mintInfo.registrationStartTime = newregistrationStartTime;
        mintInfo.executor = newexecutor;
        mintInfo.bankAddress = newbankAddress;
        mintInfo.mintPrice = newmintPrice;
        _balanceAndTokId[address(0)] = newTokenId;
        emit updatemintInfo(newmaxMint, newregistrationStartTime, newexecutor, newbankAddress, newmintPrice);
    }

    function setRegister(uint48 salt_) public payable returns (bytes memory) { // accsesemit barash benevis baraye tasir gozari dar dastresi
        require(mintInfo.nRegistrants <= mintInfo.maxMint && mintInfo.registrationStartTime <= block.timestamp, "It is not possible to register now");
        require(_msgSender() != address(0) && _msgSender().code.length == 0,"The address of the registrant must not be 0 or the address of a contract");
        require(msg.value >= mintInfo.mintPrice, "The amount should not be less than the mint price");

        (bool paid, bytes memory data) = mintInfo.bankAddress.call{value : msg.value}("");
        require(paid, "The amount was not sent");

        ++mintInfo.nRegistrants;
        mintInfo.salts[mintInfo.nRegistrants] = salt_;
        mintInfo.salts[0] += salt_;
        mintInfo.registrants[mintInfo.nRegistrants] =_msgSender();
        
        return data;
    }

    function mint() public AccessCheck(msg.sender) {

        if (mintInfo.nRegistrants > mintInfo.currentTokens) {
            uint48[1201] memory salts_ = mintInfo.salts;
            address[1201] memory registrants_ = mintInfo.registrants;
            uint16 remainingReg = mintInfo.nRegistrants - mintInfo.currentTokens;
            uint16 remainingTok = (mintInfo.maxMint - mintInfo.currentTokens);
            uint16 i = ++mintInfo.currentTokens;
            uint16 nRegistrants = mintInfo.nRegistrants;
            uint256 mintTimeSalt = block.timestamp;

            for (i; i <= nRegistrants; i++) {
                uint16 index1 = uint16(salts_[0] + mintTimeSalt + salts_[i]) % i;
                uint16 index2 = uint16(salts_[index1] + salts_[0]) % nRegistrants;
                uint16 indexOwner =(uint16(salts_[index1] + salts_[index2]) % remainingReg) + i;
                address owner = registrants_[indexOwner];
                registrants_[indexOwner] = registrants_[i];
                registrants_[i] = owner;

                uint16 indextoken = (uint16(salts_[index1] + salts_[indexOwner]) % remainingTok);
                if (indextoken == 0) {
                    indextoken = remainingTok;
                }
                _update(owner, indextoken, address(0));
                --remainingReg;
                --remainingTok;
            }

            mintInfo.currentTokens = mintInfo.nRegistrants;
        } else {
            revert ERC721NoNewRegistrants(mintInfo.nRegistrants);
        }
    }

    // in set bayad tvasote ye contrct set anjam shavad. 
    // yani jaye in tabe faghat bayad contract set be _ban dastresi dashte bashe.
    // pas in cod badan avaz khahad shod va alan ebtedayi hastesh.
    function setBan(uint16 tokenId, bool set_) public { 
        address owner = _requireOwned(tokenId);

        if (_msgSender() == owner) {
            _ban[tokenId] = set_;
        } else if (governoraccess(_msgSender())) {
            _ban[tokenId] = set_;
        } else {
            revert ERC721AccessIsNotApproved(_msgSender());
        }
    }


    function _update(address to, uint16 tokenId, address from) private {
        uint16 preBalanceFrom = _balanceAndTokId[from][0];
       if (from != address(0)) {
        for (uint16 i = 1; i <= preBalanceFrom; i++) {
            if (_balanceAndTokId[from][i] == tokenId) {
                _balanceAndTokId[from][i] = _balanceAndTokId[from][preBalanceFrom];
                break;
           }
        }

       } else {
        uint16 index = tokenId;
        tokenId = _balanceAndTokId[from][index];
        if (_owners[tokenId] != address(0)) {
            revert Erc721InvalidTokenInNewTokenId(index);
        }
        _balanceAndTokId[from][index] = _balanceAndTokId[from][preBalanceFrom];
       }

        _balanceAndTokId[from][preBalanceFrom] = 0;
        _balanceAndTokId[from][0] -= 1;

        uint16 newBalanceTo = (_balanceAndTokId[to][0] + 1);
        _balanceAndTokId[to][newBalanceTo] = tokenId;
        _balanceAndTokId[to][0] = newBalanceTo;

        _owners[tokenId] = to;

        (, bytes memory data) = getGovernance().call(abi.encodeWithSignature("getCMWithCallerAddress(address, bytes32)", msg.sender, "storageContract"));
        address storageContract_ = abi.decode(data, (address));
        (bool suc,) = storageContract_.call(abi.encodeWithSignature("setActivityTimeToken(uint48,uint16,bytes32)", block.timestamp, tokenId, "lastTransfer"));

        if (suc) {
            emit updateActivityTimeTransfer(tokenId, block.timestamp);
        }
        emit Transfer(from, to, tokenId);
    }


    function _aprove(address to, uint16 tokenId, address owner) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    


    function _requireOwned(uint16 tokenId) private view returns (address) {
        require(0 < tokenId && tokenId <= mintInfo.maxMint, "The ID entered is invalid. It must be in this interval 0 < id <= maximum mintable tokens");
        address owner = _owners[tokenId];
        if (owner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return owner;
    }


    function _baseURI() private pure returns (string memory) {
        return "";
    }

    function _checkOnERC721Received(address from, address to, uint16 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721TCNReceiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721TCNReceiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    function onERC721Received(
        address operator,
        address from,
        uint16 tokenId,
        bytes calldata data
    ) external returns (bytes4){}





    function governoraccess (address) public returns (bool) {

    }// bardashte mishe badan


    
}