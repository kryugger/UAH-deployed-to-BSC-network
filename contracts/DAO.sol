// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "./DonorBadge.sol";

contract DAO is Governor, GovernorTimelockControl {
    ERC20Votes public token;
    DonorBadge public badge;

    mapping(uint256 => ProposalVote) private _proposalVotes;
    mapping(uint256 => mapping(address => VoterProfile)) public voterMetadata;
    mapping(address => VoterProfile) public purchaseMetadata;
    mapping(uint256 => mapping(address => bool)) public hasVotedFlag;

    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
    }

    struct VoterProfile {
        string country;
        string gender;
        string ageGroup;
        string ideology;
        string religion;
        string educationLevel;
        string incomeBracket;
        string politicalAffiliation;
        bool isDonor;
    }

    event MetadataSubmitted(
        uint256 indexed proposalId,
        address indexed voter,
        string country,
        string gender,
        string ageGroup,
        string ideology,
        string religion,
        string educationLevel,
        string incomeBracket,
        string politicalAffiliation,
        bool isDonor
    );

    event PurchaseMetadataSubmitted(
        address indexed user,
        string country,
        string gender,
        string ageGroup,
        string ideology,
        string religion,
        string educationLevel,
        string incomeBracket,
        string politicalAffiliation,
        bool isDonor
    );

    event VoteCounted(
        uint256 indexed proposalId,
        address indexed voter,
        uint8 support,
        uint256 weight,
        string country,
        string ideology,
        string religion
    );

    constructor(ERC20Votes _token, TimelockController _timelock, DonorBadge _badge)
        Governor("UAH DAO")
        GovernorTimelockControl(_timelock)
    {
        token = _token;
        badge = _badge;
    }

    function submitVoteMetadata(
        uint256 proposalId,
        string memory country,
        string memory gender,
        string memory ageGroup,
        string memory ideology,
        string memory religion,
        string memory educationLevel,
        string memory incomeBracket,
        string memory politicalAffiliation,
        bool isDonor
    ) external {
        require(bytes(voterMetadata[proposalId][msg.sender].country).length == 0, "Already submitted");

        VoterProfile memory profile = VoterProfile({
            country: country,
            gender: gender,
            ageGroup: ageGroup,
            ideology: ideology,
            religion: religion,
            educationLevel: educationLevel,
            incomeBracket: incomeBracket,
            politicalAffiliation: politicalAffiliation,
            isDonor: isDonor
        });

        voterMetadata[proposalId][msg.sender] = profile;

        if (isDonor) {
            badge.mint(msg.sender);
        }

        emit MetadataSubmitted(
            proposalId,
            msg.sender,
            country,
            gender,
            ageGroup,
            ideology,
            religion,
            educationLevel,
            incomeBracket,
            politicalAffiliation,
            isDonor
        );
    }

    function submitPurchaseMetadata(
        string memory country,
        string memory gender,
        string memory ageGroup,
        string memory ideology,
        string memory religion,
        string memory educationLevel,
        string memory incomeBracket,
        string memory politicalAffiliation,
        bool isDonor
    ) external {
        purchaseMetadata[msg.sender] = VoterProfile({
            country: country,
            gender: gender,
            ageGroup: ageGroup,
            ideology: ideology,
            religion: religion,
            educationLevel: educationLevel,
            incomeBracket: incomeBracket,
            politicalAffiliation: politicalAffiliation,
            isDonor: isDonor
        });

        if (isDonor) {
            badge.mint(msg.sender);
        }

        emit PurchaseMetadataSubmitted(
            msg.sender,
            country,
            gender,
            ageGroup,
            ideology,
            religion,
            educationLevel,
            incomeBracket,
            politicalAffiliation,
            isDonor
        );
    }

    function getVoterProfile(uint256 proposalId, address voter)
        external
        view
        returns (VoterProfile memory)
    {
        return voterMetadata[proposalId][voter];
    }

    function hasSubmittedMetadata(uint256 proposalId, address voter)
        external
        view
        returns (bool)
    {
        return bytes(voterMetadata[proposalId][voter].country).length > 0;
    }

    function getProposalVotes(uint256 proposalId)
        external
        view
        returns (uint256 forVotes, uint256 againstVotes, uint256 abstainVotes)
    {
        ProposalVote memory votes = _proposalVotes[proposalId];
        return (votes.forVotes, votes.againstVotes, votes.abstainVotes);
    }

    function votingDelay() public pure override returns (uint256) {
        return 1;
    }

    function votingPeriod() public pure override returns (uint256) {
        return 45818;
    }

    function quorum(uint256) public pure override returns (uint256) {
        return 1;
    }

    function getVotes(address account, uint256 blockNumber)
        public
        view
        override(Governor, IGovernor)
        returns (uint256)
    {
        return token.getPastVotes(account, blockNumber);
    }

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    )
        public
        override(Governor, IGovernor)
        returns (uint256)
    {
        return super.propose(targets, values, calldatas, description);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function clock() public view override returns (uint48) {
        return uint48(block.number);
    }

    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=blocknumber&from=default";
    }

    function COUNTING_MODE() public pure override returns (string memory) {
        return "support=bravo&quorum=for";
    }

    function hasVoted(uint256 proposalId, address account)
    public
    view
    override(IGovernor)
    returns (bool)
    {
    return hasVotedFlag[proposalId][account];
    }

    function _getVotes(
        address account,
        uint256 timepoint,
        bytes memory
    )
        internal
        view
        override
        returns (uint256)
    {
        return token.getPastVotes(account, timepoint);
    }

    function _quorumReached(uint256 proposalId)
        internal
        view
        override
        returns (bool)
    {
        ProposalVote memory votes = _proposalVotes[proposalId];
        return quorum(proposalSnapshot(proposalId)) <= votes.forVotes;
    }

    function _voteSucceeded(uint256 proposalId)
        internal
        view
        override
        returns (bool)
    {
        ProposalVote memory votes = _proposalVotes[proposalId];
        return votes.forVotes > votes.againstVotes;
    }

    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight,
        bytes memory
    ) internal override {
        ProposalVote storage votes = _proposalVotes[proposalId];

        if (support == 0) {
            votes.againstVotes += weight;
        } else if (support == 1) {
            votes.forVotes += weight;
        } else if (support == 2) {
            votes.abstainVotes += weight;
        } else {
            revert("Invalid vote type");
        }

        VoterProfile memory profile = voterMetadata[proposalId][account];

        if (bytes(profile.country).length == 0) {
            badge.mint(account);
        }

        emit VoteCounted(
            proposalId,
            account,
            support,
            weight,
            profile.country,
            profile.ideology,
            profile.religion
        );

        hasVotedFlag[proposalId][account] = true;
    }
}

