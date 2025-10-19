// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./Campaign.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CampaignFactory {
    address[] public campaigns;
    address public dao;

    mapping(bytes32 => bool) public campaignHashes;

    /// @notice Событие, фиксирующее создание новой кампании
    event CampaignCreated(address indexed creator, address campaignAddress);

    /// @notice Устанавливает DAO, который имеет право создавать кампании
    constructor(address _dao) {
        require(_dao != address(0), "Invalid DAO address");
        dao = _dao;
    }

    /// @notice Создаёт новый кампейн с ERC20 токеном и метаданными
    /// @param token Адрес ERC20 токена, который будет использоваться для пожертвований
    /// @param beneficiary Получатель средств кампейна
    /// @param target Целевая сумма в токенах
    /// @param deadline Временная метка (timestamp) окончания кампейна
    /// @param name Название кампании
    /// @param description Описание кампании
    function createCampaign(
        address token,
        address beneficiary,
        uint256 target,
        uint256 deadline,
        string memory name,
        string memory description
    ) external {
        require(msg.sender == dao, "Only DAO can create campaigns");
        require(token != address(0), "Invalid token address");
        require(beneficiary != address(0), "Invalid beneficiary");
        require(target > 0, "Target must be > 0");
        require(deadline > block.timestamp, "Deadline must be in the future");

        bytes32 hash = keccak256(abi.encodePacked(token, beneficiary, target, deadline, name));
        require(!campaignHashes[hash], "Campaign already exists");
        campaignHashes[hash] = true;

        Campaign c = new Campaign(
            IERC20(token),
            beneficiary,
            target,
            deadline,
            name,
            description
        );

        campaigns.push(address(c));
        emit CampaignCreated(msg.sender, address(c));
    }

    /// @notice Возвращает все созданные кампейны
    function allCampaigns() external view returns (address[] memory) {
        return campaigns;
    }

    /// @notice Возвращает количество созданных кампейнов
    function getCampaignsCount() external view returns (uint256) {
        return campaigns.length;
    }
}