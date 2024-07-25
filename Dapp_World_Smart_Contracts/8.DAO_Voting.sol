// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.20;

contract DAO {
    uint256 public contributionTimeEnd;
    uint256 public voteTime;
    uint256 public quorum;

    mapping(address => uint256) public shares;
    address[] public investors;

    address owner;

    struct Proposal {
        uint256 id;
        uint256 amount;
        address payable recipient;
        string description;
        uint256 voteWeight;
        mapping(address => bool) votes;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalId;

    error ContributionTimeEnded();
    error InsufficientShares();
    error InsufficientFunds();
    error Unauthorized();
    error InvalidConfig();
    error ZeroTransfer();
    error ProposalExecutionFailed();
    error VotingFailed();
    error DAONotInitialized();

    constructor() {
        owner = msg.sender;
    }

    function initializeDAO(uint256 _contributionTimeEnd, uint256 _voteTime, uint256 _quorum) public {
        if(msg.sender != owner) revert Unauthorized();
        if(_contributionTimeEnd == 0 || _voteTime == 0 || _quorum == 0) revert InvalidConfig();

        contributionTimeEnd = block.timestamp + _contributionTimeEnd;
        voteTime = contributionTimeEnd + _voteTime;
        quorum = _quorum;
    }

    function contribution() public payable {
        if(block.timestamp >= contributionTimeEnd) revert ContributionTimeEnded();
        if(msg.value < 1) revert InsufficientFunds();

        shares[msg.sender] += msg.value;
        if (shares[msg.sender] == msg.value) {
            investors.push(msg.sender);
        }
    }

    function redeemShare(uint256 amount) public {
        if(shares[msg.sender] < amount) revert InsufficientShares();
        if(address(this).balance < amount) revert InsufficientFunds();

        shares[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transaction failed");
    }

    function transferShare(uint256 amount, address to) public {
        if(amount < 1) revert ZeroTransfer();
        if(shares[msg.sender] < amount) revert InsufficientShares();

        shares[to] += amount;
        shares[msg.sender] -= amount;
        if (shares[to] == amount) {
            investors.push(to);
        }
    }

    function createProposal(string calldata description, uint256 amount, address payable recipient) public {
        if(msg.sender != owner) revert Unauthorized();
        if(address(this).balance < amount)  revert InsufficientFunds();

        Proposal storage newProposal = proposals[proposalId];
        newProposal.id = proposalId;
        newProposal.amount = amount;
        newProposal.recipient = recipient;
        newProposal.description = description;
        newProposal.voteWeight = 0;
        newProposal.executed = false;
        
        proposalId++;
    }

    function voteProposal(uint256 _proposalId) public {
        if(shares[msg.sender] == 0 || proposals[_proposalId].votes[msg.sender] || block.timestamp >= voteTime) revert VotingFailed();

        proposals[_proposalId].votes[msg.sender] = true;
        proposals[_proposalId].voteWeight += shares[msg.sender];
    }

    function executeProposal(uint256 _proposalId) public {
        if(proposals[_proposalId].executed || msg.sender != owner || (proposals[_proposalId].voteWeight * 100) / address(this).balance < quorum)
            revert ProposalExecutionFailed();

        (bool success, ) = proposals[_proposalId].recipient.call{value: proposals[_proposalId].amount}("");
        require(success, "Transaction failed");

        proposals[_proposalId].executed = true;
    }

    function proposalList() public view returns (string[] memory, uint256[] memory, address[] memory) {
        if(contributionTimeEnd == 0) revert DAONotInitialized();
        
        string[] memory descriptions = new string[](proposalId);
        uint256[] memory amounts = new uint256[](proposalId);
        address[] memory recipients = new address[](proposalId);

        for (uint256 i = 0; i < proposalId; i++) {
            descriptions[i] = proposals[i].description;
            amounts[i] = proposals[i].amount;
            recipients[i] = proposals[i].recipient;
        }

        return (descriptions, amounts, recipients);
    }

    function allInvestorList() public view returns (address[] memory) {
        if(contributionTimeEnd == 0) revert DAONotInitialized();
        return investors;
    }
}