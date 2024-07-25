// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract SmartRanking {

    struct Student {
        uint rollNumber;
        uint marks;
    }

    Student[] private students;
    mapping(uint => uint) private marks;
    uint private _topperMark;
    uint private _topperRollNumber;

    // Function to insert marks and roll number of a student
    function insertMarks(uint _rollNumber, uint _marks) public {
        marks[_rollNumber] = _marks;
        students.push(Student(_rollNumber, _marks));
        if (_marks > _topperMark) {
            _topperMark = _marks;
            _topperRollNumber = _rollNumber;
        }
        // Sort the students array after each insertion to maintain the rank order
        sortStudentsByMarks();
    }

    // Function to sort students by marks in descending order
    function sortStudentsByMarks() internal {
        for (uint i = 0; i < students.length - 1; i++) {
            for (uint j = 0; j < students.length - i - 1; j++) {
                if (students[j].marks < students[j + 1].marks) {
                    Student memory temp = students[j];
                    students[j] = students[j + 1];
                    students[j + 1] = temp;
                }
            }
        }
    }

     // Function to get the marks of a student by rank
    function scoreByRank(uint rank) public view returns (uint) {
        require(rank < students.length, "Rank is out of bounds");
        return students[rank].marks;
    }

    // Function to get the roll number of a student by rank
    function rollNumberByRank(uint rank) public view returns (uint) {
        require(rank < students.length, "Rank is out of bounds");
        return students[rank].rollNumber;
    }
}