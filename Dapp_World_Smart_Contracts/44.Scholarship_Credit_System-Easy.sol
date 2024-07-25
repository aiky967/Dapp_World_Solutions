// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ScholarshipCreditContract {

    uint credits = 1000000;
    address immutable owner;

    mapping (address => uint256) merchantOrStudent; // 1. student 2. merchant
    mapping (address => uint256) amount;

    // All addresses for owner, students, and merchant must be unique.
    // A student is allowed to receive multiple scholarship.
    // Merchants can only receive credits and can cash them in through Pied Piper. 
    // They can also deregister their address from the list of merchant addresses.
    // The smart contract must be accessible to students and merchants for transferring and receiving credits. 

    constructor() {
        owner = msg.sender;
    }

    function onlyOwner() internal view {
        require(msg.sender == owner);
    }

    //This function assigns credits to student getting the scholarship
    function grantScholarship(address _studentAddress, uint _credits) public {
        onlyOwner();
        require(msg.sender != _studentAddress);
        require(credits >= _credits);
        require(merchantOrStudent[_studentAddress] != 2); 
        unchecked {
            merchantOrStudent[_studentAddress] = 1;
            credits -= _credits;
            amount[_studentAddress] += _credits;
        }
    }

    //This function is used to register a new merchant who can receive credits from students
    function registerMerchantAddress(address _merchantAddress) public {
        onlyOwner();
        require(msg.sender != _merchantAddress);
        require(merchantOrStudent[_merchantAddress] != 1);
        unchecked {
            merchantOrStudent[_merchantAddress] = 2;
        }
    }

    function clear(address _addr) internal {
        unchecked {
            merchantOrStudent[_addr] = 0;
            credits += amount[_addr];
            amount[_addr] = 0;
        }
    }

    //This function is used to deregister an existing merchant
    function deregisterMerchantAddress(address _merchantAddress) public {
        onlyOwner();
        require(merchantOrStudent[_merchantAddress] == 2);
        clear(_merchantAddress);
    }

    //This function is used to revoke the scholarship of a student
    function revokeScholarship(address _studentAddress) public {
        onlyOwner();
        require(merchantOrStudent[_studentAddress] == 1);
        clear(_studentAddress);
    }

    //Students can use this function to transfer credits only to registered merchants
    function spend(address _merchantAddress, uint _amount) public {
        require(merchantOrStudent[msg.sender] == 1);
        require(merchantOrStudent[_merchantAddress] == 2);
        require(amount[msg.sender] >= _amount);
        unchecked {
            amount[msg.sender] -= _amount;
            amount[_merchantAddress] += _amount;
        }
    }

    //This function is used to see the available credits assigned.
    function checkBalance() public view returns (uint) {
        if(merchantOrStudent[msg.sender] > 0) {
            return amount[msg.sender];
        } else if(msg.sender == owner) {
            return credits;
        }
        revert();
    }
}