// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CryptoTrader {
 
    function roundTrip(int[] memory walletBalances, int[] memory networkFees) external pure returns (int) {
        uint n = walletBalances.length;
        
        for (uint i = 0; i < n; i++) {
            // Check if starting from exchange i is possible
            int balance = 0;
            bool canCompleteRoundTrip = true;
            
            for (uint j = 0; j < n; j++) {
                uint nextExchange = (i + j) % n;
                balance += walletBalances[nextExchange];
                balance -= networkFees[nextExchange];
                
                if (balance < 0) {
                    canCompleteRoundTrip = false;
                    break;
                }
            }
            
            if (canCompleteRoundTrip && balance >= 0) {
                return int(i);
            }
        }
        
        // If no solution found
        return -1;
    }
}
