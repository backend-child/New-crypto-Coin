// SPDX-License-Identifier: MIT
// This is where our code is going to go

pragma solidity >=0.7.0 <0.9.0;

// we want to allow only the creator to create new coins
// any body can send coin to each other without need for username or password

contract Coin {
    address public minter;
    mapping(address => uint256) public balances;
    event Sent(address from, address to, uint256 amount);

    // contructor would only be called when the contract is deployed
    constructor() {
        minter = msg.sender;
    }

    // creating a function for minting coins
    // we want to make new coins and send them to an address
    // we want to make sure that only the owner can send this coins

    function mint(address receiver, uint256 amount) public {
        require(msg.sender == minter);
        // now to actually make the coins or mint to say
        balances[receiver] += amount;
    }

    // now lets create a function that can allow us to send any amount of coin
    // to an existing address

    error insufficientBalance(uint256 requested, uint256 available);

    function send(address receiver, uint256 amount) public {
        // here we want to create a logic to check if a person actually has the needed
        // balancess to send or recieve a token

        if (amount > balances[msg.sender])
            revert insufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });

        balances[msg.sender] -= amount;
        balances[receiver] += amount;
    }
}
