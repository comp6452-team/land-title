pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract LandTitleRegistry is ERC721 {

    struct LandTitle {
        bytes32 titleHash;
    }

    mapping(uint256 => LandTitle) public landTitles;

    constructor() ERC721("LandTitle", "LT") {}
}