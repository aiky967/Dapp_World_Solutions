// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SecondLargest {

    //this function outputs the second largest integer in the array
    function findSecondLargest(int[] calldata arr) public pure returns (int) {
        int largest = -2**255;
        int secondLargest = -2**255;

        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] > largest) {
                secondLargest = largest;
                largest = arr[i];
            } else if (arr[i] > secondLargest && arr[i] != largest) {
                secondLargest = arr[i];
            }
        }
        return secondLargest;
    }

}