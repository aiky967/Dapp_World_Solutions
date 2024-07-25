// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IMyToken {
    function mint(address _to, uint256 _amount) external;
    function getTokenPriceInUSD() external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract CrowdFundEasy {

    IMyToken public immutable token;
    
    struct Campaign {
        address owner;
        uint256 deadline;
        uint256 goal;
        uint256 funds_collected;
    }

    constructor(address _token) {
        token = IMyToken(_token);
    }

    Campaign[] public campaigns;
    // donator => (campaign_id => amount in tokens))
    mapping(address => mapping(uint => uint)) public donations;

    /**
     * @notice createCampaign allows anyone to create a campaign
     * @param _goal amount of funds to be raised in USD
     * @param _duration the duration of the campaign in seconds
     */
    function createCampaign(uint256 _goal, uint256 _duration) external {
        require(_goal > 0 && _duration > 0, "Non-zero goal and duration required!");

        campaigns.push(Campaign(msg.sender, block.timestamp + _duration, _goal, 0));
    }

    /**
     * @dev contribute allows anyone to contribute to a campaign
     * @param _id the id of the campaign
     * @param _amount the amount of tokens to contribute
     */
    function contribute(uint256 _id, uint256 _amount) external {
        // check for valid _id value
        require(0 < _id && _id <= campaigns.length, "invalid campaign id!");
        // check for the campaign to be still active
        Campaign storage c = campaigns[_id - 1];
        require(c.deadline > block.timestamp, "this campaign is inactive!");
        // check if a contributor is not the owner of the campaign
        require(msg.sender != c.owner, "the owner can not contribute!");
        // check for _amount value
        require(_amount > 0, "the amount must be positive uint!");
        
        unchecked {
            // effects
            c.funds_collected += token.getTokenPriceInUSD() * _amount;
            donations[msg.sender][_id] += _amount;
        }

        // interactions - transfer from the contributor        
        token.transferFrom(msg.sender, address(this), _amount);
    }

    /**
     * @dev cancelContribution allows anyone to cancel their contribution
     * @param _id the id of the campaign
     */
    function cancelContribution(uint256 _id) external {
        // check for valid _id value
        require(0 < _id && _id <= campaigns.length, "invalid campaign id!");
        // check for the campaign to be still active
        Campaign storage c = campaigns[_id - 1];
        require(c.deadline > block.timestamp, "this campaign is inactive!");
        // check if you are a contributor
        uint amount = donations[msg.sender][_id];
        require(amount > 0, "you have not contributed anything for this campaign!");
        
        unchecked {
            // effects            
            c.funds_collected -= token.getTokenPriceInUSD() * donations[msg.sender][_id];
            donations[msg.sender][_id] = 0;
        }

        // interactions - transfer to the contributor
        token.transfer(msg.sender, amount);
    }

    /**
     * @notice withdrawFunds allows the creator of the campaign to withdraw the funds
     * @param _id the id of the campaign
     */

    function withdrawFunds(uint256 _id) external {
        // check for valid _id value
        require(0 < _id && _id <= campaigns.length, "invalid campaign id!");
        // check if msg.sender is the owner
        Campaign storage c = campaigns[_id - 1];
        require(c.owner == msg.sender, "you are not the owner!");        
        // check for the campaign to be inactive and the goal has been met         
        require(c.deadline <= block.timestamp && c.funds_collected >= c.goal, "this campaign is still active or the goal has not been met!");

        unchecked {
            uint amount = c.funds_collected / token.getTokenPriceInUSD();

            // effects - close the campaign
            c.funds_collected = 0;
            c.owner = address(0);
            c.goal = 0;
            c.deadline = 0;

            // interactions - transfer to the owner
            token.transfer(msg.sender, amount);
        }
    }

    /**
     * @notice refund allows the contributors to get a refund if the campaign failed
     * @param _id the id of the campaign
     */
    function refund(uint256 _id) external {
        // check for valid _id value
        require(0 < _id && _id <= campaigns.length, "invalid campaign id!");
        
        Campaign storage c = campaigns[_id - 1];
        // check for the campaign to be inactive and the goal has not been met
        require(c.deadline <= block.timestamp && c.funds_collected < c.goal, "this campaign is still active or the goal has been met!");
        // check if you are a contributor
        uint amount = donations[msg.sender][_id];
        require(amount > 0, "you have not contributed anything for this campaign!");

        unchecked {
            // effects - reset a donations from this contributor to this campaign
            donations[msg.sender][_id] = 0;
        }

        // interactions - transfer to the contributor
        token.transfer(msg.sender, amount);      
    }

    /**
     * @notice getContribution returns the contribution of a contributor in USD
     * @param _id the id of the campaign
     * @param _contributor the address of the contributor
     */
    function getContribution(uint256 _id, address _contributor) public view returns (uint256) {
        unchecked {
            return token.getTokenPriceInUSD() * donations[_contributor][_id];
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
        // check for valid _id value
        require(0 < _id && _id <= campaigns.length, "invalid campaign id!");
        // check for the campaign to be still active
        Campaign storage c = campaigns[_id - 1];
        require(c.deadline >= block.timestamp, "this campaign is inactive!");

        remainingTime = c.deadline - block.timestamp;
        goal = c.goal;
        totalFunds = c.funds_collected;
    }
}