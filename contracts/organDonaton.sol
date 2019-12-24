pragma solidity ^0.5.7;

contract OrganDonation {
    
  struct Organ{
     address owner;
     bytes32 bloodGroup;
     string description;
     bool isAvailable;
  }
 
 uint256 public organId=1;
 mapping(uint256 => Organ) public organs;
 
 struct Request{
     address owner;
     bytes32 bloodGroup;
     string description;
     bool isRequested;
  }
  
  uint256 public requestId;
  mapping(uint256 => Request) public requestList;
  
 
  struct Transaction{
    uint256 organId;
    address receiver;
    
  }

  uint256 public transactionId;
  mapping(uint256 => Transaction) public transactions;

  struct User {
    string name;
    string age;
    bytes32 bloodGroup;
    string mobileNumber;
    string userName;
    string password;
    uint index;
    uint256[] receiveList;
  }

  address public userAddress;
  mapping(address => User) public users;

  event NewDonaton (
    uint256 indexed organId,
    bytes32 indexed bloodGroup,
    string indexed description
  );

  event NewReceived (
    uint256 indexed organId,
    bytes32 indexed bloodGroup,
    string indexed name
  );

 
  function donateOrgan(string memory bloodGroup, string memory description) public {
    Organ memory organ = Organ(msg.sender, stringToBytes32(bloodGroup), description,true);
    organs[organId] = organ;
    emit NewDonaton(organId++,stringToBytes32(bloodGroup),description);
  }
  
  function requestOrgan(string memory bloodGroup,string memory description)public{
      Request memory request = Request(msg.sender,stringToBytes32(bloodGroup),description,true);
      requestList[requestId++] = request;
  }

  function receiveOrgan(uint256 _organId) public {
    Organ storage organ = organs[_organId];
    User storage user = users[msg.sender];
    
    require(
        organ.bloodGroup == user.bloodGroup,
      "blood group doesnot match"
    );
    
    require(user.index<2,"you cannot receive more than 2 organs");
    

   organ.isAvailable = false;
   Transaction memory transaction = Transaction(_organId,msg.sender);
   transactions[transactionId] = transaction;
   transactionId++;
   user.receiveList[user.index++] = _organId;
    emit NewReceived(_organId,organ.bloodGroup,user.name);
  }
  

  function makeOrganUnavailable(uint256 _organId) public {
    require(
      organs[_organId].owner == msg.sender,
      "Not authorized"
    );
    
    organs[_organId].isAvailable = false;
  }
  
  function registerUser(string memory name,string memory age,string memory bloodGroup,string memory mobileNumber,string memory userName,string memory password)public {
    User memory user = User(name,age,stringToBytes32(bloodGroup),mobileNumber,userName,password,0,new uint256 [](2));
    users[msg.sender] = user;
  }
  
  function stringToBytes32(string memory source)internal pure returns (bytes32 result){
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
  }
}