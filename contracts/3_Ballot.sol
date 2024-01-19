// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract Ballot {

    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    struct Proposal {
        // If you can limit the length to a certain number of bytes, 
        // always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    /** 
     * @dev Create a new ballot to choose one of 'proposalNames'.
     * @param proposalNames names of proposals
     */
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            // 'Proposal({...})' creates a temporary
            // Proposal object and 'proposals.push(...)'
            // appends it to the end of 'proposals'.
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }



    function setBallotForupdateMintInfo(
        uint16 newmaxMint,
        uint256 newregistrationStartTime,
        address newexecutor,
        address newbankAddress,
        uint256 newmintPrice,
        uint16[1201] memory newTokenId,
        bytes32 descriptionHash,
        address governance,
        uint256 value,
        address proposer,
        address ballotAddress,
        uint16 quorum,
        uint32 voteDuration,
        uint48 voteStart) public {
            require(_msgSender() == mintInfo.executor, "You do not have access to this function");
           if (1000 < newmaxMint && newmaxMint <= 1200) { 
                if (newmaxMint > mintInfo.nRegistrants && newregistrationStartTime >= block.timestamp) {
                    revert ERC721ParamArentAcceptable(newmaxMint, newregistrationStartTime);
                } else if ((newmaxMint - mintInfo.currentTokens) != newTokenId[0]) {
                    revert Erc721InvalidTotalNewTokenId(newTokenId[0]);
                } else if (governance != _governance) {
                    revert ERC721InvalidGovernanceAddress(governance);
                }
            bytes memory callData = abi.encodeWithSignature("updateMintInfo(uint16,uint256,address,address,uint256,uint16[],bytes32,address)", newmaxMint, newregistrationStartTime, newexecutor, newbankAddress, newmintPrice, newTokenId, descriptionHash, governance);
            (bool suc,) = governance.call(abi.encodeWithSignature("propose(address,uint256,bytes,bytes32)", address(this), value, callData, descriptionHash, proposer, ballotAddress));
            } else revert ERC721CantMoreThan1200(newmaxMint);
        }

    /** 
     * @dev Give 'voter' the right to vote on this ballot. May only be called by 'chairperson'.
     * @param voter address of voter
     */
    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    /**
     * @dev Delegate your vote to the voter 'to'.
     * @param to address to which vote is delegated
     */
    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    /**
     * @dev Give your vote (including votes delegated to you) to proposal 'proposals[proposal].name'.
     * @param proposal index of proposal in the proposals array
     */
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }

    /** 
     * @dev Computes the winning proposal taking all previous votes into account.
     * @return winningProposal_ index of winning proposal in the proposals array
     */
    function voteCountProposal() public view
            returns (uint256 winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    /** 
     * @dev Calls winningProposal() function to get the index of the winner contained in the proposals array and then
     * @return winnerName_ the name of the winner
     */
    function winnerName() public view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[voteCountProposal()].name;
    }
}