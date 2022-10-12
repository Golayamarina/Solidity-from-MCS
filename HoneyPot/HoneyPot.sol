// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Bank {
    ILogger private logger;
    mapping(address => uint) private _balances;

    constructor(address _logger) {
        logger = ILogger(_logger);
    }

    function deposit() external payable {
        _balances[msg.sender] = msg.value;
        logger.log(msg.sender, 1);
    }

    function withdraw(uint amount) external {
        _balances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);

        logger.log(msg.sender, 2);
    }
}

interface ILogger {
    event Log(address indexed initiator, uint indexed eventCode);
    function log(address initiator, uint eventCode) external;
}

contract Logger is ILogger {
    function log(address initiator, uint eventCode) external {
        emit Log(initiator, eventCode);
    }
}

contract HoneyPot is ILogger {
    function log(address, uint eventCode) external pure{
        if(eventCode == 2) {
            revert("honeypoted");
        }
    }
}
