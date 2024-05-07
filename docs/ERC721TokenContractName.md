# Solidity API

## ERC721TokenContractName

### Contract
ERC721TokenContractName : contracts/ERC721TokenContractName.sol

 --- 
### Functions:
### constructor

```solidity
constructor(bytes20 name_, bytes10 symbol_, address governance_, address storageContract_) public
```

### name

```solidity
function name() public view returns (bytes20)
```

### symbol

```solidity
function symbol() public view returns (bytes10)
```

### balanceOf

```solidity
function balanceOf(address owner) public view returns (uint16)
```

### ownerOf

```solidity
function ownerOf(uint16 tokenId) public view returns (address)
```

### tokenURI

```solidity
function tokenURI(uint16 tokenId) public view returns (string)
```

### approve

```solidity
function approve(address to, uint16 tokenId) public
```

### getApproved

```solidity
function getApproved(uint16 tokenId) public view virtual returns (address)
```

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) public
```

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) public view returns (bool)
```

### transferFrom

```solidity
function transferFrom(address from, address to, uint16 tokenId) public virtual
```

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint16 tokenId) public
```

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint16 tokenId, bytes data) public virtual
```

### setBallotForupdateMintInfo

```solidity
function setBallotForupdateMintInfo(uint256 value, address ballotAddress) public returns (uint256 proposalId)
```

### updateMintInfo

```solidity
function updateMintInfo(uint16 newmaxMint, uint256 newregistrationStartTime, address newexecutor, address newbankAddress, uint256 newmintPrice, uint16[1201] newTokenId, bytes32 descriptionHash, address governance) public payable
```

### setRegister

```solidity
function setRegister(uint48 salt_) public payable returns (bytes)
```

### mint

```solidity
function mint() public
```

### setBan

```solidity
function setBan(uint16 tokenId, bool set_) public
```

### setAccessAddress

```solidity
function setAccessAddress(address address_, bytes32 varName) public
```

### onERC721Received

```solidity
function onERC721Received(address operator, address from, uint16 tokenId, bytes data) external returns (bytes4)
```

_Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
by `operator` from `from`, this function is called.

It must return its Solidity selector to confirm the token transfer.
If any other value is returned or the interface is not implemented by the recipient, the transfer will be
reverted.

The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`._

### governoraccess

```solidity
function governoraccess(address) public returns (bool)
```

inherits IERC721TCNReceiver:
inherits IERC721Errors:

 --- 
### Events:
### Approval

```solidity
event Approval(address owner, address approved, uint16 tokenId)
```

### ApprovalForAll

```solidity
event ApprovalForAll(address owner, address operator, bool approved)
```

### Transfer

```solidity
event Transfer(address from, address to, uint16 tokenId)
```

### updatemintInfo

```solidity
event updatemintInfo(uint16 newmaxMint, uint256 newregistrationStartTime, address newexecutor, address newbankAddress, uint256 newmintPrice)
```

### updateActivityTimeTransfer

```solidity
event updateActivityTimeTransfer(uint16 tokenId, uint256 time)
```

inherits IERC721TCNReceiver:
inherits IERC721Errors:

## IERC721TCNReceiver

_Interface for any contract that wants to support safeTransfers
from ERC-721 asset contracts._

### Contract
IERC721TCNReceiver : contracts/IERc721TokenContractNameReceiver.sol

Interface for any contract that wants to support safeTransfers
from ERC-721 asset contracts.

 --- 
### Functions:
### onERC721Received

```solidity
function onERC721Received(address operator, address from, uint16 tokenId, bytes data) external returns (bytes4)
```

_Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
by `operator` from `from`, this function is called.

It must return its Solidity selector to confirm the token transfer.
If any other value is returned or the interface is not implemented by the recipient, the transfer will be
reverted.

The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`._

