pragma solidity ^0.4.24;

import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC20/IERC20.sol';
import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC20/ERC20.sol';

contract VoteToken is ERC20 {
    
    function requestToken(address _requester) internal {
        require(balanceOf(_requester) == 0);
        _mint(address(this), 1);
        _requester.transfer(1);
    }
}

contract CommitedPromise is VoteToken, Ownable {
    
    address public politicanAddress;
    address public promiseAddress;
    address public oracleAddress;
    mapping (address => bool) voters;
    
    event pledgeSupported(address indexed voter, address indexed politicanAddress);
    
    constructor(address _politicanAddress, address _promiseAddress, address _oracleAddress) public {
        politicanAddress = _politicanAddress;
        promiseAddress = _promiseAddress;
        oracleAddress = _oracleAddress;
    }
    
    function supportPledge() external {
        require(voters[msg.sender] == false);
        require(balanceOf(msg.sender) == 0);
        requestToken(msg.sender);
        voters[msg.sender] = true;
        emit pledgeSupported(msg.sender, politicanAddress);
    }
}