// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ToBinary{

		function toBinary(uint256 n) public pure returns (string memory) {
            require(n < 256);

            bytes memory output = new bytes(8);
            uint8 i;

            unchecked {
                for (;i < 8; i++) {
                    output[7 - i] = ((n >> i) & 1 == 1) ? bytes1("1") : bytes1("0");
                }
            }

            return string(output);   
        }
}