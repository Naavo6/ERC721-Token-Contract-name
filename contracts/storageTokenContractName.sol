// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;








contract storageTCN {

    struct ProposalCore {
        address proposer;
        uint48 voteStart;
        uint32 voteDuration;
        bool executed;
        bool canceled;
        uint48 etaSeconds;
    }

    mapping(uint256 proposalId => ProposalCore) private _proposals;



    function proposals(uint256 proposalId) public view returns (ProposalCore memory) {
        return _proposals[proposalId];
    }

}