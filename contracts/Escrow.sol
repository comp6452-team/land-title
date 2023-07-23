// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./LandTitle.sol";

contract Escrow {
    address public funder;
    address public beneficiary;
    address public oracle;
    address public landTitleContract;
    uint256 titleId;

    event CheckDelivery(address funder, address beneficiary);
    event DeliveryStatus(bool status);

    constructor(address _beneficiary, address _oracle, address _landTitleContract, uint256 _titleId) {
        funder = msg.sender;
        beneficiary = _beneficiary;
        oracle = _oracle;
        landTitleContract = _landTitleContract;
        titleId = _titleId;
    }

    function redeem() public {
        require(msg.sender == beneficiary, 'Only beneficiary can call');
        
        emit CheckDelivery(funder, beneficiary);
    }

    function release() public {
        require(msg.sender == funder, 'Only funder can call');
    }

    function deliveryStatus(bool isDelivered) public {
        require(msg.sender == oracle, 'Only oracle can call');

        emit DeliveryStatus(isDelivered);

        if (isDelivered) {
            LandTitle(landTitleContract).transferTitle(beneficiary, titleId);
        }
    }
}