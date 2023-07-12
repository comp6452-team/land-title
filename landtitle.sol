// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract landtitle {


    struct userDetail{
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


//store all the tx history related to a property
    struct txRecord{
        uint24 txId;
        bytes32 txHash;
        uint24 percent;
        bytes32 buyFrom;
        bytes32[] sellTo;
        uint24[] owners;
        uint24[] proportionL;
        bool isExist;
    }

    struct property{
        bytes32 district;
        bytes32 city;
        uint24 pID;
        uint24 pType;
        uint24 pArea;
        bool isExist;
        bool available;
    }


    mapping (uint24 => userDetail)  users;

    mapping (bytes32 => property)  properties;

    mapping (bytes32 => txRecord)  records;

    uint24 public numTxs = 0;
    uint[]   userL;
    bytes32[]   propertyL;
    bytes32[]   recordL;


//the authority,e.g. government,have the ability the create the contract
    constructor() public {
        authority = msg.sender;
    }




    function addNewTitle(uint24 pid, uint[] user, uint16[] proportion) public{
        require(msg.sender == authority, "no rights");
        require(properties[pid].isExist == true, "property doesn't exist");
        bytes32 xHash = keccak256((abi.encodePacked(pid, block.timestamp)));
        require(records[xHash].isExist != true, "Transaction already exists");
        for(uint i = 0; i<user.length; i++){
            require(users[user[i]].isExist == true, "User doesn't exist");
        }

        for(uint i = 0; i<user.length; i++){
            addUserTitle(user[i], xHash);
        }
        
        numTxs+=1;

        records[xHash].txId =numTxs;
        records[xHash].isExist = true;
        records[xHash].proportionL = proportion;
        records[xHash].owners = user;

        recordL.push(xHash);
    }


    function updateTX(uint24 pid, bytes32 from, uint24[] newOwner,uint24[] sellUser, uint24[] percentL) public{
        require(msg.sender == authority, "no rights");
        require(properties[pid].isExist == true, "property doesn't exist");

        bytes32 xHash = keccak256((abi.encodePacked(pid, block.timestamp)));

        require(records[xHash].isExist != true, "Transaction already exists");
        require(records[from].isExist, "no previous transaction");
        require(records[from].percent >= percent, "not enough land");
        for(uint i = 0; i<newOwner.length; i++){
            require(users[newOwner[i]].isExist == true, "User doesn't exist");
        }
        numTxs+=1;
        records[xHash].txId =numTxs;
        records[xHash].isExist = true;
        records[xHash].proportionL = percentL;
        records[xHash].owners = user;
        records[xhash].buyFrom = from;
        records[xhash].sellTo = sellUser;


        for(uint i = 0; i<user.length; i++){
            addUserTitle(user[i], xHash);
        }

        recordL.push(xHash);
    }
    function addUserTitle(uint user, bytes32 tHash) public{
        userOwnedMapping[user].number +=1;
        userOwnedMapping[user].push(thash);
    }

    function getTx(uint24 id) public view returns(bytes32 tHash,uint24 txId1,bytes32 buyFrom1,bytes32[] sellTo1,uint24[] owners1,bytes32[] proportionL1,uint24 percent1){
        tHash=recordL[id];
        require(records[tHash].isExist == true, "Record doesn't exist");
        txId1 = records[tHash].txId;
        buyFrom1 = records[tHash].buyFrom;
        sellTo1 = records[tHash].sellTo;
        owners1 = records[tHash].owners;
        proportionL1 = records[tHash].proportionL;
        percent1=records[tHash].percent;
    }

    function AddUser(string firstname, string lastname1, string district1, string contact1, uint24 postcode, uint24 uid) public{
        require(msg.sender == authority, "no rights");

        require(users[uid].isExist == false, "User already exist");

        users[uid].firstName = bytes(firstname1);
        users[uid].lastName = bytes(lastname1);
        users[uid].district = bytes(district1);
        users[uid].contact = bytes(contact1);
        users[uid].postCode = postcode1;
        users[uid].isExist = true;
        users[uid].number=0;

        userL.push(uid);
    }

    function getUser(uint uid1) public view returns(bytes32 firstname1, bytes32 lastname1, bytes32 district1, bytes32 contact1, uint24 postCode1, bytes32[] propertyL1 ){
        require(users[uid1].isExist == true, "User Doesn't exist");
        firstname1 = users[uid1].firstName;
        lastname1 = users[uid1].lastName;
        district1 = users[uid1].district;
        contact1 = users[uid1].contact;
        postCode1 = users[uid1].postCode;
        propertyL1 = users[uid1].proL;
    }


    function addProperty(uint24 p,string district1, string city1, uint24 pType1, uint24 pArea1) public{
        require(msg.sender == authority, "no rights");
        pid=keccak256(abi.encodePacked(p, block.timestamp));
        require(properties[pid1].isExist != true, "Property already exsits");

        properties[pid1].district = bytes (district1);
        properties[pid1].city = bytes (city1);
        properties[pid1].pID = p;
        properties[pid1].pType = pType1;
        properties[pid1].pArea = pArea1;
        properties[pid1].isExist = true;
        properties[pid1].available=false;
        propertyL.push(pid1);

    }
    function addUserOwned(uint uid, bytes32 p) public{
        users[uid].number ++;
        users[uid].proL.push(p);
    }

    function getProperty(bytes32 pid1) public view returns(bytes32 district1, bytes32 city1, uint24 pType1, uint24 pArea1,bool available){
        require(properties[pid1].isExist == true, "Property doesn't exist");
        district1 = properties[pid1].district;
        city1 = properties[pid1].city;
        pType1 = properties[pid1].pType;
        pArea1 = properties[pid1].pArea;
        available=properties[pid1].available;
    }
    function propertyAvailable(bytes32 p)public{
        require(properties[p].isExist == true, "property doesn't exist");

        for(uint i = 0; i<msg.sender.proL.length; i++){
            if(msg.sender.propertyL[i]==property1){
                properties[p].available=true;
                break;
            }else{
                if(i==msg.sender.propertyL.length-1){
                    revert("you have no rights");
                }
            }

    }}

    function buyProperty(bytes32 property1,uint24 fromUser,uint proportion)public payable{
        require(properties[property1].available == true,"property not available");

        users[fromUser].transfer(msg.value);
        removeOwnership(fromUser,property1);
        msg.sender.propertyL.push(property1);
        properties[property1].available=false;


    }

    function removeOwnership(uint24 id,bytes32 p)private{
        x=findAssert(p,id);
        delete users[id].proL[x];
        users[id].proL.length--;
    }

    function findAssert(bytes32 id,uint24 user1)public view returns(bytes32){

        for(uint i=0;i<users[user1].proL.length;i++){
            if(users[user1].prol[i] == id)
                return i;
        }
        return i;
    }
}


