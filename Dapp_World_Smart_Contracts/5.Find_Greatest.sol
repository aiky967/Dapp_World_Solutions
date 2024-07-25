// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MaxNumberContract {

    function findMaxNumber(uint256[] memory numbers) external pure returns (uint256) {
        uint256 largest = 0;
        uint256 n = numbers.length;
        uint256 i;
        for (i = 0; i < n; i++) {
            if(largest < numbers[i]){
               largest = numbers[i];
           }
        }
        return largest;
    }
}
