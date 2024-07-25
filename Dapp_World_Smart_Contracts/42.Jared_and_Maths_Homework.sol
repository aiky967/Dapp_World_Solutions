// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract CalculateArea {

    //this function returns area of square
    function squareArea(uint a) public pure returns(uint n) {
        if( a == 0) { 
            revert(); 
        }
        unchecked {
            n = a * a;
        }
    }

    //this function returns area of rectangle
    function rectangleArea(uint a, uint b) public pure returns(uint n) {
        // if( a == 0 || b == 0) { 
        //     revert(); 
        // } 
        if(0 == (a < b ? a : b) || (a > b ? a : b) > 2**253) {
            revert();
        }
        unchecked {
            n = a * b;
        }
    }
    
}