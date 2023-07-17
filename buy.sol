//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract buy{
    struct property {
        uint256 tokenId;
        address nft;
        address buyer;
        address seller;
        uint256 purchasePrice;
        uint256 want;
        string tokenURI;
    }


    mapping(uint256 => property) public properties;

    modifier onlyBuyer(uint256 tokenId) {
        
        if (msg.sender != properties[tokenId].buyer) {
            revert ("not buyer");
        }
        _;
    }

    function prepare(uint256 tokenId,address nft,address buyer,uint256 purchasePrice,string memory tokenURI,uint256 want) external {
        IERC721(nft).transferFrom(msg.sender, address(this), tokenId);
        properties[tokenId] = property(tokenId,nft,buyer,msg.sender,purchasePrice,want,tokenURI);
        
    }

    

    function deposit(uint256 tokenId) external payable onlyBuyer(tokenId) {
        require(msg.value >= properties[tokenId].want);
        
    }

    function buyProperty(uint256 tokenId) external payable onlyBuyer(tokenId) {
        require(msg.value >=properties[tokenId].purchasePrice);
        uint256 value =properties[tokenId].purchasePrice;
        (bool success, ) = payable(properties[tokenId].seller).call{value: value}("");
        require(success);
        IERC721(properties[tokenId].nft).transferFrom(address(this), properties[tokenId].buyer, tokenId);
        
    }

    
    
}