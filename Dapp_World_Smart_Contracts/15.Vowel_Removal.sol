// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RemoveVowels {

    function removeVowels(string memory input) public pure returns (string memory) {
        bytes memory inputbytes = bytes(input);
        uint256 inputLength = inputbytes.length;
        uint256 outputLength = 0;

        // Count the number of non-vowel characters
        for (uint256 i = 0; i < inputLength; i++) {
            bytes1 char = inputbytes[i];
            if (
                !(char == "a" || char == "e" || char == "i" || char == "o" || char == "u" ||
                  char == "A" || char == "E" || char == "I" || char == "O" || char == "U")
            ) {
                outputLength++;
            }
        }

        // Create a new bytes array with non-vowel characters
        bytes memory outputbytes = new bytes(outputLength);
        uint256 outputIndex = 0;
        for (uint256 i = 0; i < inputLength; i++) {
            bytes1 char = inputbytes[i];
            if (
                !(char == "a" || char == "e" || char == "i" || char == "o" || char == "u" ||
                  char == "A" || char == "E" || char == "I" || char == "O" || char == "U")
            ) {
                outputbytes[outputIndex] = char;
                outputIndex++;
            }
        }

        return string(outputbytes);
    }
}