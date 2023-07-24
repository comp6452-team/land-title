// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "truffle/Console.sol";
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
    function registerTitle(string memory dataHash) public returns( uint256){
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        // console.log(msg.sender);
        _mint(msg.sender, tokenId);

        _titleDetails[tokenId] = Title(dataHash);

        return tokenId;
    }

    // returns dataHash
    function getTitleDetails(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721: queried token does not exist");
        return _titleDetails[tokenId].dataHash;
    }

    // verify token
    function verifyTitle(uint256 tokenId) public view returns (bool) {
        require(_exists(tokenId), "ERC721: queried token does not exist");
        // console.log(msg.sender);
        return ownerOf(tokenId) == msg.sender;
    }

    // transfer token from caller to address given
    function transferTitle(address owner, address newOwner, uint256 tokenId) public {
        require(_exists(tokenId), "ERC721: queried token does not exist");
        require(ownerOf(tokenId) == owner, "ERC721: owner is not the owner");
        // console.log(msg.sender);
        transferToken(msg.sender, newOwner, tokenId);
    }

    function transferToken(address owner, address newOwner, uint256 tokenId) private {
        _transfer(owner, newOwner, tokenId);
    }
}
