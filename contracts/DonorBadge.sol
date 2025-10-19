// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DonorBadge is ERC721Enumerable, Ownable {
    uint256 public nextId;
    mapping(address => uint256[]) private _badges;

    string private baseTokenURI;

    event BadgeMinted(address indexed donor, uint256 indexed tokenId);
    event BaseURIUpdated(string newURI);

    constructor() ERC721("UAH Donor Badge", "UDB") {}

    function mint(address donor) external onlyOwner {
        require(donor != address(0), "Invalid donor address");

        uint256 tokenId = nextId;
        _safeMint(donor, tokenId);
        _badges[donor].push(tokenId);

        emit BadgeMinted(donor, tokenId);
        nextId++;
    }

    function getBadges(address donor) external view returns (uint256[] memory) {
        return _badges[donor];
    }

    function setBaseURI(string memory uri) external onlyOwner {
        require(bytes(uri).length > 0, "URI cannot be empty");
        baseTokenURI = uri;
        emit BaseURIUpdated(uri);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function totalBadgesOf(address donor) external view returns (uint256) {
        return _badges[donor].length;
    }

    function lastBadgeOf(address donor) external view returns (uint256) {
        uint256 count = _badges[donor].length;
        require(count > 0, "No badges found");
        return _badges[donor][count - 1];
    }
}