// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {storageTCN} from "contracts/storageTokenContractName.sol";
import {BallotTCN} from "contracts/3_Ballot.sol";






contract TokenNamGovernor is EIP712 {

    event ChangeStateToExecutedAndContinue(address indexed  storageContract, uint256 indexed proposalId);
    event changeVoteDuration(uint32 indexed  time);
    event changeEtaSeconds(uint32 indexed  time);
    event changeVoteDelay(uint32 indexed  time);
    event setBallotVotingTimes(address indexed  ballotContract, uint32 voteDuration,uint48 indexed voteStart, uint48 _etaSeconds);

    error GovernorNonexistentProposal(uint256 proposalId);
    error AddressNotReturnVoteCount(address ballot);
    error StorageContractS_invalidAccess(address Applicant);
    error StorageContractS_invalidState(address storageContract, uint256 proposalId);
    error invalidProposalParam(bytes callData, bytes32 descriptionHash);
    error invalidQuorum(uint16 quorum);
    error invalidVoteStart(uint48 voteStart);
    error invalidvoteDuration(uint32 voteDuration);


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

    

    mapping(address applicantAdd => address storageAdd) private _storageConnectors;

    string private _name;

    uint32 private _voteDuration = 1 days;

    uint32 private _etaSeconds = 1 days;

    uint32 private _voteDelay = 7 days;


    

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

    function CLOCK_MODE() public pure returns (string memory) {
        return "Time stamp";
    }

    function setvoteTiming(uint32 time, bytes32 varName) public {
        bytes32 varName_ = keccak256(abi.encodePacked(varName));
        uint32 time_ = uint32(time);
        if (keccak256(abi.encodePacked("_voteDuration")) == varName_) {
           _voteDuration = time_;
            emit changeVoteDuration(time_);
       } else if (keccak256(abi.encodePacked("_etaSeconds")) == varName_) {
           _etaSeconds = time_;
            emit changeEtaSeconds(time_);
       } else if (keccak256(abi.encodePacked("_votedelay")) == varName_) {
           _voteDelay = time_;
           emit changeVoteDelay(time_);
       }
    }

    function setConnectors(address applicantAdd_, address storageAdd_) public { // modifier lazeme ba contract access control
        _storageConnectors[applicantAdd_] = storageAdd_;
    }

    function hashProposal(address target, uint256 value, bytes memory callData, bytes32 descriptionHash) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(target, value, callData, descriptionHash)));
    }

    function state(uint256 proposalId) public returns (ProposalState) {
       storageTCN contractStorage = storageTCN(_storageConnectors[msg.sender]);
       storageTCN.ProposalCore memory proposal_ = contractStorage.proposals(proposalId);

       if (proposal_.executed) {
        return ProposalState.Executed;
       }

       if (proposal_.canceled) {
        return ProposalState.Canceled;
       }

       uint256 snapshot = proposal_.voteStart;

       if (snapshot == 0) {
        revert GovernorNonexistentProposal(proposalId);
       }

       uint256 currentTimePoint = block.timestamp;

       if (currentTimePoint <= snapshot) {
        return ProposalState.Pending;
       }

       uint256 deadline = snapshot + proposal_.voteDuration;

       if (currentTimePoint <= deadline) {
        return ProposalState.Active;
       } else if (proposal_.Succeeded) {
            return ProposalState.Succeeded;
        } else if (proposal_.Defeated) {
            return ProposalState.Defeated;
        } else {
            ProposalState result = _voteResult(proposal_);
            uint256 state_ = uint256(result);
            contractStorage.setProposalState(state_, proposalId);
            return result;
        }
    }

    function proposal(
        uint256 value,
        address target,
        address proposer,
        address ballotAddress) public {
            BallotTCN ballotContract = BallotTCN(ballotAddress);
            (,,address governances) = ballotContract.getBallotCallDataParams();
        // (,bytes memory ballotCallData) = ballotAddress.call(abi.encodeWithSignature("getCallData()"));
        // (,bytes memory ballotDescriptionHash) = ballotAddress.call(abi.encodeWithSignature("getDescriptionHash()"));
        // bytes32 ballotDescriptionHash_ = abi.decode(ballotDescriptionHash, (bytes32));
        // if (!((keccak256(ballotCallData) == keccak256(callData)) && (ballotDescriptionHash_ == descriptionHash))) {
        //     revert invalidProposalParam(callData, descriptionHash);
        // }
        // if (!isQuorumValid(quorum)) {// governance ballot
        //     revert invalidQuorum(quorum);// chek shavad ghablansabt nashode bashad
        // }

        // if (voteStart < (block.timestamp + _voteDelay)) {
        //     revert invalidVoteStart(voteStart);
        // }

        // if (voteDuration < _voteDuration) {
        //     revert invalidvoteDuration(voteDuration);
        // }

        // (bool suc,) = ballotAddress.call(abi.encodeWithSignature("setVotingTimes(uint32,uint48,uint48)", voteDuration, voteStart, _etaSeconds));
        // if (suc) {
        //     emit setBallotVotingTimes(ballotAddress, voteDuration, voteStart, _etaSeconds);
        // }
        
        // uint256 proposalId = hashProposal(target, value, callData, descriptionHash);

        storageTCN contractStorage_ = storageTCN(_storageConnectors[msg.sender]);
        //contractStorage_.setProposalCore();

        //(bool suc,) = IQuorumvalid
    }

    function execute(address target, uint256 value, bytes memory callData, bytes32 descriptionHash) public {
        if (target == msg.sender){ 
            uint256 proposalId = hashProposal(target, value, callData, descriptionHash);
            ProposalState proState = state(proposalId);

            if(proState == ProposalState.Succeeded) {
                storageTCN contractStorage_ = storageTCN(_storageConnectors[msg.sender]);
                contractStorage_.setProposalState(5, proposalId);
                emit ChangeStateToExecutedAndContinue(_storageConnectors[msg.sender], proposalId);

            } else revert StorageContractS_invalidState(_storageConnectors[msg.sender], proposalId);

        } else revert StorageContractS_invalidAccess(msg.sender);
    }

    function isQuorumValid(uint16 quorumProposal) private view returns (bool) {
        storageTCN contractStorage_ = storageTCN(_storageConnectors[msg.sender]);
        uint48[1201] memory forAny = contractStorage_.getActivityTimeToken("forAny");
        uint256 currentTime = block.timestamp;
        uint48 sampleTime = uint48(currentTime - 60 days);
        uint16 activeToken;
        uint16 i;
        for (i = 1; i <= 1200; i++) {
            if (forAny[i] == 0) {
                break;
            } else if (sampleTime < forAny[i]) {
                ++activeToken;
            }
        }
        if (quorumProposal > (i/2)) {
            return true;
        }else if (((quorumProposal/activeToken) * 100) > 70) {
            return true;
        }else return false;
    }


    function _voteResult(storageTCN.ProposalCore memory proposal_) private returns (ProposalState) {
        address ballot = proposal_.ballotContract;
        (bool result, bytes memory data) = ballot.call(abi.encodeWithSignature("voteCountProposal()"));
        if (result) {
            uint256 voteCount = abi.decode(data, (uint256));
            if (voteCount > proposal_.quorum) {
                return ProposalState.Succeeded;
            } else return ProposalState.Defeated;
        } else revert AddressNotReturnVoteCount(ballot);

    }


}