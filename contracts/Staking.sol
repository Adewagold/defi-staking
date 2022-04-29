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
    // a mapping of how much each address has been paid;
    mapping(address => uint256) public s_userRewardPerTokenPaid;
    // a mapping of how much each asset has
    mapping(address=> uint256) public rewards;

    uint256 public s_totalSupply;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdateTime;
    uint256 public constant REWARD_RATE = 100;


    modifier updateReward(address account){
        // how much reward per token?
        // last timestamp
        // 12 - 1, user earned X tokens
        s_rewardPerTokenStored = rewardPerToken();
        s_rewards[accounts] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
    }

    function earned(address account) public view returns(uint256){
        uint356 currentBalance = s_balances[account];
        //how much they have been paid already
        uint256 amountPaid = s_userRewardPerTokenPaid[account];
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = s_rewards[account];

        ((currentBalance * (currentRewardPerToken - amountPaid)) / 1e18) + pastRewards;
    }

    constructor(address stakingToken){
        s_stakingToken = IERC20(stakingToken);
    }
    //do we allow any tokens -not allow any token,
    // Chainlink stuff to convert prices between tokens.
    // or just a specific tokens?
    error Staking__TransferFailed();

    function stake(uint256 amount) external updateReward(msg.sender){
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

    function withdraw(uint256 amount) external updateReward(msg.sender){
        s_balances[msg.sender] = s_balances[msg.sender] - amount;
        s_totalSupply = s_totalSupply - amount;
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if(!success){
            revert Staking__TransferFailed();
        }
    }

    function claimReward() external updateReward(msg.sender){
        // How much reward do they get?

        // The contract is going to emit X tokens per second
        // And disperse them to all token stakers
        // 100 tokens / second
        // staked:  50 staked tokens, 20 staked tokens, 30 staked tokens
        // rewards: 50 reward tokens, 20 reward tokens, 30 reward tokens

        // staked: 100, 50, 20, 30 (total = 200)
        // rewards: 50, 25, 10, 15 // The more people save the lesser the reward.

        // why not 1 to 1 - bankrupt your protocol?
        // 5 days, 1 person had 100 token staked = reward 500 tokens
        // 6 seconds, 2 person have 100 tokens staked each:
        //      person 1: 550
        //      person 2: 50
        // ok between seconds 1 and 5, person 1 got 500 tokens
        // ok at seconds 6 on, person 1 gets 50 tokens now

        // 100 tokens / send
        // Time = 0 
        // Person A: 80 staked = 80/100 = 80% of 100
        // Person B: 20 staked

        //Time = 1
        // PA: 80, Earned: 80, withdrawn: 0
        // PB: 20, Earned: 20, withdrawn: 0

        //Time = 2
        // PA: 80, Earned: 160, withdrawn: 0
        // PB: 20, Earned: 40, withdrawn: 0

        //Time = 3
        // PA: 80, Earned: 240, withdrawn: 0
        // PB: 20, Earned: 60, withdrawn: 0

        //New person enters
        //Time = 4
        //Time = 3
        // PA: 80, Earned: 240 + (80/200) = 0.4 x 100 = 40, withdrawn: 0
        // PB: 20, Earned: 60 + (20/200) = 0.1 x 100 = 10, withdrawn: 0
        // PC: 100, Earned: 60 + (100/200) = 0.5 x 100 = 50, withdrawn: 0
    }

    function rewardPerToken() public view returns(uint256){
        if(s_totalSupply == 0){
            return s_rewardPerTokenStored;
        }
        // How long has it been since the last stake or withdrawal.
        return s_rewardPerTokenStored + (((block.timestamp - s_lastUpdateTime ) * REWARD_RATE * 1e18) / s_totalSupply)
    }
}