// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract EnglishAuction {
    string public item;
    address payable public immutable seller;
    uint public endAt;
    bool public started;
    bool public ended;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bids;

    event Start(string _item, uint _currentPrice);
    event Bid(address _bidder, uint _bid);
    event End(address _highestBidder, uint _highestBid);
    event Withdraw(address _sender, uint _amount);

    constructor(string memory _item, uint _startingBid) {
        item = _item;
        highestBid = _startingBid;
        seller = payable(msg.sender);
    }

    modifier onlySeller {
        require(msg.sender == seller, "you are not seller");
        _;
    }

    modifier hasStarted {
        require(started, "has not started yet");
        _;
    }

    modifier notEnded {
        require(block.timestamp < endAt, "has ended");
        _;
    }

    function start() external onlySeller {
        require(!started, "has already started!");

        started = true;
        endAt = block.timestamp + 70;
        emit Start(item, highestBid);
    }

    function bid() external payable hasStarted notEnded {
        require(msg.value > highestBid, "too low money");
        
        if(highestBidder != address(0)) {
        bids[highestBidder] += highestBid;
        }
        highestBid = msg.value;
        highestBidder = msg.sender;
        emit Bid(msg.sender, msg.value);
    }
    
     function end() external hasStarted {
         require(!ended, "already ended");
         require(block.timestamp >= endAt, "can't stop auction yet");
         ended = true;
         if(highestBidder != address(0)) {
             seller.transfer(highestBid);
         }
         emit End(highestBidder, highestBid);
     }

     function withdraw() external {
         uint refundAmount = bids[msg.sender];
         require(refundAmount > 0, "incorrect refund amount");
         bids[msg.sender] = 0;
         payable(msg.sender).transfer(refundAmount);
         emit Withdraw(msg.sender, refundAmount);
     }

}

