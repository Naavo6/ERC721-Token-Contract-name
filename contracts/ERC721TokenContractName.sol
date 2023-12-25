// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC721TCNReceiver} from "contracts/IERc721TokenContractNameReceiver.sol";




contract ERC721TokenContractName is Context, IERC721Errors, IERC721TCNReceiver {
    event Approval(address indexed owner, address indexed approved, uint16 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Transfer(address indexed from, address indexed to, uint16 indexed tokenId);


    using Address for address;
    using Strings for uint16;


    bytes20 private _name;


    bytes10 private _symbol;

    struct MintInfo {
        uint16 maxMinted;
        uint16 currentTokens;
    }



   MintInfo private mintInfo;


    address[1201] private _owners;

    bool[1201] private ban;

    mapping(address owner => uint16[1201]) private _balanceAndTokId;


    mapping(uint16 tokenId => address operator) private _tokenApprovals;


    mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;


    constructor(bytes20 name_, bytes10 symbol_) {
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

    function transferFrom(address from, address to, uint16 tokenId) public virtual {
         if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }

        address previousOwner = _requireOwned(tokenId);

        require(!ban[tokenId], "The transfer of this token is currently banned");

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

    function safeTransferFrom(address from, address to, uint16 tokenId, bytes memory data) public virtual {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }


    function _update(address to, uint16 tokenId, address from) private returns (address) {
       if (from != address(0)) {
        uint16 preBalanceFrom = _balanceAndTokId[from][0];
        for (uint16 i = 0; i <= preBalanceFrom; ++i) {
            if (_balanceAndTokId[from][i] == tokenId) {
                _balanceAndTokId[from][i] = _balanceAndTokId[from][preBalanceFrom];
                _balanceAndTokId[from][preBalanceFrom] = 0;
                break;
           }
        }
       }

    }


    function _aprove(address to, uint16 tokenId, address owner) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    


    function _requireOwned(uint16 tokenId) private view returns (address) {
        require(0 < tokenId && tokenId <= mintInfo.currentTokens, "The ID entered is invalid. It must be in this interval 0 < id <= current tokens"); 
        return _owners[tokenId];
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


    
}