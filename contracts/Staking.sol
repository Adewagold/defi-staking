// SPDX-License-Identifier: MIT
// stake: Lock tokens into our smart contract
// withdraw: unlock tokens and pull out of the contract
// claimReward: users get their reward tokens
// what's a good reward mechanism?
// what's some good reward math?

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking{

    IERC20 public s_stakingToken;

    //someone's address -> how much they staked
    mapping(address=>uint256) public s_balances;

    uint256 public s_totalSupply;

    constructor(address stakingToken){
        s_stakingToken = IERC20(stakingToken);
    }
    //do we allow any tokens -not allow any token,
    // Chainlink stuff to convert prices between tokens.
    // or just a specific tokens?
    error Staking__TransferFailed();

    function stake(uint256 amount) external{
        //keep tract of how much this user has staked
        //keep track of how much token we have total
        //transfer the tokens to this contract
        s_balances[msg.sender] = s_balances[msg.sender] + amount;
        s_totalSupply = s_totalSupply + amount;
        //emit an event
        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
        if(!success){
            revert Staking__TransferFailed();
        }
    }

    function withdraw(uint256 amount) external{
        s_balances[msg.sender] = s_balances[msg.sender] - amount;
        s_totalSupply = s_totalSupply - amount;
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if(!success){
            revert Staking__TransferFailed();
        }
    }

}