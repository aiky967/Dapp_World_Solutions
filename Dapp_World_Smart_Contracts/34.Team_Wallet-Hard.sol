// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

contract TeamWallet {

    struct Transaction {
        uint256 amount;
        uint256 approvalCnt;
        uint256 rejectionCnt;
        string status;
        mapping(address => bool) action;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _counter;

    address owner;
    uint256 private _credits;
    uint256 private _teamCount;
    uint256 initialized = 0;
    mapping(address => bool) teamMembers;
    mapping(uint256 => Transaction) transactions;

    // modifier to check members
    modifier isTeamMember() {
        require(teamMembers[msg.sender], "Not a team member");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    //For setting up the wallet
    function setWallet(address[] memory members, uint256 credtis) public {
        require(msg.sender == owner, "Not owner");
        require(initialized == 0);

        // checks
        require(members.length > 0, "Empty members array");
        require(credtis > 0, "Credits are 0");

        _credits = credtis;
        uint256 len = members.length;
        for(uint i; i<len; i++) {
            require(members[i] != msg.sender, "Owner can't be member");
            teamMembers[members[i]] = true;
        }

        _teamCount = members.length;
        initialized = 1;
    }

    //For spending amount from the wallet
    function spend(uint256 amount) public isTeamMember {
        require(amount > 0, "Spending can't be 0");
        _counter.increment();

        Transaction storage newTransaction = transactions[_counter.current()];
        newTransaction.amount = amount;
        newTransaction.approvalCnt = 0;
        newTransaction.rejectionCnt = 0;
        if (amount > credits()){
            newTransaction.status = "failed";
        } else {
            newTransaction.status = "pending";
        }
        newTransaction.action[msg.sender] = true;

        if (_teamCount == 1) {
            if(amount > credits()) {
                transactions[_counter.current()].status = "failed";
            } else {
                _credits -= amount;
                transactions[_counter.current()].status = "debited";
            }
        }
    }

    //For approving a transaction request
    function approve(uint256 n) public isTeamMember {
        require(keccak256(bytes(transactions[n].status)) == keccak256(bytes("pending")), "Decision made");
        require(!transactions[n].action[msg.sender], "Can't approve");

        transactions[n].approvalCnt++;
        transactions[n].action[msg.sender] = true;
        sync(n, true, false);
    }

    //For rejecting a transaction request
    function reject(uint256 n) public isTeamMember {
        require(keccak256(bytes(transactions[n].status)) == keccak256(bytes("pending")), "Decision made");
        require(!transactions[n].action[msg.sender], "Can't approve");

        transactions[n].rejectionCnt++;
        transactions[n].action[msg.sender] = true;
        sync(n, false, true);
    }

    // utility function for execution of pending transactions
    function sync(uint256 n, bool approval, bool rejection) internal {
        uint256 approvalCnt = transactions[n].approvalCnt+1;
        uint256 rejectionCnt = transactions[n].rejectionCnt;

        if(approval && (approvalCnt * 100) / _teamCount >= 70) {
            if(transactions[n].amount > credits()) {
                revert("No enough credits");
            } else {
                _credits -= transactions[n].amount;
                transactions[n].status = "debited";
            }
        }   
        
        if(rejection && (rejectionCnt * 100) / _teamCount > 30) {
            transactions[n].status = "failed";
        }
    }

    //For checking remaing credits in the wallet
    function credits() public view isTeamMember returns (uint256) {
        return _credits;
    }

    //For checking nth transaction status
    function viewTransaction(uint256 n) public view isTeamMember returns (uint amount,string memory status){
        require(transactions[n].amount != 0, "No transaction exists");
        amount = transactions[n].amount;
        status = transactions[n].status;
    }

    //For checking the transaction stats for the wallet
    function transactionStats() public view isTeamMember returns (uint debitedCount,uint pendingCount,uint failedCount) {
        debitedCount = debitedCount;
        pendingCount = pendingCount;
        failedCount = failedCount;
    }
}