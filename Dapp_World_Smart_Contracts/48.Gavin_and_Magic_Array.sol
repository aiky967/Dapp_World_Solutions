// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MagicArray {

    //this function outputs value of arr[ind] after 'hrs' number of hours
    function findValue(int[] memory arr, uint ind, uint hrs) public pure returns (int){
        return arr[ind] * int(hrs);
    }

    // function findValue(int[] calldata arr, uint ind, uint hrs) external pure returns (int ret){
    //     assembly {
    //         if gt(ind, sub(arr.length, 1)) {revert(0, 0)}
    //         ret := mul(calldataload(add(arr.offset, mul(ind, 0x20))), hrs)
    //     }
    // }

}