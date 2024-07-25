// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IMyToken {
    function mint(address _to, uint256 _amount) external;
    function getTokenPriceInUSD() external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract CrowdFund {

    IMyToken[] public tokens;
    
    struct Campaign {
        address owner;
        uint256 deadline;
        uint256 goal;
        uint256 overall_funds;
        // dim(funds_collected) == dim(tokens)
        mapping(IMyToken => uint256) funds_collected;
    }

    // here we have a list of tokens in which we can contribute :)
    constructor(address[] memory _tokens) {
        unchecked {
            uint idx;
            uint len = _tokens.length;

            for (; idx < len; ++idx) {
                tokens.push(IMyToken(_tokens[idx]));
            }
        }
    }

    Campaign[] public campaigns;
    // donator => (campaign_id => (token's address => amount in tokens)))
    mapping(address => mapping(uint => mapping(IMyToken => uint))) public donations;

    /**
     * @notice createCampaign allows anyone to create a campaign
     * @param _goal amount of funds to be raised in USD
     * @param _duration the duration of the campaign in seconds
     */
    function createCampaign(uint256 _goal, uint256 _duration) external {
        require(_goal > 0 && _duration > 0, "Non-zero goal and duration required!");

        unchecked {
            uint idx = campaigns.length;
            campaigns.push();
            Campaign storage c = campaigns[idx];

            c.owner = msg.sender;
            c.deadline = block.timestamp + _duration;
            c.goal = _goal;
        }
    }

    /**
     * @dev contribute allows anyone to contribute to a campaign
     * @param _id the id of the campaign
     * @param _amount the amount of tokens to contribute
     */
    function contribute(uint256 _id, address _token, uint256 _amount) external {
        unchecked {
            // check for valid _id value
            require(0 < _id && _id <= campaigns.length, "invalid campaign id!");
            // check for the campaign to be still active
            Campaign storage c = campaigns[_id - 1];
            require(c.deadline > block.timestamp, "this campaign is inactive!");
            // check if a contributor is not the owner of the campaign
            require(msg.sender != c.owner, "the owner can not contribute!");
            // check for _amount value
            require(_amount > 0, "the amount must be positive uint!");
        
            // effects
            c.funds_collected[IMyToken(_token)] += IMyToken(_token).getTokenPriceInUSD() * _amount;
            c.overall_funds += IMyToken(_token).getTokenPriceInUSD() * _amount;
            donations[msg.sender][_id][IMyToken(_token)] += _amount;
        }

        // interactions - transfer from the contributor        
        IMyToken(_token).transferFrom(msg.sender, address(this), _amount);
    }

    /**
     * @dev cancelContribution allows anyone to cancel their contribution
     * @param _id the id of the campaign
     */
    function cancelContribution(uint256 _id) external {
        unchecked {
            // check for valid _id value
            require(0 < _id && _id <= campaigns.length, "invalid campaign id!");
            // check for the campaign to be still active
            Campaign storage c = campaigns[_id - 1];
            require(c.deadline > block.timestamp, "this campaign is inactive!");
            // check if you are a contributor of at least one token of tokens list

            uint idx;
            uint len = tokens.length;
            uint amount;
            uint usd_amount;
            bool flag;

            for (; idx < len; ++idx) {            
                amount = donations[msg.sender][_id][tokens[idx]];
                usd_amount = tokens[idx].getTokenPriceInUSD() * amount;

                if (amount > 0) {
                    // effects
                    c.funds_collected[tokens[idx]] -= usd_amount;
                    c.overall_funds -= usd_amount;
                    donations[msg.sender][_id][tokens[idx]] = 0;

                    // interactions - transfer to the contributor
                    tokens[idx].transfer(msg.sender, amount);

                    flag = true;
                }
            }
            require(flag == true, "you have not contributed anything for this campaign!");
        }
    }

    /**
     * @notice withdrawFunds allows the creator of the campaign to withdraw the funds
     * @param _id the id of the campaign
     */

    function withdrawFunds(uint256 _id) external {
        unchecked {
            // check for valid _id value
            require(0 < _id && _id <= campaigns.length, "invalid campaign id!");
            // check if msg.sender is the owner
            Campaign storage c = campaigns[_id - 1];
            require(c.owner == msg.sender, "you are not the owner!");        
            // check for the campaign to be inactive and the goal has been met         
            require(c.deadline <= block.timestamp && c.overall_funds >= c.goal, "this campaign is still active or the goal has not been met!");

            uint idx;
            uint amount;
            uint len = tokens.length;

            // effects - close the campaign
            c.owner = address(0);
            c.goal = 0;
            c.deadline = 0;
            c.overall_funds = 0;


            for (; idx < len; ++idx) {
                 amount = c.funds_collected[tokens[idx]] / tokens[idx].getTokenPriceInUSD();

                // effects - close the campaign
                c.funds_collected[tokens[idx]] = 0;

                // interactions - transfer to the owner
                tokens[idx].transfer(msg.sender, amount);
            }
        }
    }

    /**
     * @notice refund allows the contributors to get a refund if the campaign failed
     * @param _id the id of the campaign
     */
    function refund(uint256 _id) external {
        unchecked {
            // check for valid _id value
            require(0 < _id && _id <= campaigns.length, "invalid campaign id!");
            
            Campaign storage c = campaigns[_id - 1];
            // check for the campaign to be inactive and the goal has not been met
            require(c.deadline <= block.timestamp && c.overall_funds < c.goal, "this campaign is still active or the goal has been met!");
            // check if you are a contributor of at least one token of tokens list

            uint idx;
            uint len = tokens.length;
            uint amount;
            bool flag;

            for (; idx < len; ++idx) {            
                amount = donations[msg.sender][_id][tokens[idx]];

                if (amount > 0) {
                    // effects - reset a donations from this contributor to this campaign
                    donations[msg.sender][_id][tokens[idx]] = 0;

                    // interactions - transfer to the contributor
                    tokens[idx].transfer(msg.sender, amount);   
                    flag = true;              
                }
            }            
            require(flag == true, "you have not contributed anything for this campaign!");            
        }     
    }

    /**
     * @notice getContribution returns the contribution of a contributor in USD
     * @param _id the id of the campaign
     * @param _contributor the address of the contributor
     */
    function getContribution(uint256 _id, address _contributor) public view returns (uint256 z) {
        unchecked {        
            // check for valid _id value
            require(0 < _id && _id <= campaigns.length, "invalid campaign id!");

            uint idx;
            uint len = tokens.length;

            for (; idx < len; ++idx) { 
                z += tokens[idx].getTokenPriceInUSD() * donations[_contributor][_id][tokens[idx]];
            }           
        }
    }
		
		/**
		 * @notice getCampaign returns details about a campaign
		 * @param _id the id of the campaign
		 * @return remainingTime the time (in seconds) when the campaign ends
		 * @return goal the goal of the campaign (in USD)
		 * @return totalFunds total funds (in USD) raised by the campaign
		 */
    function getCampaign(uint256 _id)
        external
        view
        returns (uint256 remainingTime, uint256 goal, uint256 totalFunds) {
        unchecked {
            // check for valid _id value
            require(0 < _id && _id <= campaigns.length, "invalid campaign id!");
            // check for the campaign to be still active
            Campaign storage c = campaigns[_id - 1];
            require(c.deadline >= block.timestamp, "this campaign is inactive!");

            remainingTime = c.deadline - block.timestamp;
            goal = c.goal;
            totalFunds = c.overall_funds;
        }
    }
}