// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract LandTitle is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Title {
        string dataHash;
    }

    mapping(uint256 => Title) private _titleDetails;

    constructor() ERC721("LandTitle", "LTT") {}

    // registers new Title as a token
    function registerTitle(string memory dataHash) public {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        _mint(msg.sender, tokenId);

        _titleDetails[tokenId] = Title(dataHash);

        // assign ownership to whoever calls function to register
        transferToken(address(this), msg.sender, tokenId);
    }

    // returns dataHash
    function getTitleDetails(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721: queried token does not exist");
        return _titleDetails[tokenId].dataHash;
    }

    // verify token
    function verifyTitle(uint256 tokenId) public view returns (bool) {
        require(_exists(tokenId), "ERC721: queried token does not exist");
        return ownerOf(tokenId) == msg.sender;
    }

    // transfer token from caller to address given
    // owner = msg.sender, newOwner = given address
    function transferTitle(uint256 tokenId, address newOwner) public {
        require(_exists(tokenId), "ERC721: queried token does not exist");
        require(ownerOf(tokenId) == msg.sender, "ERC721: sender is not the owner");

        transferToken(msg.sender, newOwner, tokenId);
    }

    function transferToken(address owner, address newOwner, uint256 tokenId) private {
        _transfer(owner, newOwner, tokenId);
    }
}
