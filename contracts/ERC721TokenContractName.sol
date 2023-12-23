// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";




contract ERC721TokenContractName is Context, IERC721Errors {
    event Approval(address indexed owner, address indexed approved, uint16 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);


    using Address for address;
    using Strings for uint16;


    bytes20 private _name;


    bytes10 private _symbol;

    struct TokInfo {
        uint16 maxMinted;
        uint16 currentTokens;
    }

    TokInfo private tokInfo;


    address[1201] private _owners;


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
        _aprove(to, tokenId, _msgSender());
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




    function _aprove(address to, uint16 tokenId, address auth) internal {
        address owner = _requireOwned(tokenId);
        require(owner != to, "The address of the owner and the operator must be different");
       if (owner != auth && !isApprovedForAll(owner, auth)){
        revert ERC721InvalidApprover(auth);
       }

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    


    function _requireOwned(uint16 tokenId) internal view returns (address) {
        require(0 < tokenId && tokenId <= tokInfo.currentTokens, "The ID entered is invalid. It must be in this interval 0 < id <= current tokens"); 
        return _owners[tokenId];
    }


    function _baseURI() internal pure returns (string memory) {
        return "";
    }


    
}