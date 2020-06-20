/*
 * SPDX-License-Identifier: Apache-2.0
 * Licensed to @Author: Salman Dabbakuti(https://github.com/Salmandabbakuti)
 * Permissioned Use Only. Reproduction of this code is strictly prohibited.
 * See the License for the specific language governing permissions and limitations under the License.
 */

pragma solidity ^0.6.10;

contract blockchits {
  
    struct chitsData {
      string poolName;
      uint poolId;
      uint availableSlots; 
      address[] members;
      address[] memberRequests; //member join requests
      address[] poolEndRequests;
      uint startedOn;
      uint endingOn;
      uint poolAmount;
      address owner;
      uint period; //period in months
      uint poolSize; //members capacity
      uint amountAvailable;
      address winnerOfMonth;
      uint latestDrawOn;
      uint aph; //amount per head
  }
  
  struct poolStatus {
      bool isExists;
      bool isEnded;
      string poolName;
      uint poolId;
      
  }
  struct memberData {
      string name;
      string memberAddress; //physical address
      string aadhar;
      bool isCreated;
      string mobile;
      address addr; //ethereum account address
      uint[] createdPools;
      uint[] joinedPools;
  }
  struct poolMemberData {
      address addr;
      bool isJoined;
      bool isRequested; //is submitted join request
      bool isRequestedEnd; // is submitted pool end request
      bool isDrawn;
      uint[] payments; //all payments timestamps
      uint totalPaid;
  }
  mapping(uint => chitsData) private chitsPool;
  mapping(uint => poolStatus) public chitsPoolStatus;
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
      require(members[msg.sender].isCreated, 'You mustbe registered before creating pool');
      
         chitsPool[now].poolName = _poolName;
         chitsPool[now].poolId = now;
         chitsPool[now].availableSlots = _poolSize-1; //owner slot will be filled up while creation
         chitsPool[now].startedOn = now;
         chitsPool[now].endingOn = now + _period*2592000; //period in seconds compatible for 'now' 1 month = 2592000 seconds
         chitsPool[now].poolAmount = _poolAmount;
         chitsPool[now].period = _period; //in months
         chitsPool[now].poolSize = _poolSize;
         chitsPool[now].owner = msg.sender;
         chitsPoolStatus[now].isExists = true;
         chitsPoolStatus[now].poolName = _poolName;
         chitsPoolStatus[now].poolId = now;
         chitsPool[now].aph = (_poolAmount/_poolSize)/_period;
         chitsPool[now].members.push(msg.sender); //owner can join pool by default
         poolMembers[msg.sender][now].isJoined = true;
         members[msg.sender].createdPools.push(now);
         members[msg.sender].joinedPools.push(now);
         return now;
         
     }
     
     function joinPool(uint _poolId) public payable {
      require(members[msg.sender].isCreated,'Joining member mustbe registred first before joining pool');
      require(chitsPoolStatus[_poolId].isExists, 'Pool with this Id doesnot exist');
      require(chitsPool[_poolId].availableSlots >=1, 'This Pool is filled up');
      require(!chitsPoolStatus[_poolId].isEnded, 'This Pool is Ended');
      require(!poolMembers[msg.sender][_poolId].isRequested,'You are already requested to join in this pool. Wait till owner approves');
      require(!poolMembers[msg.sender][_poolId].isJoined,'You are already joined this pool.');
      
      chitsPool[_poolId].memberRequests.push(msg.sender);
      poolMembers[msg.sender][_poolId].isRequested = true;
      
     }
     
     function approveJoin(uint _poolId, address _member) public payable {
         
      require(members[_member].isCreated,'Joining member mustbe registred first before joining pool');
      require(chitsPool[_poolId].owner==msg.sender,'You are not the owner of this pool');
      require(poolMembers[_member][_poolId].isRequested,'Member must be requested before to join in this pool');
       require(!poolMembers[_member][_poolId].isJoined,'Member already joined in this pool');
      require(chitsPoolStatus[_poolId].isExists, 'Pool with this Id doesnot exist');
      require(chitsPool[_poolId].availableSlots >=1, 'This Pool is filled up');
      require(!chitsPoolStatus[_poolId].isEnded, 'This Pool is Ended');
   
      chitsPool[_poolId].members.push(_member);
      poolMembers[_member][_poolId].isJoined = true;
      poolMembers[_member][_poolId].addr = _member;
      members[_member].joinedPools.push(_poolId);
      chitsPool[_poolId].availableSlots--;
     }
     
     function payAmount(uint _poolId) public payable {

      require(poolMembers[msg.sender][_poolId].isJoined,'You are not joined in this pool');
      require(chitsPoolStatus[_poolId].isExists, 'Pool with this Id doesnot exist');
      require(!chitsPoolStatus[_poolId].isEnded, 'This Pool is Ended');
      require(chitsPool[_poolId].aph == msg.value,'Amount must be equal to pool amount per head');
      require(poolMembers[msg.sender][_poolId].totalPaid < chitsPool[_poolId].poolAmount,'You have already paid all installments.');
      
      poolMembers[msg.sender][_poolId].payments.push(now);
      poolMembers[msg.sender][_poolId].totalPaid += msg.value;
      chitsPool[_poolId].amountAvailable += msg.value;
   
      
     }
     
     function endPool(uint _poolId) public payable {
         
      require(chitsPool[_poolId].owner == msg.sender, 'Only owner can end pool');
      require(!chitsPoolStatus[_poolId].isEnded, 'This Pool is already Ended');
      require(chitsPool[_poolId].poolEndRequests.length == chitsPool[_poolId].poolSize, 'All Pool members request are needed to end pool.');
     
      chitsPoolStatus[_poolId].isEnded = true;
     }
    
     function submitPoolEndRequest(uint _poolId) public payable {
         
      require(poolMembers[msg.sender][_poolId].isJoined, 'Only pool members can submit end request');
      require(!poolMembers[msg.sender][_poolId].isRequestedEnd, 'You are already subitted pool end request. No need to resubmit.');
      require(chitsPoolStatus[_poolId].isExists, 'Pool with this Id doesnot exist');
      require(!chitsPoolStatus[_poolId].isEnded, 'This Pool is already Ended');
      
      chitsPool[_poolId].poolEndRequests.push(msg.sender);
      poolMembers[msg.sender][_poolId].isRequestedEnd = true;
      
     }
    
    function drawChits(uint _poolId) public payable {
         
      require(poolMembers[msg.sender][_poolId].isJoined, 'Only pool members can draw chits');
      require(chitsPoolStatus[_poolId].isExists, 'Pool with this Id doesnot exist');
      require(!chitsPoolStatus[_poolId].isEnded, 'This Pool is already Ended');
      require(chitsPool[_poolId].amountAvailable >= chitsPool[_poolId].poolAmount, 'All members have not deposited amounts yet.');
      require(!poolMembers[msg.sender][_poolId].isDrawn, 'You have already drawn chits under this pool.');

      chitsPool[_poolId].winnerOfMonth == msg.sender;
      chitsPool[_poolId].latestDrawOn == now;
      poolMembers[msg.sender][_poolId].isDrawn = true; 
      msg.sender.transfer(chitsPool[_poolId].poolAmount);
      chitsPool[_poolId].amountAvailable -= chitsPool[_poolId].poolAmount;
     }
     
     function getPoolInfo(uint _poolId) public view returns(string memory, uint, uint, uint, address, uint, uint){
         return (
       chitsPool[_poolId].poolName,
       chitsPool[_poolId].startedOn,
       chitsPool[_poolId].endingOn,
       chitsPool[_poolId].poolAmount,
       chitsPool[_poolId].owner,
       chitsPool[_poolId].poolSize,
       chitsPool[_poolId].aph
        //chitsPool[_poolId].poolId,
       //chitsPool[_poolId].amountAvailable,
       //chitsPool[_poolId].winnerOfMonth
      );
     }
     
     function getPoolStatus(uint _poolId) public view returns(string memory, uint, address, bool, bool, uint, address [] memory){
         require(poolMembers[msg.sender][_poolId].isJoined, 'Only Joined members can view pool status');
         return (
       chitsPool[_poolId].poolName,
       chitsPool[_poolId].amountAvailable,
       chitsPool[_poolId].winnerOfMonth,
       chitsPoolStatus[_poolId].isExists,
       chitsPoolStatus[_poolId].isEnded,
       chitsPool[_poolId].latestDrawOn,
       chitsPool[_poolId].members
       //chitsPool[_poolId].availableSlots
       //chitsPool[_poolId].aph
       //chitsPool[_poolId].poolId,
       //chitsPool[_poolId].startedOn,
       //chitsPool[_poolId].endingOn,
       //chitsPool[_poolId].poolAmount,
       //chitsPool[_poolId].owner,
       //chitsPool[_poolId].poolSize
      );
         
         
     }
     
     function getPoolRequests(uint _poolId) public view returns(string memory, address [] memory, address [] memory){
          require(chitsPool[_poolId].owner == msg.sender, 'Only pool owner can view pool requests.');
         return (
       chitsPool[_poolId].poolName,
       chitsPool[_poolId].memberRequests,
       chitsPool[_poolId].poolEndRequests
      );
     }
     
      function getPoolMemberInfo(uint _poolId, address _member) public view returns(string memory, uint [] memory, uint, bool, bool){
          require(chitsPool[_poolId].owner == msg.sender, 'Only pool owner can view pool member data');
          require(poolMembers[_member][_poolId].isJoined, 'Member is not part of this pool.');
         return (
       chitsPool[_poolId].poolName,
       poolMembers[_member][_poolId].payments,
       poolMembers[_member][_poolId].totalPaid,
       poolMembers[_member][_poolId].isDrawn,
       poolMembers[_member][_poolId].isRequestedEnd
      );
     }
     
     function getMyPools() public view returns(uint [] memory, uint [] memory){
          require(members[msg.sender].isCreated , 'You are not registered on this platform yet.');
         return (
             members[msg.sender].createdPools,
             members[msg.sender].joinedPools
       
      );
     }
    
}
