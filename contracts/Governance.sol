// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {storageTCN} from "contracts/storageTokenContractName.sol";
import {BallotTCN} from "contracts/3_Ballot.sol";
import {Authority} from "contracts/authority.sol";






contract TokenNamGovernor is EIP712, Authority {

    event ChangeStateToExecutedAndContinue(address indexed  storageContract, uint256 indexed proposalId);
    event changeVoteDuration(uint32 indexed  time);
    event changeEtaSeconds(uint32 indexed  time);
    event changeVoteDelay(uint32 indexed  time);
    event ValidBallotcontract(address indexed  ballotAddress);
    event SetProposal(uint indexed proposalId);
    event ProposalCanceled(uint256 indexed proposalId);

    error GovernorNonexistentProposal(uint256 proposalId);
    error AddressNotReturnVoteCount(address ballot);
    error StorageContractS_invalidAccess(address Applicant);
    error StorageContractS_invalidState(address storageContract, uint256 proposalId);
    error InvalidQuorum(uint16 quorum);
    error ThisProposalExists(uint256 proposalId_);
    error GovernanceContractNotMatch(address governances_);
    error InavlidProposalParams(address target_, address proposer_, uint256 value_);
    error InvalidVotingTImeParams(uint32 voteDuration_, uint48 voteStart_, uint48 etaSeconds_);
    error StateProposalIsSpecified(uint256 proposalId);


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

    // yek zaman bandi payei dar kol zistboom vojood darad ke mitavan in zamanhaye paye ra ba in tabe taghir dad.
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

       if (proposal_.Defeated) {
            return ProposalState.Defeated;
        }

       if (proposal_.Succeeded) {
            return ProposalState.Succeeded;
        }


       uint256 snapshot = proposal_.voteStart;

       if (snapshot == 0) {
        revert GovernorNonexistentProposal(proposalId);
       }

       uint256 currentTimePoint = block.timestamp;

       if (currentTimePoint <= snapshot) {
        return ProposalState.Pending;
       }

       address ballot = proposal_.ballotContract;
       BallotTCN ballotContract = BallotTCN(ballot);
       uint256 deadline = ballotContract.getDeadline();

       if (currentTimePoint <= deadline) {
        return ProposalState.Active;
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
        address ballotAddress) public returns (uint256 proposalId) {
            require(target == msg.sender,"invalid access");
            storageTCN contractStorage_ = storageTCN(_storageConnectors[target]);
            BallotTCN ballotContract = BallotTCN(ballotAddress);
            proposalId = ballotContract.getBallotProposalId();
            storageTCN.ProposalCore memory proposal_ = contractStorage_.proposals(proposalId);

            if (proposal_.voteStart != 0) {
                revert ThisProposalExists(proposalId);
            }

            (,,,address governances_) = ballotContract.getBallotCallDataParams();

            if (governances_ != address(this)) {
                revert GovernanceContractNotMatch(governances_);
            }

            (address target_, address proposer_, uint256 value_) = ballotContract.getBallotProposalParams();

            if ((target != target_) || (proposer != proposer_) || (value != value_)) {
                revert InavlidProposalParams(target_, proposer_, value_);
            }

            (uint16 quorum_, uint32 voteDuration_, uint48 voteStart_, uint48 etaSeconds_) = ballotContract.getBalootVotingParams();

            if (!isQuorumValid(quorum_)) {
                revert InvalidQuorum(quorum_);

            } else if ((voteDuration_ < _voteDuration) || (voteStart_ < (block.timestamp + _voteDelay)) || (etaSeconds_ < _etaSeconds)) {
                revert InvalidVotingTImeParams(voteDuration_, voteStart_, etaSeconds_);
            }
            address ballotContract_ = ballotAddress;
            emit ValidBallotcontract(ballotContract_);

            contractStorage_.setProposalCore(proposalId, quorum_, voteDuration_, voteStart_, etaSeconds_, proposer_,ballotContract_);
            emit SetProposal(proposalId);

            return proposalId;

    }



    function execute(address target, uint256 value, bytes memory callData, bytes32 descriptionHash) public {
        if (target == msg.sender){ 
            uint256 proposalId = hashProposal(target, value, callData, descriptionHash);
            ProposalState proState = state(proposalId);

            if (proState == ProposalState.Succeeded) {
                storageTCN contractStorage_ = storageTCN(_storageConnectors[msg.sender]);
                contractStorage_.setProposalState(5, proposalId);
                emit ChangeStateToExecutedAndContinue(_storageConnectors[msg.sender], proposalId);

            } else revert StorageContractS_invalidState(_storageConnectors[msg.sender], proposalId);

        } else revert StorageContractS_invalidAccess(msg.sender);
    }


    function cancel(address target, uint256 value, bytes memory callData, bytes32 descriptionHash) public {
        uint256 proposalId = hashProposal(target, value, callData, descriptionHash);
        address storageAddress = _storageConnectors[msg.sender];
        if (storageAddress != address(0)) {
            ProposalState proState = state(proposalId);
            if (proState == ProposalState.Executed || proState == ProposalState.Canceled) {
                revert StateProposalIsSpecified(proposalId);
            } else {
                storageTCN contractStorage_ = storageTCN(storageAddress);
                storageTCN.ProposalCore memory proposal_ = contractStorage_.proposals(proposalId);
                proposal_.canceled = true;
                emit ProposalCanceled(proposalId);
            }
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
        } else if (((quorumProposal/activeToken) * 100) > 70) {
            return true;
        } else return false;
    }


    function _voteResult(storageTCN.ProposalCore memory proposal_) private returns (ProposalState) {
        address ballot = proposal_.ballotContract;
        BallotTCN ballotContract = BallotTCN(ballot);
            bool result = ballotContract.votingResult();
            if (result) {
                return ProposalState.Succeeded;
            } else return ProposalState.Defeated;
    }

    function governoraccess (address) public returns (bool) {

    }// bardashte mishe badan

    function setBanedAllActivities(bool baned) public returns (bool done) {
        require(Authority.getAuthorityAddress() == msg.sender, "Access is not valid");
        // _banedAllActivities = baned;
        done = true;
    }


}