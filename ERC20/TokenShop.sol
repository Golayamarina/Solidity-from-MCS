contract TokenSell {
    IERC20 public token;
    address owner;
    address public thisAddr = address(this);

    event Bought(address indexed buyer, uint amount);
    event Sell(address indexed seller, uint amount);

    constructor(IERC20 _token) {
        token = _token;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "you are not owner!");
        _;
    }

    function balance() public view returns(uint) {
        return thisAddr.balance;
    }

    function buy() public payable {
        require(msg.value >= _rate(), "incorrect sum!");
        uint tokensAvailable = token.balanceOff(thisAddr);
        uint tokensToBuy = msg.value / _rate();
        require(tokensToBuy <= tokensAvailable, "not enough tokens!");
        token.transfer(msg.sender, tokensToBuy);
        emit Bought(msg.sender, tokensToBuy);
    }

    function sell(uint amount) public {
        require(amount > 0, "tokens must be greater than 0");
        uint allowance = token.allowance(msg.sender, thisAddr);
        require(allowance >= amount, "wrong allowance!");
        token.transferFrom(msg.sender, thisAddr, amount);
        payable(msg.sender).transfer(amount * _rate());
        emit Sell(msg.sender, amount);
    }

    function withdraw(uint amount) public onlyOwner {
        require(amount <= balance(), "not anough funds!");
        payable(msg.sender).transfer(amount);

    }

    function _rate() private pure returns(uint) {
        return 1 ether;
    }




}
