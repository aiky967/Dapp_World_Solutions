// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract LCM {

    //this function calculates the LCM
    function gcd(uint a, uint b) public pure returns (uint) {
        uint256 _a = a;//65
        uint256 _b = b;//784
        uint256 temp;//0
        while (_b > 0) {
            temp = _b;//784
            _b = _a % _b; // % is remainder 0
            _a = temp;//784
        }
        return _a;
    }

    function lcm(uint256 a, uint256 b) public pure returns (uint256) {
        return a * (b / gcd(a, b));
    }

}