// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Abacus  {

    int256 private values;

    function addInteger(int n) public {
        unchecked {
            values = values + n;
        }
    }

    function sumOfIntegers() public view returns(int x){
        x = values;
    }
}