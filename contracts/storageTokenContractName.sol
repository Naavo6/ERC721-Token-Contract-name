// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;








contract storageTCN {

    error stateIsInvalid(uint256 proposalState);

    struct ACTIVITYTIME {
        uint48[1201] forAny;
        uint48[1201] lastTransfer;
        uint48[1201] lastPartiAuction;
        uint48[1201] lastSucAuction;
    }

    ACTIVITYTIME private activityTimeToken;

    struct ProposalCore {
        address proposer;
        address ballotContract;
        uint16 quorum;
        uint32 voteDuration;
        uint48 voteStart;
        uint48 etaSeconds;
        bool executed;
        bool canceled;
        bool Succeeded;
        bool Defeated;
    }


    mapping(uint256 proposalId => ProposalCore) private _proposals;
    mapping(uint256 proposalId => mapping(address voter => bytes32 voteHash)) private _votersVote;


    function setProposalCore(
        uint256 proposalId,
        address proposer_,
        address ballotContract_,
        uint16 quorum_,
        uint32 voteDuration_,
        uint48 voteStart_,
        uint48 etaSeconds_) public {
            _proposals[proposalId].proposer = proposer_;
            _proposals[proposalId].ballotContract = ballotContract_;
            _proposals[proposalId].quorum = quorum_;
            _proposals[proposalId].voteDuration = voteDuration_;
            _proposals[proposalId].voteStart = voteStart_;
            _proposals[proposalId].etaSeconds = etaSeconds_;
        }


    function setProposalState(uint256 proposalState, uint256 proposalId) public {
        if (2 >= proposalState || proposalState >= 5) {
            revert stateIsInvalid(proposalState);
        }
        if (proposalState == 4) {
            _proposals[proposalId].Succeeded = true;

        } else if (proposalState == 3) {
            _proposals[proposalId].Defeated = true;

        } else if (proposalState == 5) {
            _proposals[proposalId].executed = true;

        } else {
            _proposals[proposalId].canceled = true;
        }
    }



    function setActivityTimeToken(uint256 time, uint16 tokenId, bytes32 varName) public {
        bytes32 varName_ = keccak256(abi.encodePacked(varName));
        uint48 time_ = uint48(time);
       if (keccak256(abi.encodePacked("forAny")) == varName_) {
            activityTimeToken.forAny[tokenId] = time_;
            activityTimeToken.forAny[0] += 1;
       } else if (keccak256(abi.encodePacked("lastPartiAuction")) == varName_) {
            activityTimeToken.forAny[tokenId] = time_;
            activityTimeToken.forAny[0] += 1;
            activityTimeToken.lastPartiAuction[tokenId] = time_;
            activityTimeToken.lastPartiAuction[0] += 1;
       } else if (keccak256(abi.encodePacked("lastSucAuction")) == varName_) {
            activityTimeToken.forAny[tokenId] = time_;
            activityTimeToken.forAny[0] += 1;
            activityTimeToken.lastSucAuction[tokenId] = time_;
            activityTimeToken.lastSucAuction[0] += 1;
       } else if (keccak256(abi.encodePacked("lastTransfer")) == varName_) {
            activityTimeToken.forAny[tokenId] = time_;
            activityTimeToken.forAny[0] += 1;
            activityTimeToken.lastTransfer[tokenId] = time_;
            activityTimeToken.lastTransfer[0] += 1;
       }
    }


    function proposals(uint256 proposalId) public view returns (ProposalCore memory) {
        return _proposals[proposalId];
    }


    function getActivityTimeToken(bytes32 varName) public view returns (uint48[1201] memory time_) {
         bytes32 varName_ = keccak256(abi.encodePacked(varName));

        if (keccak256(abi.encodePacked("forAny")) == varName_) {
            time_ = activityTimeToken.forAny;
            return time_;
       } else if (keccak256(abi.encodePacked("lastPartiAuction")) == varName_) {
           time_ = activityTimeToken.lastPartiAuction;
            return time_;
       } else if (keccak256(abi.encodePacked("lastSucAuction")) == varName_) {
           time_ = activityTimeToken.lastSucAuction;
            return time_;
       } else if (keccak256(abi.encodePacked("lastTransfer")) == varName_) {
           time_ = activityTimeToken.lastTransfer;
            return time_;
       }
    }


    

}