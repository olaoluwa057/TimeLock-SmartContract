pragma solidity >=0.0.6 <=0.8.0; 

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';


contract Timewallet{
    

    
    mapping (address => user) users;
    mapping(address => uint256) lockTime;
    mapping(address => uint256) tokenlockTime;

    
    
    
    struct user{
        address userAddress;
        string firstName;
        string lastName;
        uint256  userWeiBalance;
        uint256 userTokenBalance;
        uint256 createdTime;
        bool doesExist ; 
    }
   
                
        
        
    
    
        
        
        function createUser (string memory _firstName, string  memory _lastName ) public returns  (string memory, string memory, address){
            users[msg.sender] = user(msg.sender,_firstName,_lastName,0,0,0, true);
            return (_firstName,_lastName, msg.sender);
            
        }
        
        function deposit (uint256 _amount, uint256 _lockTime) public payable returns ( uint256, uint256) {
            require ( _amount == msg.value,  "DepositEther:Amount sent does not equal amount entered");
            require(users[msg.sender].doesExist = true, 'You need to Create user before depositing');
            users[msg.sender].userWeiBalance += _amount;
            lockTime[msg.sender] = _lockTime;
            users[msg.sender].createdTime = block.timestamp;
           return( users[msg.sender].userWeiBalance, lockTime[msg.sender]);
            
        }
        function withdraw (uint256 _amount) public returns (uint256){
            require(users[msg.sender].doesExist = true, 'You have to have an account first');
             require(block.timestamp >= users[msg.sender].createdTime + lockTime[msg.sender], 'too early');
             users[msg.sender].userWeiBalance -= _amount;
            payable (msg.sender).transfer(_amount);
            return users[msg.sender].userWeiBalance;
        }
        function tokenDeposit (address _tokenAddress, uint256 _amount, uint256 _tokenLockTime) public returns (uint256,uint256){
                IERC20 _j = IERC20( _tokenAddress );
                  require(
                _j.allowance(msg.sender, address(this)) >= _amount,
                "TokenDeposit: you have not approved Timewallet to spend one or more of your tokens"
            );
               _j.transferFrom(msg.sender, address(this), _amount);
               users[msg.sender].userTokenBalance += _amount;
               tokenlockTime[msg.sender] = _tokenLockTime;
                 users[msg.sender].createdTime = block.timestamp;
               return( users[msg.sender].userTokenBalance, tokenlockTime[msg.sender]);
        }
        
        function withdrawToken ( address _token, uint256 _amount) public {
              require(users[msg.sender].doesExist = true, 'You have to have an account first');
              require(block.timestamp >= users[msg.sender].createdTime + tokenlockTime[msg.sender], 'too early');
               if(_token == address(0)) { 
                 payable (msg.sender).transfer(_amount);
                 } else {
                 IERC20(_token).transfer(msg.sender, _amount);
              }
               users[msg.sender].userTokenBalance -= _amount;
        }
            
        
        function contractBalance () public view returns (uint256){
            
            return address(this).balance;
        }
}
