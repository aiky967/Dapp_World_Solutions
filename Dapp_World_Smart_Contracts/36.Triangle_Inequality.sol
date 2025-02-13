// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TriangleInequality {
    //To check if a triangle is possible with lengths a,b and c
    function check(uint a, uint b, uint c) public pure returns (bool) {
        if( a+b <= c || a+c <= b || b+c <= a || a < 1 || b < 1 || c < 1 ) {
            return false;
        }
        return true;
    }
}