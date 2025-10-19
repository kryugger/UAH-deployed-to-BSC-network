// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Campaign {
    enum Status { Active, Completed, Successful }

    IERC20 public token;
    address public beneficiary;
    uint256 public target;
    uint256 public deadline;
    uint256 public totalDonated;
    Status public status;

    string public name;
    string public description;

    event DonationReceived(address indexed donor, uint256 amount);
    event CampaignCompleted(bool successful);
    event MetadataUpdated(string name, string description);

    constructor(
        IERC20 _token,
        address _beneficiary,
        uint256 _target,
        uint256 _deadline,
        string memory _name,
        string memory _description
    ) {
        require(address(_token) != address(0), "Invalid token");
        require(_beneficiary != address(0), "Invalid beneficiary");
        require(_target > 0, "Target must be > 0");
        require(_deadline > block.timestamp, "Deadline must be in the future");

        token = _token;
        beneficiary = _beneficiary;
        target = _target;
        deadline = _deadline;
        name = _name;
        description = _description;
        status = Status.Active;

        emit MetadataUpdated(_name, _description);
    }

    function donate(uint256 amount) external {
        require(status == Status.Active, "Campaign not active");
        require(block.timestamp < deadline, "Campaign ended");
        require(amount > 0, "Amount must be > 0");

        token.transferFrom(msg.sender, beneficiary, amount);
        totalDonated += amount;

        emit DonationReceived(msg.sender, amount);

        if (totalDonated >= target) {
            status = Status.Successful;
            emit CampaignCompleted(true);
        }
    }

    function markComplete() external {
        require(status == Status.Active, "Already completed");
        require(block.timestamp >= deadline, "Deadline not reached");

        status = totalDonated >= target ? Status.Successful : Status.Completed;
        emit CampaignCompleted(status == Status.Successful);
    }

    function remainingToTarget() external view returns (uint256) {
        if (totalDonated >= target) return 0;
        return target - totalDonated;
    }

    function updateMetadata(string memory _name, string memory _description) external {
        name = _name;
        description = _description;
        emit MetadataUpdated(_name, _description);
    }

    function isSuccessful() external view returns (bool) {
        return status == Status.Successful;
    }
}