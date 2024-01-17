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



    function setActivityTimeToken(uint48 time, uint16 tokenId, bytes32 varName) public {
        bytes32 varName_ = keccak256(abi.encodePacked(varName));
       if (keccak256(abi.encodePacked("forAny")) == varName_) {
        activityTimeToken.forAny[tokenId] = time;
        activityTimeToken.forAny[0] += 1;
       } else if (keccak256(abi.encodePacked("lastPartiAuction")) == varName_) {
        activityTimeToken.forAny[tokenId] = time;
        activityTimeToken.forAny[0] += 1;
        activityTimeToken.lastPartiAuction[tokenId] = time;
        activityTimeToken.lastPartiAuction[0] += 1;
       } else if (keccak256(abi.encodePacked("lastSucAuction")) == varName_) {
        activityTimeToken.forAny[tokenId] = time;
        activityTimeToken.forAny[0] += 1;
        activityTimeToken.lastSucAuction[tokenId] = time;
        activityTimeToken.lastSucAuction[0] += 1;
       } else if (keccak256(abi.encodePacked("lastTransfer")) == varName_) {
        activityTimeToken.forAny[tokenId] = time;
        activityTimeToken.forAny[0] += 1;
        activityTimeToken.lastTransfer[tokenId] = time;
        activityTimeToken.lastTransfer[0] += 1;
       }
    }

    function isQuorumValid(uint16 quorumProposal) public view returns (bool) {
        uint256 currentTime = block.timestamp;
        uint48 sampleTime = uint48(currentTime - 60 days);
        uint16 activeToken;
        uint16 i;
        for (i = 1; i <= 1200; i++) {
            if (activityTimeToken.forAny[i] == 0) {
                break
            } else if (sampleTime < activityTimeToken.forAny[i]) {
                ++activeToken;
            }
        }
        if (quorumProposal > (i/2)) {
            return true;
        }else if (((quorumProposal/activeToken) * 100) > 70) {
            return true;
        }else return false;
    }

    function proposals(uint256 proposalId) public view returns (ProposalCore memory) {
        return _proposals[proposalId];
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

}