// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ScholarshipCreditContract {
    uint256 credits = 1000000;
    address owner;

    bytes32 constant MEAL = keccak256(abi.encodePacked("meal"));
    bytes32 constant ACADEMICS = keccak256(abi.encodePacked("academics"));
    bytes32 constant SPORTS = keccak256(abi.encodePacked("sports"));
    bytes32 constant ALL = keccak256(abi.encodePacked("all"));
    uint constant STUDENT = 1;

    mapping(address => bytes32) merchantOrStudent;
    mapping(address => mapping(bytes32 => uint256)) amount;

    constructor() {
        owner = msg.sender;
    }

    //This function assigns credits of particular category to student getting the scholarship
    function grantScholarship(address _studentAddress, uint _credits, string calldata _category) public {
        onlyOwner();
        require(msg.sender != _studentAddress, "Owner cannot grant scholarship to themselves");
        require(credits >= _credits, "Not enough credits available");
        require(uint256(merchantOrStudent[_studentAddress]) < 2, "Address already registered as merchant");

        bytes32 b_category = keccak256(abi.encodePacked(_category));
        require(b_category == MEAL || 
                b_category == ACADEMICS || 
                b_category == SPORTS || 
                b_category == ALL, "Invalid category");

        merchantOrStudent[_studentAddress] = bytes32(STUDENT);
        credits -= _credits;
        amount[_studentAddress][b_category] += _credits;
    }

    //This function is used to register a new merchant under given category
    function registerMerchantAddress(address _merchantAddress, string calldata _category) public {
        onlyOwner();
        require(msg.sender != _merchantAddress, "Owner cannot register themselves");
        require(merchantOrStudent[_merchantAddress] != bytes32(STUDENT), "Address already registered as student");

        bytes32 b_category = keccak256(abi.encodePacked(_category));
        require(b_category == MEAL || 
                b_category == ACADEMICS || 
                b_category == SPORTS, "Invalid category");

        merchantOrStudent[_merchantAddress] = b_category;
    }

    //This function is used to deregister an existing merchant
    function deregisterMerchantAddress(address _merchantAddress) public {
        onlyOwner();
        require(uint256(merchantOrStudent[_merchantAddress]) > 1, "Address not registered as merchant");

        clear(_merchantAddress);
    }

    //This function is used to revoke the scholarship of a student
    function revokeScholarship(address _studentAddress) public {
        onlyOwner();
        require(merchantOrStudent[_studentAddress] == bytes32(STUDENT), "Address not registered as student");

        clear(_studentAddress);        
    }

    //Students can use this function to transfer credits only to registered merchants
    function spend(address _merchantAddress, uint _amount) public {
        require(merchantOrStudent[msg.sender] == bytes32(STUDENT), "Sender not registered as student");

        bytes32 merchantCategory = merchantOrStudent[_merchantAddress];
        require(uint256(merchantCategory) > 1, "Merchant not registered");

        uint256 categoryFunds = amount[msg.sender][merchantCategory];
        uint256 allFunds = amount[msg.sender][ALL];

        require(categoryFunds + allFunds >= _amount, "Insufficient funds");

        amount[_merchantAddress][ALL] += _amount;

        if (categoryFunds >= _amount) {
            amount[msg.sender][merchantCategory] -= _amount;
        } else {
            amount[msg.sender][merchantCategory] = 0;
            amount[msg.sender][ALL] -= (_amount - categoryFunds);
        }
    }

    //This function is used to see the available credits assigned.
    function checkBalance(string calldata _category) public view returns (uint) {
        bytes32 b_category = keccak256(abi.encodePacked(_category));
        require(b_category == MEAL || b_category == ACADEMICS || b_category == SPORTS || b_category == ALL, "Invalid category");

        if (merchantOrStudent[msg.sender] >= bytes32(STUDENT) || msg.sender == owner) {
            if (msg.sender == owner && b_category == ALL) {
                return credits;
            }
            return amount[msg.sender][b_category];
        }
        revert("Unauthorized access");
    }

    //This function is used to see the category under which Merchants are registered
    function showCategory() public view returns (string memory) {
        bytes32 b_category = merchantOrStudent[msg.sender];
        require(uint256(b_category) > 1, "Address not registered as merchant");

        if (b_category == MEAL) {
            return "meal";
        } else if (b_category == ACADEMICS) {
            return "academics";
        } else if (b_category == SPORTS) {
            return "sports";
        }
        revert("Unknown category");
    }

    function clear(address _addr) internal {
        merchantOrStudent[_addr] = 0;
        credits += amount[_addr][MEAL];
        credits += amount[_addr][ACADEMICS];
        credits += amount[_addr][SPORTS];
        credits += amount[_addr][ALL];
        amount[_addr][MEAL] = 0;
        amount[_addr][ACADEMICS] = 0;
        amount[_addr][SPORTS] = 0;
        amount[_addr][ALL] = 0;
    }

    function onlyOwner() internal view {
        require(msg.sender == owner, "Only owner can call this function");
    }
}
