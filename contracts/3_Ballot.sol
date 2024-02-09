// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

//import {ERC721TokenContractName} from "contracts/ERC721TokenContractName.sol";


interface IgetBalance {

    function balanceOf(address owner) external view returns (uint16);
}

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract BallotTCN {

    event etaSecondsIsActivated(address indexed _this, uint48 _etaSeconds);
    event TheVoteWasRegistered(address indexed sender, address indexed _this);

    error invalidProposer(address proposer);
    error VotingHasNotStarted(uint48 _voteStart);
    error VotingIsOver(uint256 _deadLine);

    struct Voter {
        uint16 weight; // weight is accumulated by delegation
        uint16 delegateWeight;
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint256 votedTime;   // index of the voted proposal
    }

    struct BALLOtPARAM {
        // If you can limit the length to a certain number of bytes, 
        // always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name;   // short name (up to 32 bytes)
        uint16 voteCount; // number of accumulated votes
        uint16 observed;
    }

    BALLOtPARAM public _ballotParam;

    struct VOTINGPARAM {
        uint16 quorum;
        uint32 voteDuration;
        uint48 voteStart;
        uint48 etaSeconds;
    }

    VOTINGPARAM private _votingParams;
    uint256 private _deadLine;

    struct CALLDATAPARAM {
        string signature;
        // uint16 newmaxMint;
        // uint256 newregistrationStartTime;
        // address newexecutor;
        // address newbankAddress;
        // uint256 newmintPrice;
        // uint16[1201] newTokenId;
        string description;
        bytes32 descriptionHash;
        address governance;
    }

    CALLDATAPARAM  private _callDataParam;

    struct PROPOSALPARAM {
        address  target;
        address  proposer;
        uint256  value;
    }

    PROPOSALPARAM private _proposalParams;

    mapping(address proposerAdd => address targetAdd) private _targetConnectors;
    mapping(address => Voter) private _voters;
    mapping(address => uint16[1201]) private _targetSociety;



    // /** 
    //  * @dev Create a new ballot to choose one of 'proposalNames'.
    //  * @param proposalNames names of proposals
    //  */
    constructor(
        CALLDATAPARAM memory callDataParam_,
        uint256 value_,
        VOTINGPARAM memory votingParams_,
        bytes32 name_) {

        // calldata param
        _callDataParam = callDataParam_;
        _callDataParam.descriptionHash = keccak256(abi.encode(_callDataParam.description));

        // proposal param
        _proposalParams.proposer = msg.sender;
        _proposalParams.target = _targetConnectors[_proposalParams.proposer];
        if (_proposalParams.target == address(0)) {
            revert invalidProposer(_proposalParams.proposer);
        }
        _proposalParams.value = value_;

        // voting param
        _votingParams = votingParams_;
        _deadLine = _votingParams.voteStart + _votingParams.voteDuration;

        // Ballot param
        _ballotParam.name = name_;
        _ballotParam.voteCount = 0;
        _ballotParam.observed = 0;

        // _setVoters()

    }


    function getBallotCallDataParams() public view returns (string memory, string memory, bytes32, address) {
        return (_callDataParam.signature, _callDataParam.description,  _callDataParam.descriptionHash, _callDataParam.governance);
    }

    function getBallotProposalParams() public view returns (address, address, uint256) {
        return (_proposalParams.target, _proposalParams.proposer, _proposalParams.value);
    }

    function getBalootVotingParams() public view returns (uint16, uint32, uint48, uint48) {
        return (_votingParams.quorum, _votingParams.voteDuration, _votingParams.voteStart, _votingParams.etaSeconds);
    }

    function getBallotCallData() public view virtual  returns (bytes memory callData) {
        callData = abi.encodeWithSignature(_callDataParam.signature); // parametrhaye signature bayad ezafe shavad
    }

    function getBallotProposalId() public view returns (uint256 proposalId) {
        proposalId = uint256(keccak256(abi.encode(_proposalParams.target, _proposalParams.value, getBallotCallData(), _callDataParam.descriptionHash)));
    }

    function getBallotParam() public view returns (bytes32 name, uint16 voteCount, uint16 observed) {
        return (_ballotParam.name, _ballotParam.voteCount, _ballotParam.observed);
    }


    /** 
     * @dev Give 'voter' the right to vote on this ballot. May only be called by 'chairperson'.
     * @param voter address of voter
     */
    // function giveRightToVote(address voter) public {
    //     if (!isVotingDeadLine()) {
    //         revert VotingIsOver(_deadLine);
    //     }
    //     require(
    //         msg.sender == _proposalParams.proposer,
    //         "Only proposer can give right to vote."
    //     );
    //     require(
    //         !_voters[voter].voted,
    //         "The voter already voted."
    //     );
    //     require(_voters[voter].weight == 0);
    //     _voters[voter].weight = 1;
    // }

    /**
     * @dev Delegate your vote to the voter 'to'.
     * @param to address to which vote is delegated
     */
    function delegate(address to) public {
        if (!isVotingDeadLine()) {
            revert VotingIsOver(_deadLine);
        }
        require(!_voters[msg.sender].voted, "Already voted.");
        _votersPermission();
        Voter storage sender = _voters[msg.sender];
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (_voters[to].delegate != address(0)) {
            to = _voters[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }
        sender.voted = true;
        _ballotParam.observed += sender.weight;
        sender.delegate = to;
        Voter storage delegate_ = _voters[to];
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            _ballotParam.voteCount += (sender.weight + sender.delegateWeight);
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            delegate_.delegateWeight += (sender.weight + sender.delegateWeight);
        }

    }

    /**
     * @dev Give your vote (including votes delegated to you).
     * @param opinion index of opinion in the vote function
     */
    function vote(bool opinion) public {
        if (block.timestamp < _votingParams.voteStart) { 
            revert VotingHasNotStarted(_votingParams.voteStart);
        } else if (!isVotingDeadLine()) {
            revert VotingIsOver(_deadLine);
        }
        require(!_voters[msg.sender].voted, "Already voted.");
        _votersPermission();
        Voter storage sender = _voters[msg.sender];
        sender.voted = true;
        sender.votedTime = block.timestamp;
        if (opinion) {
            _ballotParam.observed += sender.weight;
            _ballotParam.voteCount += (sender.weight + sender.delegateWeight);
        } else _ballotParam.observed += sender.weight;
        emit TheVoteWasRegistered(msg.sender,address(this));
    }

    /** 
     * @dev Computes the winning proposal taking all previous votes into account.
     * @return winningProposal_ index of winning proposal in the proposals array
     */
    function voteCountProposal() public view
            returns (uint26 winningProposal_)
    {
        // uint winningVoteCount = 0;
        // for (uint p = 0; p < proposals.length; p++) {
        //     if (proposals[p].voteCount > winningVoteCount) {
        //         winningVoteCount = proposals[p].voteCount;
        //         winningProposal_ = p;
        //     }
        // }
    }

    function _votersPermission() private {
        uint16 weight_ = IgetBalance(_proposalParams.target).balanceOf(msg.sender);
        if (weight_ > 0) {
            _voters[msg.sender].weight = weight_;
        }
        require(_voters[msg.sender].weight != 0 || _voters[msg.sender].delegateWeight != 0, "Has no right to vote");
    }

    function isVotingDeadLine() private returns (bool) {
        uint48 currentTime = uint48(block.timestamp);
        if (currentTime <= _deadLine) {
            return true;
        } else if (_ballotParam.observed < _votingParams.quorum) {
            if (currentTime <= (_votingParams.voteStart + _votingParams.voteDuration + _votingParams.etaSeconds)) {
                _deadLine += _votingParams.etaSeconds;
                emit etaSecondsIsActivated(address(this), _votingParams.etaSeconds);
                return true;
            } 
        }
        return false;
    }
}