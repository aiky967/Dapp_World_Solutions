// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

// Record each diamond  in a blockchain ledger 
// keep track of diamonds based on their weights

contract DiamondLedger {

    mapping (uint => uint) private diamondWeights;

    // weight of each diamond will be in the range of 0 to 1000
    function importDiamonds(uint[] memory weights) public {
        for (uint i = 0; i < weights.length; i++) {
            uint weight = weights[i];
            require(weight < 1000);
            diamondWeights[weight]++;
        }
    }

    // Hard version
    // allowance - max allowable diff between weight of diamond and queried weight
    // returns in the range of weight - allowance to weight + allowance
    function availableDiamonds(uint weight, uint allowance) public view returns(uint) {
        require(weight < 1000);
        uint count = 0;

        uint lowerBound = weight >= allowance ? weight - allowance : 0;
        uint upperBound = weight + allowance <= 1000 ? weight + allowance : 0;

        for (uint i = lowerBound; i <= upperBound; i++) {
            count += diamondWeights[i];
        }

        return count;
    }

}