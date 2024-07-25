// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    mapping(address => Order[]) private s_addressToOrder;
    mapping(address => uint[2]) private s_addressToDeliveries; 

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
        s_addressToOrder[customerAddress].push(Order(pin, Status.Dispached)); 
        unchecked {
            ++s_addressToDeliveries[customerAddress][1];
        }
        
    }
    //This function acknowlegdes the acceptance of the delivery
    function acceptOrder(uint pin) external {
        if (msg.sender == i_owner) {
            revert();
        }
        bool exists;
        Order[] memory orders = s_addressToOrder[msg.sender];
        uint256 length = orders.length;
        for (uint i; i < length;) {
            if (orders[i].pin == pin) {
                Order storage order = s_addressToOrder[msg.sender][i];
                order.status = Status.Delivered;
                order.pin = 0;
                exists = true;
                uint[2] storage arr = s_addressToDeliveries[msg.sender];
                unchecked {
                    ++arr[0];
                    --arr[1];
                }
                break;
            }
            unchecked {
                ++i;
            }
        }
        if (!exists) {
            revert();
        }
    }

    //This function outputs the status of the delivery
    function checkStatus(address customerAddress) external view returns (uint) {
        if (!(customerAddress == msg.sender || msg.sender == i_owner)) {
            revert();
        }
        return s_addressToDeliveries[customerAddress][1];
    }

    //This function outputs the total number of successful deliveries
    function totalCompletedDeliveries(address customerAddress) external view returns (uint) {
        if (!(customerAddress == msg.sender || msg.sender == i_owner)) {
            revert();
        }

        return s_addressToDeliveries[customerAddress][0];
    }
}