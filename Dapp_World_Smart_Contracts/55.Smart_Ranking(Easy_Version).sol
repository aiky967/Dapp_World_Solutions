// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SmartRanking {

    mapping(uint => uint) private marks;
    uint private _topperMark;
    uint private _topperRollNumber;

    //this function is used to insert the marks
    function insertMarks(uint _rollNumber, uint _marks) public {
        marks[_rollNumber] = _marks;
        if (_marks > _topperMark) {
            _topperMark = _marks;
            _topperRollNumber = _rollNumber;
        }
    }

    //this function returns the hightest marks obtained by student
    function topperMarks() public view returns(uint) {
        require(_topperMark>0);
        return _topperMark;
    }

    //this function returns the roll number of student having highest marks
    function topperRollNumber() public view returns(uint) {
        require(_topperRollNumber>0);
        return _topperRollNumber;
    }

}