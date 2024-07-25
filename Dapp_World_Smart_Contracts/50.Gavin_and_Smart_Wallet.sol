// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SmartWallet {
    address public immutable Gavin;
    uint256 public wallet;
    
    mapping(address => bool) public accessList;

    uint constant MAX_LIMIT = 10000;

    constructor() {
        Gavin = msg.sender;
        wallet = 0;
    }

    modifier onlyGavin() {
        require(msg.sender == Gavin);
        _;
    }

    modifier onlyChildrens() {
        require(accessList[msg.sender] == true, "You don't have access to the wallet");
        _;
    }

    //this function allows adding funds to wallet
    function addFunds(uint amount) public payable onlyGavin onlyChildrens {
        require(amount > 0, "   Amount must be greater than zero");
        require(wallet + amount <= MAX_LIMIT, "Limit exceeds");
        unchecked {
            wallet += amount;
            payable(Gavin).transfer(amount);
        }
    }

    //this function allows spending an amount to the account that has been granted access by Gavin
    function spendFunds(uint amount) public payable onlyGavin onlyChildrens {
        unchecked {
            wallet -= amount;
            payable(msg.sender).transfer(amount);
        }
    }

    //this function grants access to an account and can only be accessed by Gavin
    function addAccess(address x) public onlyGavin {
        require(x != address(0), "Invalid address");
        accessList[x] = true;
    }

    //this function revokes access to an account and can only be accessed by Gavin
    function revokeAccess(address x) public onlyGavin {
        require(accessList[x], "Address not in the list");
        accessList[x] = false;
    }

    //this function returns the current balance of the wallet
    function viewBalance() public view onlyGavin onlyChildrens returns(uint) {
        return wallet;
    }

}