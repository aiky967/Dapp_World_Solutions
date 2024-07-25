// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MaxProfit {

    //this function takes an array of prices and calculate maximum profit
    function maxProfit(uint256[] memory prices) public pure returns (uint256) {
        uint256 minPrice = type(uint256).max;
        uint256 maxP = 0;
        
        // Iterate through the prices array
        for (uint256 i = 0; i < prices.length; i++) {
            // Update the minimum price if a lower price is found
            if (prices[i] < minPrice) {
                minPrice = prices[i];
            }
            // Calculate the current profit
            uint256 currentProfit = prices[i] - minPrice;
            // Update the maximum profit if the current profit is higher
            if (currentProfit > maxP) {
                maxP = currentProfit;
            }
        }
        
        // Return the maximum profit
        return maxP;
    }

}