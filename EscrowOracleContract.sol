pragma solidity ^0.4.24;

import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol';
// import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "./CommitedPromise.sol";

// contract EscrowOracleContract is usingOraclize {
contract EscrowOracleContract {

	mapping (address => uint) public pledgeVoterPositiveBets;
	address[] public positiveBetsAddress;
	mapping (address => uint) public positiveBetsAddressIndex; 

	mapping (address => uint) public pledgeVoterNegativeBets;
	address[] public negativeBetsAddress;
	mapping (address => uint) public negativeBetsAddressIndex; 
	
	uint public positiveBetsSummary;
	uint public negativeBetsSummary;
	
	uint public politicanReward;
	
	uint public politicanRewardFactorNominator = 1;
	uint public politicanRewardFactorDenominator = 10;

    uint public oracleReward;
    
	uint public oracleRewardFactorNominator = 1;
	uint public oracleRewardFactorDenominator = 200;

	mapping (address => address) public pledgeVoterChosenOracles;
	CommitedPromise public commitedPromise;
	
	constructor(address _promiseTokenAddress) public {
	    commitedPromise = CommitedPromise(_promiseTokenAddress);
	}
	
// 	function resolvePledge(address _pledge) external payable {
// 	    require(true);
// 	}
	
// 	function __callback(bytes32 myid, string result) {
	    
// 	}
	
	function () public payable {
	    if(commitedPromise.balanceOf(msg.sender) != 0) {
	        if(pledgeVoterPositiveBets[msg.sender] == 0) {
	            positiveBetsAddress.push(msg.sender);
	            positiveBetsAddressIndex[msg.sender] = positiveBetsAddress.length-1;
	        }
	        pledgeVoterPositiveBets[msg.sender] += msg.value;
	        positiveBetsSummary += msg.value;
	    } else {
	        if(pledgeVoterNegativeBets[msg.sender] == 0) {
	            negativeBetsAddress.push(msg.sender);
	            negativeBetsAddressIndex[msg.sender] = negativeBetsAddress.length-1;
	        }
	        pledgeVoterNegativeBets[msg.sender] += msg.value;
	        negativeBetsSummary += msg.value;
	    }
	}
	
	function applyOracleResult(bool result) external {
	    uint i = 0;
	    uint actualBalance;
	    uint singlePoliticanReward = 0;
	    uint singleOracleReward = 0;
	    
	    if(result) {
	        for(i = 0; i < positiveBetsAddress.length; i++) {
	            actualBalance = pledgeVoterPositiveBets[positiveBetsAddress[i]];
	            pledgeVoterPositiveBets[positiveBetsAddress[i]] = 
	            actualBalance  = SafeMath.div(
	                SafeMath.mul(actualBalance, positiveBetsSummary+negativeBetsSummary), positiveBetsSummary);
	            
	            singlePoliticanReward = SafeMath.div(
	                SafeMath.mul(actualBalance, politicanRewardFactorNominator), politicanRewardFactorDenominator);
	            politicanReward += (singlePoliticanReward);
	            
	            singleOracleReward = SafeMath.div(
	                SafeMath.mul(actualBalance, oracleRewardFactorNominator), oracleRewardFactorDenominator);
	            oracleReward += (singleOracleReward);
	            
	            actualBalance -= singlePoliticanReward;
	            pledgeVoterPositiveBets[positiveBetsAddress[i]] = actualBalance;
	            positiveBetsAddress[i].transfer(pledgeVoterPositiveBets[positiveBetsAddress[i]]);
	        }
	        commitedPromise.politicanAddress().transfer(politicanReward);
	        for(i = 0; i < negativeBetsAddress.length; i++) {
	            pledgeVoterNegativeBets[negativeBetsAddress[i]] = 0;
	        }
	    } else {
	        for(i = 0; i < negativeBetsAddress.length; i++) {
	            actualBalance = pledgeVoterNegativeBets[negativeBetsAddress[i]];
	            actualBalance = SafeMath.div(
	                SafeMath.mul(actualBalance, negativeBetsSummary+positiveBetsSummary), negativeBetsSummary);

	            singleOracleReward = SafeMath.div(
	                SafeMath.mul(actualBalance, oracleRewardFactorNominator), oracleRewardFactorDenominator);
	            oracleReward += (singleOracleReward);

	            pledgeVoterNegativeBets[negativeBetsAddress[i]] = actualBalance;
	            negativeBetsAddress[i].transfer(pledgeVoterNegativeBets[negativeBetsAddress[i]]);
	        }
	        for(i = 0; i < positiveBetsAddress.length; i++) {
	            pledgeVoterPositiveBets[positiveBetsAddress[i]] = 0;
	        }
	    }
	    commitedPromise.oracleAddress().transfer(oracleReward);
	}
	

}