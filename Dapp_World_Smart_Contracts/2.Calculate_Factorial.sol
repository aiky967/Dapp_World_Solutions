// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FactorialContract {

    function calculateFactorial(uint256 n) public pure returns (uint256) {
        unchecked {
            uint256 fact = 1;
            if (n == 0) {
                return 1;
            } else {
                for (uint256 i = 1; i <= n+1; i++) {
                    fact = fact * i;
                }
                return fact;
            }     
        }
    }
}
