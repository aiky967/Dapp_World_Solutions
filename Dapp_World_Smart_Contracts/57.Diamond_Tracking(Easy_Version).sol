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

    // // returns the number of diamonds that have specified weights
    function availableDiamonds(uint weight) public view returns(uint) {
        require(weight < 1000);
        return diamondWeights[weight];
    }
}