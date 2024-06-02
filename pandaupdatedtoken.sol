// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Coin {
    address public minter;
    uint256 public totalSupply;
    uint256 public supplyCap;
    bool public paused = false;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    event Sent(address from, address to, uint256 amount);
    event Minted(address receiver, uint256 amount);
    event Burned(address burner, uint256 amount);
    event OwnershipTransferred(address oldMinter, address newMinter);
    event Paused();
    event Unpaused();
    event Approval(address owner, address spender, uint256 amount);

    error insufficientBalance(uint256 requested, uint256 available);
    error notAuthorized();
    error contractPaused();
    error supplyCapExceeded(uint256 requested, uint256 available);

    constructor(uint256 _supplyCap) {
        minter = msg.sender;
        supplyCap = _supplyCap;
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Only minter can call this function");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function mint(address receiver, uint256 amount) public onlyMinter whenNotPaused {
        if (totalSupply + amount > supplyCap) {
            revert supplyCapExceeded({
                requested: totalSupply + amount,
                available: supplyCap
            });
        }

        balances[receiver] += amount;
        totalSupply += amount;
        emit Minted(receiver, amount);
    }

    function burn(uint256 amount) public whenNotPaused {
        if (amount > balances[msg.sender]) {
            revert insufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });
        }

        balances[msg.sender] -= amount;
        totalSupply -= amount;
        emit Burned(msg.sender, amount);
    }

    function send(address receiver, uint256 amount) public whenNotPaused {
        if (amount > balances[msg.sender]) {
            revert insufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });
        }

        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }

    function transferOwnership(address newMinter) public onlyMinter {
        require(newMinter != address(0), "New minter cannot be the zero address");
        emit OwnershipTransferred(minter, newMinter);
        minter = newMinter;
    }

    function pause() public onlyMinter {
        paused = true;
        emit Paused();
    }

    function unpause() public onlyMinter {
        paused = false;
        emit Unpaused();
    }

    function approve(address spender, uint256 amount) public whenNotPaused returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address receiver, uint256 amount) public whenNotPaused returns (bool) {
        if (amount > balances[sender]) {
            revert insufficientBalance({
                requested: amount,
                available: balances[sender]
            });
        }

        if (amount > allowances[sender][msg.sender]) {
            revert notAuthorized();
        }

        balances[sender] -= amount;
        balances[receiver] += amount;
        allowances[sender][msg.sender] -= amount;
        emit Sent(sender, receiver, amount);
        return true;
    }
}
