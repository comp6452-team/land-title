// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract landtitle {


    struct userDetail{
        uint24 id;
        bytes32 firstName;
        bytes32 lastName;
        bytes32 district;
        uint24 contact;
        uint24 postCode;
        bool isExist;
        //define all the properties that a user have
        uint number;
        bytes32[] proL;
    }



    struct property{
        bytes32 district;
        bytes32 city;
        uint24 pID;
        uint24 pType;
        uint24 pArea;
        bool isExist;
        bool available;
        uint percentLeft;
        address payable[] owners;
        mapping(address payable =>uint24)OwnersOwn;
    }


    mapping (address payable => userDetail)  users;

    mapping (bytes32 => property)  properties;


    uint24[]   userL;
    uint24[]   propertyL;


    //the authority,e.g. government,have the ability the create the contract
    constructor() public {
        address payable authority = msg.sender;
    }



    function AddUser(address payable add,string firstname, string lastname1, string district1, string contact1, uint24 postcode, uint24 uid) public{
        require(msg.sender == authority, "no rights");

        require(users[add].isExist == false, "User already exist");

        users[add].firstName = bytes(firstname1);
        users[add].lastName = bytes(lastname1);
        users[add].district = bytes(district1);
        users[add].contact = bytes(contact1);
        users[add].postCode = postcode1;
        users[add].isExist = true;
        users[add].number=0;
        users[add].id=uid;

        userL.push(uid);
    }

    function getUser(address payable uid1) public view returns(bytes32 firstname1, bytes32 lastname1, bytes32 district1, bytes32 contact1, uint24 postCode1, bytes32[] propertyL1,uint24 id1){
        require(users[uid1].isExist == true, "User Doesn't exist");
        firstname1 = users[uid1].firstName;
        lastname1 = users[uid1].lastName;
        district1 = users[uid1].district;
        contact1 = users[uid1].contact;
        postCode1 = users[uid1].postCode;
        propertyL1 = users[uid1].proL;
        id1=users[uid1].id;
    }


    function addProperty(uint24 p,string district1, string city1, uint24 pType1, uint24 pArea1) public{
        require(msg.sender == authority, "no rights");
        pid1=keccak256(abi.encodePacked(p, block.timestamp));
        require(properties[pid1].isExist != true, "Property already exsits");

        properties[pid1].district = bytes (district1);
        properties[pid1].city = bytes (city1);
        properties[pid1].pID = p;
        properties[pid1].pType = pType1;
        properties[pid1].pArea = pArea1;
        properties[pid1].isExist = true;
        properties[pid1].available=false;
        properties[pid1].percentLeft=100;
        propertyL.push(p);

    }
    function addUserOwned(address payable uid, bytes32 p,uint24 percent) public{
        require(msg.sender == authority, "no rights");
        require(properties[p].percentLeft>=percent, "not enough land to add");
        users[uid].number ++;
        for(uint i = 0; i<users[uid].proL.length; i++){
            if(p==users[uid].proL[i]){
                break;
            }else{
                if(i==users[uid].proL.length-1){
                    users[uid].proL.push(p); }
            }}

        for(uint i = 0; i<properties[p].owners.length; i++){
            if(uid==properties[p].owners[i]){
                properties[p].OwnersOwn+=percent;
                properties[p].percentLeft-=percent;

            }else{
                if(i==properties[p].owners.length-1){
                properties[p].owners.push(uid);
                properties[p].OwnersOwn=percent;
                properties[p].percentLeft-=percent;
                }
            }}
    }

    function getProperty(bytes32 pid1) public view returns(bytes32 district1, bytes32 city1, uint24 pType1, uint24 pArea1,bool available,address payable[] owners1){
        require(properties[pid1].isExist == true, "Property doesn't exist");
        district1 = properties[pid1].district;
        city1 = properties[pid1].city;
        pType1 = properties[pid1].pType;
        pArea1 = properties[pid1].pArea;
        available=properties[pid1].available;
        owners1=properties[pid1].OwnersOwn;
    }


    function SetAvailable(bytes32 p)public{
        require(properties[p].isExist == true, "property doesn't exist");


        for(uint i = 0; i<users[msg.sender].proL.length; i++){
            if(users[msg.sender].proL[i]==p){
                properties[p].available=true;
                break;
            }else{
                if(i==users[msg.sender].proL.length-1){
                    revert("you have no rights");
                }
            }

        }}

    function buyProperty(bytes32 property1,address payable fromUser,uint24 proportion,uint24 value,uint24 tax)public payable{
        require(properties[property1].available == true,"property not available");
        for(uint i=0;i<users[user1].proL.length;i++){
            if(users[user1].proL[i]==property1){
                users[fromUser].transfer(value);
                PayTax(tax);
                removeOwnership(fromUser,property1,proportion);
                addUserOwned(msg.sender,property1,proportion);
                properties[property1].available=false;
            }else{
                if(i==users[fromUser].proL.length-1){
                    revert( "the user you bought from doesn't have the property" );
                }
            }
        }
    }


    function removeOwnership(address payable user1,bytes32 property1,uint24 proportion)private{
        if(properties[p].OwnersOwn[user1]<proportion){
            revert( "not enough land to buy");
        }else if(properties[p].OwnersOwn[user1]==proportion){
            delete properties[p].OwnersOwn[user1];
            properties[p].percentLeft+=proportion;
            for(uint i = 0; i<users[user1].proL.length; i++){
                if(users[user1].proL[i]==property1){
                    delete users[user1].proL[i];
                    break;
                }}
            for(uint i = 0; i<properties[property1].owners.length; i++){
                if(properties[property1].owners[i]==user1){
                    delete properties[property1].owners[i];
                    break;
                }

            }
        }else{
            properties[p].percentLeft+=proportion;
            properties[p].OwnersOwn[user1]-=proportion;
        }
    }



    function PayTax(uint24 value){
        authority.transfer(value);

    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }


    function deposit(uint256 amount)public payable{
        if(amount!=msg.value)return;

        address(this).balance+= amount;


    }

}