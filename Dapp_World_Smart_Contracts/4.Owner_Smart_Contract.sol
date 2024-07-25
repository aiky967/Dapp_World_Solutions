// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract OwnerContract {
   
    function getOwner() external view returns (address) {
       return msg.sender;
    }
}
