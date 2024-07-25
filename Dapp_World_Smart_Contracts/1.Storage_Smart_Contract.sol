// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StorageContract {

    // Function to store a new value
    function storeValue(uint256 _newValue) public {
        assembly {
            sstore(0x20, _newValue)
        }
    }

    // Function to read the stored value
    function readValue() public view returns (uint256 ret) {
       assembly {
        ret := sload(0x20)
       }
    }
}
