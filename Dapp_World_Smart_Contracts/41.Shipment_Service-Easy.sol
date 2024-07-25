// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ShipmentService {

    struct Order {
        uint256 pin;
        Status status;
    }

    enum Status {
        NotOrdered,
        Dispached,
        Delivered
    }

    address private immutable i_owner;
    mapping(address => Order) private s_addressToOrder;
    mapping(address => uint) private s_totalDeliveriesCompleted;

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert();
        }
        _;
    }

    constructor() {
        i_owner = msg.sender;
    }

    //This function inititates the shipment
    function shipWithPin(address customerAddress, uint pin) external onlyOwner {
        if (pin < 1000 || pin > 9999 || customerAddress == i_owner) {
            revert();
        }
        Order storage order = s_addressToOrder[customerAddress]; 
        if (order.pin != 0) {
            revert();
        }
        order.status = Status.Dispached;
        order.pin = pin;
    }

    //This function acknowlegdes the acceptance of the delivery
    function acceptOrder(uint pin) external {
        if (msg.sender == i_owner) {
            revert();
        }
        Order storage order = s_addressToOrder[msg.sender];
        if (order.pin != pin || order.pin == 0) {
            revert();
        }
        order.status = Status.Delivered;
        order.pin = 0;
        unchecked {
            ++s_totalDeliveriesCompleted[msg.sender];
        }
    }

    //This function outputs the status of the delivery
    function checkStatus(address customerAddress) external view returns (string memory) {
        if (!(customerAddress == msg.sender || msg.sender == i_owner)) {
            revert();
        }
        Status status = s_addressToOrder[customerAddress].status; 
        if (status == Status.Dispached) {
            return "shipped";
        } else if (status == Status.Delivered) {
            return "delivered";
        } 
        return "no orders placed";
    }

    //This function outputs the total number of successful deliveries
    function totalCompletedDeliveries(address customerAddress) external view returns (uint) {
        if (!(customerAddress == msg.sender || msg.sender == i_owner)) {
            revert();
        }

        return s_totalDeliveriesCompleted[customerAddress];
    }

}