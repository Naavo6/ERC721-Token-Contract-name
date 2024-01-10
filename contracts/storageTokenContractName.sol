// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;








contract storageTCN {

    struct ProposalCore {
        address proposer;
        uint16 quorum;
        uint16 voteCounter;
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

}