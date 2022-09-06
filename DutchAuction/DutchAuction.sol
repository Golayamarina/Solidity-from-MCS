// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract DutchAuction {
    uint private constant DURATION = 2 days;
    address payable public immutable seller;
    uint public immutable startingPrice;
    uint public immutable startAt;
    uint public immutable endsAt;
    uint public immutable discountRate;
    string public item;
    bool public stopped;

    constructor(
        uint _startingPrice,
        uint _discountRate,
        string memory _item
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        endsAt = block.timestamp + DURATION;
        require(_startingPrice >= _discountRate * DURATION, "starting price are too low");
        
        item = _item;
    }
        modifier notStopped() {
        require(!stopped, "stopped");
        _;
        }

        function getPrice() public view notStopped returns(uint) {
            uint timeElapsed = block.timestamp - startAt;
            uint discount = discountRate * timeElapsed;
            return startingPrice - discount;
        }

        function buy() external payable notStopped {
            require(block.timestamp < endsAt, "ended");
            uint price = getPrice();

            uint refund = msg.value - price;
            if(refund > 0) {
                payable(msg.sender).transfer(refund);
            }
            seller.transfer(address(this).balance);
            stopped = true;

        }




}
