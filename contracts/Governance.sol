// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {storageTCN} from "contracts/storageTokenContractName.sol";






contract TokenNamGovernor is EIP712 {

    event ChangeStateToExecutedAndContinue(address storageContract, uint256 indexed proposalId);

    error GovernorNonexistentProposal(uint256 proposalId);
    error AddressNotReturnVoteCount(address ballot);
    error StorageContractS_invalidAccess(address Applicant);
    error StorageContractS_invalidState(address storageContract, uint256 proposalId);

    struct ProposalCore { // mitoone nabashe
        address proposer;
        uint48 voteStart;
        uint32 voteDuration;
        bool executed;
        bool canceled;
        uint48 etaSeconds;
    }

     enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Executed
    }

    

    mapping(address applicantAdd => address storageAdd) private _connectors;

    string private _name;


    

    constructor (string memory name_) EIP712 (name_, version()) {
        _name = name_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function version() public pure returns (string memory) {
        return "1";
    }

    function Clock() public view returns (uint256) {
        return block.timestamp;
    }

    function CLOCK_MODE() public view returns (string memory) {
        return "Time stamp";
    }

    function setConnectors(address applicantAdd_, address storageAdd_) public { // modifier lazeme ba contract access control
        _connectors[applicantAdd_] = storageAdd_;
    }

    function hashProposal(address target, uint256 value, bytes memory callData, bytes32 descriptionHash) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(target, value, callData, descriptionHash)));
    }

    function state(uint256 proposalId) public returns (ProposalState) {
       storageTCN contractStorage = storageTCN(_connectors[msg.sender]);
       storageTCN.ProposalCore memory proposal = contractStorage.proposals(proposalId);

       if (proposal.executed) {
        return ProposalState.Executed;
       }

       if (proposal.canceled) {
        return ProposalState.Canceled;
       }

       uint256 snapshot = proposal.voteStart;

       if (snapshot == 0) {
        revert GovernorNonexistentProposal(proposalId);
       }

       uint256 currentTimePoint = block.timestamp;

       if (currentTimePoint <= snapshot) {
        return ProposalState.Pending;
       }

       uint256 deadline = snapshot + proposal.voteDuration;

       if (currentTimePoint <= deadline) {
        return ProposalState.Active;
       } else if (proposal.Succeeded) {
            return ProposalState.Succeeded;
        } else if (proposal.Defeated) {
            return ProposalState.Defeated;
        } else {
            ProposalState result = _voteResult(proposal);
            uint256 state_ = uint256(result);
            contractStorage.setProposalState(state_, proposalId);
            return result;
        }
    }

    function proposal() public {
        (bool suc,) = IQuorumvalid
    }

    function execute(address target, uint256 value, bytes memory callData, bytes32 descriptionHash) public {
        if (target == msg.sender){ 
            uint256 proposalId = hashProposal(target, value, callData, descriptionHash);
            ProposalState proState = state(proposalId);

            if(proState == ProposalState.Succeeded) {
                storageTCN contractStorage_ = storageTCN(_connectors[msg.sender]);
                contractStorage_.setProposalState(5, proposalId);

                emit ChangeStateToExecutedAndContinue(_connectors[msg.sender], proposalId);

            } else revert StorageContractS_invalidState(_connectors[msg.sender], proposalId);

        } else revert StorageContractS_invalidAccess(msg.sender);
    }


    function _voteResult(storageTCN.ProposalCore memory proposal) private returns (ProposalState) {
        address ballot = proposal.ballotContract;
        (bool result, bytes memory data) = ballot.call(abi.encodeWithSignature("voteCountProposal()"));
        if (result) {
            uint256 voteCount = abi.decode(data, (uint256));
            if (voteCount > proposal.quorum) {
                return ProposalState.Succeeded;
            } else return ProposalState.Defeated;
        } else revert AddressNotReturnVoteCount(ballot);

    }


}