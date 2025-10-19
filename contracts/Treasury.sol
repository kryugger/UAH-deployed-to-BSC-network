// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./DonorBadge.sol";

contract Treasury is AccessControl, Pausable {
    DonorBadge public badge;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    mapping(address => bool) public supportedTokens;
    address[] public tokenList;

    struct Donation {
        address donor;
        address token;
        uint256 amount;
        uint256 timestamp;
        address campaign;
    }

    Donation[] public donations;

    event Funded(address indexed campaign, address indexed token, uint256 amount);
    event BadgeMinted(address indexed donor, uint256 tokenId);
    event BadgeContractUpdated(address indexed newBadge);
    event Withdrawn(address indexed to, address indexed token, uint256 amount);
    event TokenAdded(address indexed token);
    event TokenRemoved(address indexed token);
    event Paused();
    event Unpaused();
    event DonationRecorded(address indexed donor, address indexed campaign, uint256 amount, uint256 timestamp);

    constructor(address owner, address badgeAddress) {
        require(owner != address(0), "Invalid owner");
        require(badgeAddress != address(0), "Invalid badge address");

        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(MANAGER_ROLE, owner);
        _grantRole(DAO_ROLE, owner);

        badge = DonorBadge(badgeAddress);
    }

    function fundCampaign(IERC20 token, address campaign, uint256 amount)
        external
        whenNotPaused
        onlyRole(MANAGER_ROLE)
    {
        _fund(token, campaign, amount, msg.sender);
    }

    function daoFund(IERC20 token, address campaign, uint256 amount)
        external
        whenNotPaused
        onlyRole(DAO_ROLE)
    {
        _fund(token, campaign, amount, msg.sender);
    }

    function _fund(IERC20 token, address campaign, uint256 amount, address donor) internal {
        require(supportedTokens[address(token)], "Token not supported");
        require(campaign != address(0), "Invalid campaign");
        require(amount > 0, "Amount must be > 0");

        bool success = token.transfer(campaign, amount);
        require(success, "Token transfer failed");

        badge.mint(donor);
        donations.push(Donation(donor, address(token), amount, block.timestamp, campaign));

        uint256 tokenId = badge.lastBadgeOf(donor);
        emit Funded(campaign, address(token), amount);
        emit BadgeMinted(donor, tokenId);
        emit DonationRecorded(donor, campaign, amount, block.timestamp);
    }

    function addSupportedToken(address token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(token != address(0), "Invalid token");
        require(!supportedTokens[token], "Token already supported");

        supportedTokens[token] = true;
        tokenList.push(token);
        emit TokenAdded(token);
    }

    function removeSupportedToken(address token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(supportedTokens[token], "Token not supported");

        supportedTokens[token] = false;

        for (uint256 i = 0; i < tokenList.length; i++) {
            if (tokenList[i] == token) {
                tokenList[i] = tokenList[tokenList.length - 1];
                tokenList.pop();
                break;
            }
        }

        emit TokenRemoved(token);
    }

    function getSupportedTokens() external view returns (address[] memory) {
        return tokenList;
    }

    function updateBadgeContract(address newBadge) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newBadge != address(0), "Invalid badge address");
        badge = DonorBadge(newBadge);
        emit BadgeContractUpdated(newBadge);
    }

    function withdraw(IERC20 token, address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(address(token) != address(0), "Invalid token");
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be > 0");

        bool success = token.transfer(to, amount);
        require(success, "Withdraw failed");
        emit Withdrawn(to, address(token), amount);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
        emit Paused();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
        emit Unpaused();
    }

    function getDonations() external view returns (Donation[] memory) {
        return donations;
    }
}