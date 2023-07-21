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

    //


    //
}
