// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract landtitle {


    struct userDetail{
        uint24 id;
        string firstName;
        string lastName;
        string district;
        string contact;
        uint24 postCode;
        bool isExist;
        //define all the properties that a user have
        uint number;
        uint24 token;
        bytes32[] proL;
    }



    struct property{
        string district;
        string city;
        uint24 pID;
        uint24 pType;
        uint24 pArea;
        bool isExist;
        bool available;
        uint percentLeft;
        address payable[] owners;
        mapping(address =>uint24)OwnersOwn;
    }


    mapping (address  => userDetail)  users;

    mapping (bytes32 => property)  properties;


  
    uint256 totalProperty=0;
    uint24[]   userL;
    bytes32[]   propertyL;
    address payable public authority ; 

    //the authority,e.g. government,have the ability the create the contract
    constructor() public {
        authority = payable(msg.sender);
    }



    function AddUser(address payable add,string memory firstname1, string memory lastname1, string memory district1, string memory contact1, uint24 postcode1, uint24 uid) public{
        require(msg.sender == authority, "no rights");

        require(users[add].isExist == false, "User already exist");

        users[add].firstName = firstname1;
        users[add].lastName = lastname1;
        users[add].district = district1;
        users[add].contact = contact1;
        users[add].postCode = postcode1;
        users[add].isExist = true;
        users[add].number=0;
        users[add].id=uid;
        users[add].token=0;
        userL.push(uid);
    }

    function getUser(address uid1) public view returns(string memory firstname1, string memory lastname1, string memory district1, string memory contact1, uint24 postCode1, bytes32[] memory propertyL1,uint24 id1,uint number1,uint24 token){
        require(users[uid1].isExist == true, "User Doesn't exist");
        firstname1 = users[uid1].firstName;
        lastname1 = users[uid1].lastName;
        district1 = users[uid1].district;
        contact1 = users[uid1].contact;
        postCode1 = users[uid1].postCode;
        propertyL1 = users[uid1].proL;
        id1=users[uid1].id;
        number1=users[uid1].number;
        propertyL1=users[uid1].proL;
        token=users[uid1].token;
    }
    function deposit(address uid,uint24 amount)public{
        require(msg.sender == authority, "no rights");
        users[uid].token+=amount;


    }

    function addProperty(uint24 p,string memory district1, string memory city1, uint24 pType1, uint24 pArea1) public{
        require(msg.sender == authority, "no rights");
        bytes32 pid1=keccak256(abi.encodePacked(p, block.timestamp));
        require(properties[pid1].isExist != true, "Property already exsits");

        properties[pid1].district = district1;
        properties[pid1].city = city1;
        properties[pid1].pID = p;
        properties[pid1].pType = pType1;
        properties[pid1].pArea = pArea1;
        properties[pid1].isExist = true;
        properties[pid1].available=false;
        properties[pid1].percentLeft=100;
        propertyL.push(pid1);
        totalProperty+=1;

    }
    function addUserOwned(address payable uid, bytes32 p,uint24 percent) public{
        require(msg.sender == authority, "no rights");
        require(properties[p].percentLeft>=percent, "not enough land to add");
        users[uid].number ++;
        for(uint i = 0; i<users[uid].proL.length; i++){
            if(p==users[uid].proL[i]){
                break;
            }else{
                if(i==users[uid].proL.length){
                    users[uid].proL.push(p);
                    users[uid].number+=1; }
            }}

        for(uint i = 0; i<properties[p].owners.length; i++){
            if(uid==properties[p].owners[i]){
                properties[p].OwnersOwn[uid]+=percent;
                properties[p].percentLeft-=percent;

            }else{
                if(i==properties[p].owners.length-1){
                properties[p].owners.push(uid);
                properties[p].OwnersOwn[uid]=percent;
                properties[p].percentLeft-=percent;
                }
            }}
    }
    function getPropertyByte(uint24 p) public view returns(bytes32 pid){
        return propertyL[p];
    }

    function getProperty(bytes32 pid1) public view returns(string memory district1, string memory city1, uint24 pType1, uint24 pArea1,bool available){
        require(properties[pid1].isExist == true, "Property doesn't exist");
        district1 = properties[pid1].district;
        city1 = properties[pid1].city;
        pType1 = properties[pid1].pType;
        pArea1 = properties[pid1].pArea;
        available=properties[pid1].available;
        
    }


    function SetAvailable(bytes32 p)public{
        require(properties[p].isExist == true, "property doesn't exist");


        for(uint i = 0; i<users[msg.sender].proL.length; i++){
            if(users[msg.sender].proL[i]==p){
                properties[p].available=true;
            
            }else{
                if(i==users[msg.sender].proL.length){
                    revert("you don't have the property");
                }
            }

        }}

    function buyProperty(address payable toUser,bytes32 property1,address payable fromUser,uint24 proportion,uint24 value,uint24 tax)public payable{
        require(msg.sender == authority, "no rights");
        require(properties[property1].available == true,"property not available");
        require(value>=users[msg.sender].token,"no enough monery");
        for(uint i=0;i<users[fromUser].proL.length;i++){
            if(users[fromUser].proL[i]==property1){
                users[fromUser].token+=value;
                users[msg.sender].token-=value;
                PayTax(tax);
                removeOwnership(fromUser,property1,proportion);
                addUserOwned(toUser,property1,proportion);
                properties[property1].available=false;
            }else{
                if(i==users[fromUser].proL.length-1){
                    revert( "the user you bought from doesn't have the property" );
                }
            }
        }
    }


    function removeOwnership(address payable user1,bytes32 property1,uint24 proportion)private{
        if(properties[property1].OwnersOwn[user1]<proportion){
            revert( "not enough land to buy");
        }else if(properties[property1].OwnersOwn[user1]==proportion){
            delete properties[property1].OwnersOwn[user1];
            properties[property1].percentLeft+=proportion;
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
            properties[property1 ].percentLeft+=proportion;
            properties[property1].OwnersOwn[user1]-=proportion;
        }
    }



    function PayTax(uint24 value) public{
        authority.transfer(value);

    }

    


   

}