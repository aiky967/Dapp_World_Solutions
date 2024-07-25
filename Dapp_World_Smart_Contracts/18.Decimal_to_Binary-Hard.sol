// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ToBinary{

		function toBinary(int256 n) public pure returns (string memory) {
            // -5  =  5 (00000101) invert (11111010) add 1 (11111011)

            require(n >= -128 && n <= 127, "Number must be in the range of -128 to 127");

            if (n >= 0) {
                // Positive numbers are represented as usual in binary form (00000000 to 01111111)
                return toBinaryString(uint256(n));
            } else {
                uint absoluteValue = uint(-n);
                uint twoComplement = (1 << 8) - absoluteValue;
                return toBinaryString(twoComplement);
            }
            
        }

        function toBinaryString(uint256 n) private pure returns (string memory) {

            bytes memory output = new bytes(8);

            for (uint8 i = 0; i < 8; i++) {
                output[7 - i] = (n % 2 == 1) ? bytes1("1") : bytes1("0");
                n /= 2;
            }

            return string(output);
        }
}