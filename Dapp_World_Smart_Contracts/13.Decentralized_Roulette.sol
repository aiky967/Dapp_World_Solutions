// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

contract SimpleOperations {

    // /**
    //  * @notice calculateAverage calculates the average of two numbers
    //  * @param a the first number
    //  * @param b the second number
    //  * @return the average of the two numbers
    //  */
    function calculateAverage(
        uint256 a,
        uint256 b
    ) public pure returns (uint256 c) {
        assembly {
            // Add the two numbers together
            let sum := add(a, b)
            // Divide the sum by 2
            c := div(sum, 2)
        }
    }

    // /**
    //  * @notice getBit returns the bit at the given position
    //  * @param num the number to get the bit from
    //  * @param position the position of the bit to get
    //  * @return the bit at the given position
    //  */
    function getBit(uint256 num, uint256 position) public pure returns (uint8) {
        require(position > 0, "Position must be greater than 0");
        uint256 lastBitPosition = 0;
        uint256 tempNum = num;
        while (tempNum > 0) {
            lastBitPosition++;
            tempNum >>= 1;
        }

        // Check if the specified position exceeds the position of the last bit with a value of 1
        require(position <= lastBitPosition, "Specified position exceeds last bit position");

        // Calculate the bit at the specified position
        uint256 bitValue = (num >> (position - 1)) & 1;
        return uint8(bitValue);
    }

    // /**
    //  * @notice sendEth sends ETH to the given address
    //  * @param to the address to send ETH to
    //  * @param value the amount of ETH to send
    //  */
    function sendEth(address to) public payable {
        require(to != msg.sender, "Cannot send ETH to yourself");
        require(to != address(this), "Cannot send ETH to the contract itself");

        // Transfer the received amount of ETH to the specified address
        payable(to).transfer(msg.value);
    }
}