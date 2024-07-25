// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YieldFarming is ERC20{
    struct Pool {
        uint min_deposit;
        uint max_amount;
        uint reward_time;
        uint yield_percent;
        uint pool_balance;

        mapping(address => uint[2]) deposits;
        address[] depositors;
    }

    address immutable public owner;

    Pool[] public pools;

    mapping(address => uint) public total_deposits;
    address[] public whales;
    mapping(address => uint) public rewards;

    constructor() ERC20("Test", "TKN") {
        owner = msg.sender;
    }

    function addPool(uint maxAmount, uint yieldPercent, uint minDeposit, uint rewardTime) public {
        unchecked {
            require(msg.sender == owner);
            require(minDeposit <= maxAmount);

            pools.push();
            uint idx = pools.length - 1;
            pools[idx].min_deposit = minDeposit;
            pools[idx].max_amount = maxAmount;
            pools[idx].reward_time = rewardTime;
            pools[idx].yield_percent = yieldPercent;
        }
    }

    function depositWei(uint poolId) public payable {
        unchecked {
            // check for poolId
            require(poolId < pools.length);
            // check for min_deposit
            require(msg.value >= pools[poolId].min_deposit);
            // check for max_amount
            require(pools[poolId].max_amount - pools[poolId].pool_balance >= msg.value);
            // msg.sender has not deposited in this pool
            require(pools[poolId].deposits[msg.sender][0] == 0);

            uint idx;
            uint len = pools[poolId].depositors.length;
            for (;idx < len; ++idx) {
                if (pools[poolId].depositors[idx] == msg.sender) {
                    break;
                }
            }
            
            if (idx == len) {
                pools[poolId].depositors.push(msg.sender);
            }


            pools[poolId].deposits[msg.sender][0] = msg.value;
            pools[poolId].deposits[msg.sender][1] = block.timestamp;
            pools[poolId].pool_balance += msg.value;

            total_deposits[msg.sender] += msg.value;
            if (total_deposits[msg.sender] >= 10000) {
                whales.push(msg.sender);
            }            
        }
    }

    function withdrawWei(uint poolId, uint amount) public {
        unchecked {
            require(pools[poolId].deposits[msg.sender][0] >= amount);

            pools[poolId].deposits[msg.sender][0] -= amount;
            pools[poolId].pool_balance -= amount;

            // reset the reward time if we withdraw everything
            if (pools[poolId].deposits[msg.sender][0] == 0) {
                pools[poolId].deposits[msg.sender][1] = block.timestamp;
            }

            _mint(msg.sender, amount);
         }
    }

    function claimRewards(uint poolId) public {
        unchecked {
            uint reward = checkClaimableRewards(poolId);

            require(reward > 0);

            // reset get reward time
            pools[poolId].deposits[msg.sender][1] = block.timestamp;
            // check if msg.sender is a whale
            if (total_deposits[msg.sender] >= 10000) {
                reward = reward * 120 / 100;
            }

            rewards[msg.sender] += reward;
            _mint(msg.sender, reward);
        }
    }

    function checkPoolDetails(uint poolId) public view returns (uint, uint, uint, uint) {
        unchecked {
            return (pools[poolId].max_amount, pools[poolId].yield_percent, pools[poolId].min_deposit, pools[poolId].reward_time);
        }
    }

    function checkUserDeposits(address user) public view returns (uint, uint) {
        unchecked {
            return (total_deposits[user], rewards[user]);
        }
    }

    function checkUserDepositInPool(uint poolId) public view returns (address[] memory, uint[] memory) {
        unchecked {

            uint idx;
            uint len = pools[poolId].depositors.length;
            uint[] memory z = new uint[](len);

            for (; idx < len; ++idx) {
                z[idx] = (pools[poolId].deposits[pools[poolId].depositors[idx]][0]);
            }
            return (pools[poolId].depositors, z);
        }
    }

    function checkClaimableRewards(uint poolId) public view returns (uint) {
        unchecked {
            uint rewards_count = (block.timestamp - pools[poolId].deposits[msg.sender][1]) / pools[poolId].reward_time;
            return pools[poolId].deposits[msg.sender][0] * pools[poolId].yield_percent * rewards_count / 100;
        }
    }

    function checkRemainingCapacity(uint poolId) public view returns (uint) {
        unchecked {
            return pools[poolId].max_amount - pools[poolId].pool_balance;
        }
    }

    function checkWhaleWallets() public view returns (address[] memory) {
        unchecked {
            return whales;
        }
    }
}