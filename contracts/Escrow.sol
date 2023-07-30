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

    constructor() {
        funder = msg.sender;
        titleReleased = false;
    }

    function redeem(uint256 _titleId) public {
        require(msg.sender == beneficiary, 'Only beneficiary can call');
        require(titleReleased, 'Title has been released');
        require(titleId == _titleId, 'Title is correct Title');

        emit CheckPayment(funder, beneficiary, titleId);
    }

    function release(address _beneficiary, uint256 _titleId) public {
        require(msg.sender == funder, 'Only funder can call');
        require(!titleReleased, 'Title has not been released');  

        beneficiary = _beneficiary;
        titleId = _titleId;
        titleReleased = true;
    }

    function paymentReceived() public {
        require(msg.sender == oracle, 'Only oracle can call');
        require(titleReleased, 'Title has not been released yet');

        LandTitle(landTitleContract).transferTitle(funder, beneficiary, titleId);
    }

    function setOracle(address _oracle) public {
        oracle = _oracle;
    }

    function setLandTitleContract(address _landTitleContract) public {
        landTitleContract = _landTitleContract;
    }
}