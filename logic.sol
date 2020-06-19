pragma solidity ^0.6.10;

contract microchits {
    
    //address public owner;
    
    /*
    constructor() public {
        owner = msg.sender;
    }
    */
    
  struct chitsData {
      string poolName;
      uint poolId;
      uint availableSlots;
      address[] members;
      address[] memberRequests;
      uint startedOn;
      uint endingOn;
      uint poolAmount;
      address owner;
      uint period;
      uint poolSize;
      bool isExists;
      bool isEnded;
      uint amountAvailable;
      uint aph; //amount per head
  }
  struct memberData {
      string name;
      string memberAddress;
      string aadhar;
      bool isCreated;
      string mobile;
      address addr;
  }
  struct poolMemberData {
      address addr;
      bool isJoined;
      bool isRequested;
  }
  mapping(uint => chitsData) public chitsPool;
  mapping(address=>mapping(uint=>poolMemberData))private poolMembers;
  mapping(address => memberData) public members;
  
  function signUp(string memory _name, string memory _memberAddress, string memory _aadhar, string memory _mobile) public payable {
         require(!members[msg.sender].isCreated, 'Account is already Registered with this address');
         
         members[msg.sender].name = _name;
         members[msg.sender].memberAddress = _memberAddress;
         members[msg.sender].aadhar = _aadhar;
         members[msg.sender].isCreated = true;
         members[msg.sender].mobile= _mobile;
         members[msg.sender].addr= msg.sender;
     }
  function createPool(string memory _poolName,uint _poolAmount,uint _period, uint _poolSize) public payable returns (uint){
      require(!members[msg.sender].isCreated, 'You mustbe registered before creating pool');
      
         chitsPool[now].poolName = _poolName;
         chitsPool[now].poolId = now;
          chitsPool[now].availableSlots = _poolSize;
         chitsPool[now].startedOn = now;
         chitsPool[now].endingOn = now + _period;
         chitsPool[now].poolAmount = _poolAmount;
         chitsPool[now].period = _period;
         chitsPool[now].poolSize = _poolSize;
         chitsPool[now].owner = msg.sender;
         chitsPool[now].isExists = true;
         chitsPool[now].aph = _poolAmount/_poolSize;
         return now;
         
     }
     
     function joinPool(uint _poolId) public payable {
      require(members[msg.sender].isCreated,'Joining member mustbe registred first before joining pool');
      require(chitsPool[_poolId].isExists, 'Pool with this Id doesnot exist');
      require(chitsPool[_poolId].availableSlots >=1, 'This Pool is filled up');
      require(!chitsPool[_poolId].isEnded, 'This Pool is Ended');
      require(!poolMembers[msg.sender][_poolId].isRequested,'You are already requested to join in this pool. Wait till owner approves');
      require(!poolMembers[msg.sender][_poolId].isJoined,'You are already requested to join in this pool. Wait till owner approves');
      
      chitsPool[_poolId].memberRequests.push(msg.sender);
      poolMembers[msg.sender][_poolId].isRequested = true;
      
         
     }
     
     function approveJoin(uint _poolId, address _member) public payable {
         
      require(members[_member].isCreated,'Joining member mustbe registred first before joining pool');
      require(chitsPool[_poolId].owner==msg.sender,'You are not the owner of this pool');
      require(poolMembers[_member][_poolId].isRequested,'Member must be requested before to join in this pool');
       require(!poolMembers[_member][_poolId].isJoined,'Member already joined in this pool');
      require(chitsPool[_poolId].isExists, 'Pool with this Id doesnot exist');
      require(chitsPool[_poolId].availableSlots >=1, 'This Pool is filled up');
      require(!chitsPool[_poolId].isEnded, 'This Pool is Ended');
   
      chitsPool[_poolId].members.push(_member);
         
     }
}