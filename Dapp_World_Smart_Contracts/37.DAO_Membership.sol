// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOMembership {

    enum State {
        NA,
        Request,
        Accepted,
        Rejected
    }

    struct Member {
        State state;
        mapping(address => uint) approves;
        // mapping(address => bool) disapproves;
        uint favorableVote;
        uint negativeVote;
    }
    mapping(address => Member) members;
    uint countMembers = 1;

    constructor() {
        members[msg.sender].state = State.Accepted;
    }

    //To apply for membership of DAO
    function applyForEntry() public {
        Member storage m = members[msg.sender];
        require(m.state == State.NA && countMembers > 0);
        m.state = State.Request;
    }

    function checkAccepted() internal view {
        if(members[msg.sender].state != State.Accepted) {
            revert();
        }
    }    
    
    //To approve the applicant for membership of DAO
    function approveEntry(address _applicant) public {
        checkAccepted();
        Member storage m = members[_applicant];
        require(m.state == State.Request && (m.approves[msg.sender] & 1) != 1);
        m.approves[msg.sender] |= 1;
        unchecked {
            m.favorableVote ++;
            uint r = m.favorableVote * 100 / countMembers;
            if(r >= 30) {
                m.state = State.Accepted;
                countMembers++;
            }
        }        
    }

    function disapproved(State checkState, address _member, uint setBit, uint delta) internal {
        Member storage m = members[_member];
        require(m.state == checkState && (m.approves[msg.sender] & setBit) != setBit);
        m.approves[msg.sender] |= setBit;
        unchecked {
            m.negativeVote ++;
            uint r = m.negativeVote * 100 / (countMembers - delta); 
            if(r >= 70) {
                m.state = State.Rejected;
                if(setBit == 4) {
                    countMembers--;
                }
            }
        } 
    } 

    //To disapprove the applicant for membership of DAO
    function disapproveEntry(address _applicant) public{
        checkAccepted();
        disapproved(State.Request, _applicant, 2, 0);
    }

    //To remove a member from DAO
    function removeMember(address _memberToRemove) public {
        checkAccepted();
        if(msg.sender == _memberToRemove) {
            revert();
        }
        disapproved(State.Accepted, _memberToRemove, 4, 1);
    }

    //To leave DAO
    function leave() public {
        checkAccepted();
        members[msg.sender].state = State.Rejected;
        unchecked { 
            countMembers--; 
        }
    }

    //To check membership of DAO
    function isMember(address _user) public view returns (bool) {
        checkAccepted();
        return members[_user].state == State.Accepted; 
    }

    //To check total number of members of the DAO
    function totalMembers() public view returns (uint256) {
        checkAccepted();
        return countMembers; 
    }
}
