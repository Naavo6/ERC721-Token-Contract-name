// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;








contract storageTCN {

    error stateIsInvalid(uint256 proposalState);

    struct ACTIVITY

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