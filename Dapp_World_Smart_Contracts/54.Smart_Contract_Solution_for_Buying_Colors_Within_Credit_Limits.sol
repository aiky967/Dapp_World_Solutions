// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HoliColors {
    uint256 private totalCredits;
    uint256 private redCreditsSpent;
    uint256 private greenCreditsSpent;
    uint256 private blueCreditsSpent;

    uint256 constant MAX_RED_CREDITS = 40;
    uint256 constant MAX_GREEN_CREDITS = 30;
    uint256 constant MAX_BLUE_CREDITS = 40;

    constructor() {
        totalCredits = 100;
        redCreditsSpent = 0;
        greenCreditsSpent = 0;
        blueCreditsSpent = 0;
    }

    function buyColour(string memory colour, uint256 price) public {
        require(price > 0, "Price must be greater than 0");
        require(totalCredits >= price, "Not enough total credits");

        if (keccak256(abi.encodePacked(colour)) == keccak256(abi.encodePacked("red"))) {
            require(redCreditsSpent + price <= MAX_RED_CREDITS, "Exceeds red credit limit");
            redCreditsSpent += price;
        } else if (keccak256(abi.encodePacked(colour)) == keccak256(abi.encodePacked("green"))) {
            require(greenCreditsSpent + price <= MAX_GREEN_CREDITS, "Exceeds green credit limit");
            greenCreditsSpent += price;
        } else if (keccak256(abi.encodePacked(colour)) == keccak256(abi.encodePacked("blue"))) {
            require(blueCreditsSpent + price <= MAX_BLUE_CREDITS, "Exceeds blue credit limit");
            blueCreditsSpent += price;
        } else {
            revert("Invalid colour");
        }

        totalCredits -= price;
    }

    function credits() public view returns (uint256) {
        return totalCredits;
    }
}
