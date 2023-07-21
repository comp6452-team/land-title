pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract LandTitle is ERC721 {
    struct Title {
        string dataHash;
    }

    mapping(uint256 => Title) private _titleDetails;

    constructor() ERC721("LandTitle", "LTT") {}

    // registers new Title
    function registerTitle(uint256 tokenId, string memory dataHash) public {
        require(!_exists(tokenId), "ERC721: token already minted");

        _mint(msg.sender, tokenId);

        _titleDetails[tokenId] = Title(dataHash);
    }

    // returns dataHash
    function getTitleDetails(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721: queried token does not exist");
        return _titleDetails[tokenId].dataHash;
    }
}


// SPDX-License-Identifier: MIT

contract LandTitle {
    struct Title {
        address currentOwner;
        string dataHash; // this will be the hash of the off-chain land title data
    }

    mapping(string => Title) public titles;

    event TitleRegistered(string indexed titleId, address indexed currentOwner, string dataHash);
    event TitleTransferred(string indexed titleId, address indexed oldOwner, address indexed newOwner);

    function registerTitle(string memory titleId, string memory dataHash) public {
        // Ensure the title hasn't been registered before
        require(titles[titleId].currentOwner == address(0), "Title already exists");

        // Register the new title
        titles[titleId] = Title(msg.sender, dataHash);

        emit TitleRegistered(titleId, msg.sender, dataHash);
    }

    function transferTitle(string memory titleId, address newOwner) public {
        // Ensure the title exists
        require(titles[titleId].currentOwner != address(0), "Title doesn't exist");

        // Ensure the current owner is the sender
        require(titles[titleId].currentOwner == msg.sender, "Only the title owner can transfer");

        // Transfer the title
        address oldOwner = titles[titleId].currentOwner;
        titles[titleId].currentOwner = newOwner;

        emit TitleTransferred(titleId, oldOwner, newOwner);
    }
}
