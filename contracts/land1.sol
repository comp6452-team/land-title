// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

contract LandRegistry {
    struct Property {
        uint256 propertyId;
        address currentOwner;
        string location;
        uint256 size;
    }

    mapping(uint256 => Property) public properties;
    uint256 public propertyCount;

    event propertyAdded(uint256 propertyId, address currentOwner, string location, uint256 size);
    event ownershipTransferred(uint256 propertyId, address indexed previousOwner, address indexed newOwner);

    function addProperty(string memory _location, uint256 _size) public {
        propertyCount ++;
        properties[propertyCount] = Property(propertyCount, msg.sender, _location, _size);
        emit propertyAdded(propertyCount, msg.sender, _location, _size);
    }

    function transferOwnership(uint256 _propertyId, address _newOwner) public {
        require(properties[_propertyId].currentOwner == msg.sender, "Only the current owner can transfer property");
        properties[_propertyId].currentOwner = _newOwner;
        emit ownershipTransferred(_propertyId, msg.sender, _newOwner);
    }
}
