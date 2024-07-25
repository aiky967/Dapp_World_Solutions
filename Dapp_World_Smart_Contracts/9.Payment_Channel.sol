// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimplePaymentChannel {

    address public owner;
    address public recipient;
    uint256 private balance;
    uint256[] private payments;

  
    constructor(address recipientAddress) {
        require(recipientAddress != address(0));
        owner = msg.sender;
        recipient = recipientAddress;
    }

    modifier onlyParticipant() {
        require(msg.sender == owner || msg.sender == recipient);
        _;
    }

    function deposit() public payable {
        require(msg.value > 0);
        balance += msg.value;
    }

    function listPayment(uint256 _amount) public {
        require(msg.sender == owner);
        require(_amount <= balance);
        balance -= _amount;
        payments.push(_amount);
    }

    function closeChannel() public onlyParticipant {
        if (msg.sender == owner) {
            payable(owner).transfer(balance);
        } else {
            for (uint256 i = 0; i < payments.length; i++) {
                payable(recipient).transfer(payments[i]);
            }
            if (balance > 0) {
                payable(owner).transfer(balance);
            }
        }
        balance = 0;
    }

    function checkBalance() public view returns (uint256) {
        return balance;
    }

    function getAllPayments() public view returns (uint256[] memory) {
        return payments;
    }
}