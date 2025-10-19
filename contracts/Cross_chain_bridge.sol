// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface ILayerZeroEndpoint {
    function send(
        uint16 _dstChainId,
        bytes calldata _destination,
        bytes calldata _payload,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes calldata _adapterParams
    ) external payable;
}

interface IUAHToken {
    function burnFrom(address account, uint256 amount) external;
    function mint(address to, uint256 amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
}

contract CrossChainBridge is AccessControl {
    bytes32 public constant BRIDGE_OPERATOR_ROLE = keccak256("BRIDGE_OPERATOR_ROLE");

    ILayerZeroEndpoint public lzEndpoint;
    IUAHToken public token;

    event SentToChain(address indexed sender, uint16 chainId, uint256 amount);
    event MintedFromBridge(address indexed recipient, uint256 amount);

    constructor(address _endpoint, address _token, address dao) {
        lzEndpoint = ILayerZeroEndpoint(_endpoint);
        token = IUAHToken(_token);

        _grantRole(DEFAULT_ADMIN_ROLE, dao);
        _grantRole(BRIDGE_OPERATOR_ROLE, dao);
    }

    function sendToChain(uint16 chainId, bytes calldata destination, uint256 amount) external payable {
        require(token.allowance(msg.sender, address(this)) >= amount, "Bridge: insufficient allowance");

        token.burnFrom(msg.sender, amount);
        bytes memory payload = abi.encode(msg.sender, amount);

        lzEndpoint.send(chainId, destination, payload, payable(msg.sender), address(0), bytes(""));
        emit SentToChain(msg.sender, chainId, amount);
    }

    function mintFromBridge(address to, uint256 amount) external onlyRole(BRIDGE_OPERATOR_ROLE) {
        token.mint(to, amount);
        emit MintedFromBridge(to, amount);
    }
}