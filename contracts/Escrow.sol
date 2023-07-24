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
    bool public titleReleased;

    event CheckPayment(address funder, address beneficiary, uint256 titleId);

    constructor(address _beneficiary, address _oracle, address _landTitleContract, uint256 _titleId) {
        funder = msg.sender;
        beneficiary = _beneficiary;
        oracle = _oracle;
        landTitleContract = _landTitleContract;
        titleId = _titleId;
        titleReleased = false;
    }

    function redeem() public {
        require(msg.sender == beneficiary, 'Only beneficiary can call');
        require(titleReleased, 'Title has been released');  

        emit CheckPayment(funder, beneficiary, titleId);
    }

    function release() public {
        require(msg.sender == funder, 'Only funder can call');
        require(!titleReleased, 'Title has not been released');  

        titleReleased = true;
    }

    function paymentReceived() public {
        require(msg.sender == oracle, 'Only oracle can call');
        require(titleReleased, 'Title has not been released yet');

        LandTitle(landTitleContract).transferTitle(funder, beneficiary, titleId);
    }
}