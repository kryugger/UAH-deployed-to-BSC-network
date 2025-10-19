// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract UAHTokenV2 is ERC20, AccessControl {
    using SafeMath for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address public feeWallet;
    uint256 public feeBasisPoints;   // комиссия (в bps, 50 = 0.5%)
    uint256 public burnBasisPoints;  // сжигание (в bps, 10 = 0.1%)

    event FeeWalletChanged(address indexed oldWallet, address indexed newWallet);
    event FeeUpdated(uint256 oldFee, uint256 newFee);
    event BurnUpdated(uint256 oldBurn, uint256 newBurn);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        address feeWallet_,
        uint256 feeBP_,
        uint256 burnBP_
    ) ERC20(name_, symbol_) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

        feeWallet = feeWallet_;
        feeBasisPoints = feeBP_;
        burnBasisPoints = burnBP_;

        _mint(msg.sender, initialSupply_ * (10 ** decimals()));
    }

    function setFeeWallet(address newWallet) external onlyRole(DEFAULT_ADMIN_ROLE) {
        emit FeeWalletChanged(feeWallet, newWallet);
        feeWallet = newWallet;
    }

    function setFee(uint256 newFeeBP) external onlyRole(DEFAULT_ADMIN_ROLE) {
        emit FeeUpdated(feeBasisPoints, newFeeBP);
        feeBasisPoints = newFeeBP;
    }

    function setBurn(uint256 newBurnBP) external onlyRole(DEFAULT_ADMIN_ROLE) {
        emit BurnUpdated(burnBasisPoints, newBurnBP);
        burnBasisPoints = newBurnBP;
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        uint256 fee = amount.mul(feeBasisPoints).div(10000);
        uint256 burn = amount.mul(burnBasisPoints).div(10000);

        uint256 netAmount = amount.sub(fee).sub(burn);

        super._transfer(from, feeWallet, fee);
        super._transfer(from, address(0), burn);
        super._transfer(from, to, netAmount);
    }
}
