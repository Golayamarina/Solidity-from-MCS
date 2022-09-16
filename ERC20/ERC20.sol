// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0. 8. 0;

interface IERC20 {
    function decimals() external pure returns(uint);
    function totalSupply() external view returns(uint);
    function balanceOff(address account) external view returns(uint);
    function transfer(address to, uint amount) external; //returns(bool);
    function allowance(address owner, address spender) external view returns(uint);
    function approve(address spender, uint amount) external;
    function transferFrom(address spender, address recepient, uint amount) external;
    
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed to, uint amount);
}

contract ERC20 is IERC20 {
    uint totalTokens;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    string public name = "GilToken";
    string public symbol = "GTK";

    constructor (uint initionalSupply) {
        mint(initionalSupply);
    }

    modifier enoughTokens(address _from, uint _amount) {
        require(balanceOff(_from) >= _amount, "not enough tokens!");
        _;
    }


    function decimals() public pure override returns(uint) {
        return 0;
    }
    
    function totalSupply() public view override returns(uint) {
        return totalTokens;
    }

    function balanceOff(address account) public view override returns(uint) {
        return balances[account];
    }

    function transfer(address to, uint amount) external override enoughTokens(msg.sender, amount) {
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function allowance(address owner, address spender) external view override returns(uint) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint amount) external override {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    function transferFrom(address sender, address recepient, uint amount) public override enoughTokens(sender, amount) {
        allowances[sender][recepient] -= amount;
        balances[sender] -= amount;
        balances[recepient] += amount;
        emit Transfer(sender, recepient, amount);
    } 


    function mint(uint amount) public {
        balances[msg.sender] += amount;
        totalTokens += amount;
        emit Transfer(address(0), msg.sender, amount);
    } 

    function burn(uint amount) public enoughTokens(msg.sender, amount) {
        balances[msg.sender] -= amount;
        totalTokens -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    fallback() external payable {

    }

    receive() external payable {

    }

}
