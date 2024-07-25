// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DWGotTalent {

    address owner;

    enum Voting {
        prepare,
        voting,
        ended
    }

    function onlyOwner() internal view {
        require(msg.sender == owner);
    }

    Voting iVoting;
    uint judgeWeightage;
    uint audienceWeightage;
    bool fWeightage;

    address[] judges;
    address[] finalists;

    mapping(address => address) logVotes;
    mapping(address => uint) finalistResult;

    constructor() {
        owner = msg.sender;
    }

    function inArray(address[] memory arr, address check_address) internal pure returns(bool) {
        for(uint i; i < arr.length; i++) {
            if(arr[i] == check_address) {
                return true;
            }
        }
        return false;
    }

    //this function defines the addresses of accounts of judges
    function selectJudges(address[] calldata arrayOfAddresses) public {
        onlyOwner();
        require(inArray(arrayOfAddresses, owner) == false);
        for(uint i; i < finalists.length; i++) {
            require(inArray(arrayOfAddresses, finalists[i]) == false);
        }
        judges = arrayOfAddresses;
    }

    //this function adds the weightage for judges and audiences
    function inputWeightage(uint _judgeWeightage, uint _audienceWeightage) public {
        onlyOwner();
        require(iVoting == Voting.prepare);
        require(iVoting == Voting.prepare);
        judgeWeightage = _judgeWeightage;
        audienceWeightage = _audienceWeightage;
        fWeightage = true;
    }

    //this function defines the addresses of finalists
    function selectFinalists(address[] calldata arrayOfAddresses) public {
        onlyOwner();
        require(iVoting == Voting.prepare);
        require(inArray(arrayOfAddresses, owner) == false);
        for(uint i; i < judges.length; i++) {
            require(inArray(arrayOfAddresses, judges[i]) == false);
        }
        finalists = arrayOfAddresses;
    }

    //this function strats the voting process
    function startVoting() public {
        onlyOwner();
        require(judges.length > 0 && finalists.length > 0 && fWeightage == true);
        iVoting = Voting.voting;
    }

    function vote(address _finalistAddress, uint _weightage) internal {
        address addr = logVotes[msg.sender];
        if(addr != address(0)) {
            finalistResult[addr] -= _weightage;
        }
        finalistResult[_finalistAddress] += _weightage;
    }

    //this function is used to cast the vote 
    function castVote(address finalistAddress) public {
        require(iVoting == Voting.voting);
        require(inArray(finalists, finalistAddress) == true);
        if(inArray(judges, msg.sender) == true ) {
            vote(finalistAddress, judgeWeightage);
        } else {
            vote(finalistAddress, audienceWeightage);
        }
    }

    //this function ends the process of voting
    function endVoting() public {
        onlyOwner();
        require(iVoting == Voting.voting);
        iVoting = Voting.ended;
    }

    //this function returns the winner/winners
    function showResult() public view returns (address[] memory) {
        require(iVoting == Voting.ended);
        uint max;
        uint count = 1;
        for(uint i; i < finalists.length; i++) {
            address addr = finalists[i];
            uint a = finalistResult[addr];
            if(a == max) {
                count++;
            } else if(a > max) {
                count = 1;
                max = a;
            }

        }
        address[] memory res = new address[](count);
        count = 0;
        for(uint i; i < finalists.length; i++) {
            if(finalistResult[finalists[i]] == max) {
                res[count++] = finalists[i];
            }
        }
        return res;
    }

}