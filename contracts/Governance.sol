// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

contract Governance is
    Governor,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    constructor(IVotes _token, TimelockController _timelock)
        Governor("UAH Governance")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4) // 4% кворум
        GovernorTimelockControl(_timelock)
    {}

    function votingPeriod() public pure override returns (uint256) {
        return 45818;
    }

    function votingDelay() public pure override returns (uint256) {
        return 1;
    }

    function proposalThreshold() public pure override returns (uint256) {
        return 1000e18;
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

    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // 🔍 Получить статус предложения в виде строки
    function proposalStatus(uint256 proposalId) external view returns (string memory) {
        ProposalState s = state(proposalId);
        if (s == ProposalState.Pending) return "Pending";
        if (s == ProposalState.Active) return "Active";
        if (s == ProposalState.Canceled) return "Canceled";
        if (s == ProposalState.Defeated) return "Defeated";
        if (s == ProposalState.Succeeded) return "Succeeded";
        if (s == ProposalState.Queued) return "Queued";
        if (s == ProposalState.Expired) return "Expired";
        if (s == ProposalState.Executed) return "Executed";
        return "Unknown";
    }

    // 📊 Проверить, голосовал ли адрес
    function hasVoted(uint256 proposalId, address account)
    public
    view
    override(GovernorCountingSimple, IGovernor)
    returns (bool)
{
    // твоя логика
}

    // 📈 Получить силу голоса адреса
    function getVotingPower(address account) external view returns (uint256) {
        return getVotes(account, block.number - 1);
    }

    // 📋 Получить детали предложения
    function getProposalDetails(uint256 proposalId)
        external
        view
        returns (
            ProposalState status,
            uint256 snapshot,
            uint256 deadline,
            string memory statusText
        )
    {
        status = state(proposalId);
        snapshot = proposalSnapshot(proposalId);
        deadline = proposalDeadline(proposalId);
        statusText = this.proposalStatus(proposalId);
    }

    // ✅ Проверка достижения кворума
    function quorumReached(uint256 proposalId) external view returns (bool) {
        return _quorumReached(proposalId);
    }
}