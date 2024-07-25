// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChcolateShop  {

    uint private chocolates;

    //this function allows gavin to buy n chocolates
    function buyChocolates(uint n) public {
        require(n > 0);
        unchecked {
            chocolates += n;
        }
    }

    //this function allows gavin to sell n chocolates
    function sellChocolates(uint n) public {
        require(n > 0);
        require(chocolates >= n, "Not enough chocolates");
        unchecked {
            chocolates -= n;
        }
    }

    //this function returns total number of chocolates in bag
    function chocolatesInBag() public view returns(uint n) {
        return chocolates;
    }
}