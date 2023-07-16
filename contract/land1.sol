pragma solidity ^0.8.0;

//properties Details
contract propertiesRegistration{

    struct user{
        bytes32[] assets;
    }

    struct property{
        string city;
        string district;
        string detail;
        address payable  CurrentOwner;
        bool isAvailable;
        uint24 value;
        
    }





    uint24 number=0;
    mapping(bytes32 => property) properties;
    address payable authority;
    mapping(address => user) users;
    bytes32[] propertiesList;
    
    //contract owner
    constructor() public{
        authority = payable(msg.sender);
    }
    modifier onlyOwner {
        require(msg.sender == authority,"no rights");
        _;
    }
    

    //Registration of properties details.
    function Registration(string memory _city,string memory _district,
        string memory _detail, address payable _OwnerAddress
        ) public onlyOwner returns(bool) {
        
        bytes32 id=keccak256(abi.encodePacked(number, block.timestamp));
        properties[id].city = _city;
        properties[id].district = _district;
        properties[id].detail = _detail;
        properties[id].CurrentOwner= _OwnerAddress;
        users[_OwnerAddress].assets.push(id);
        propertiesList.push(id);
        number++;
        return true;
    }

    function propertyInfo(uint i) public view returns(string memory,string memory,string memory,bool,address,bytes32){
        bytes32 id=propertiesList[i];
        return(properties[id].city,properties[id].district,properties[id].detail,properties[id].isAvailable,properties[id].CurrentOwner,propertiesList[i]);
    }

    function propertyInfoByBytes(bytes32 id) public view returns(string memory,string memory,string memory,bool,address){
        return(properties[id].city,properties[id].district,properties[id].detail,properties[id].isAvailable,properties[id].CurrentOwner);
    }
    
    
    
    function userInfo()public view returns(bytes32[] memory){
        return (users[msg.sender].assets);
    }

    
    function setAvailable(bytes32 property,uint24 _value)public{
        require(properties[property].CurrentOwner == msg.sender);
        properties[property].isAvailable=true;
        properties[property].value=_value;
    } 
    //buying the approved property
    function buyProperty(bytes32 property)public payable{
        require(properties[property].isAvailable == true, "property not available");
        require(msg.value >= (properties[property].value+((properties[property].value)/4)));
        properties[property].CurrentOwner.transfer(properties[property].value);
        paytax();
        removeOwnership(properties[property].CurrentOwner,property);
        properties[property].CurrentOwner=payable(msg.sender);
        users[msg.sender].assets.push(property);
        
    }

    function paytax()public payable {
        authority.transfer(msg.value/2);
    }
    //removing the ownership of seller for the properties. and it is called by the buyProperty function
    function removeOwnership(address buyFrom,bytes32 id)private{
        uint index = findId(id,buyFrom);
        users[buyFrom].assets[index]=users[buyFrom].assets[users[buyFrom].assets.length-1];
        delete users[buyFrom].assets[users[buyFrom].assets.length-1];

    }
    //for finding the index of a perticular id
    function findId(bytes32 id,address user)private  view returns(uint){
        uint i;
        for(i=0;i<users[user].assets.length;i++){
            if(users[user].assets[i] == id)
                return i;
        }
        return i;
    }
    function getBalance() public payable returns(uint256){
       return (msg.value);
   }
}
