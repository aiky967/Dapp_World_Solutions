// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOMembership {

    enum State {
        NA,
        Request,
        Accepted
        // Rejected
    }
    struct Member {
        State state;
        mapping(address => bool) approves;
        uint vote;
    }
    mapping(address => Member) members;
    uint countMembers = 1;

    constructor() {
        members[msg.sender].state = State.Accepted;
    }

    //To apply for membership of DAO
    function applyForEntry() public {
        Member storage m = members[msg.sender];
        require(m.state == State.NA);
        m.state = State.Request;
    }

    function checkAccepted() internal view {
        require(members[msg.sender].state == State.Accepted);
    }
    
    //To approve the applicant for membership of DAO
    function approveEntry(address _applicant) public {
        checkAccepted();
        Member storage m = members[_applicant];
        require(m.state == State.Request && m.approves[msg.sender] == false);
        m.approves[msg.sender] = true;
        unchecked {
            m.vote ++;
            uint r = m.vote * 100 / countMembers;
            if(r >= 30) {
                m.state = State.Accepted;
                countMembers++;
            }
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
