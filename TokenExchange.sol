// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.17;

contract Exchange{

    address public owner;
    mapping(address => mapping(address => uint)) public balances;
    mapping(address => bool) public authorizedTokens;
    uint public fee = 0.1 ether;

    event Deposit(address indexed token, address indexed user, uint256 amount);
    event Withdraw(address indexed token, address indexed user, uint256 amount);
    event Trade(address indexed token, address indexed buyer, address indexed seller, uint256 price);

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "NOT OWNER!");
        _;
    }

    function deposit(address token, uint256 amount) public{
        require(authorizedTokens[token],"Not Authorized Token!");
        require(amount > 0, "Amount Should be Greater than Zero!");

        balances[token][msg.sender] += amount;
        emit Deposit(token,msg.sender,amount);
    }

    function withdraw(address token, uint256 amount) public{
        require(balances[token][msg.sender] >= amount,"Not Enough Balance!");
        balances[token][msg.sender] -= amount;

        emit Withdraw(token,msg.sender,amount);

       
    }

    function authorizeToken(address token) public onlyOwner{
            authorizedTokens[token] = true;
        }

    function revokeToken(address token) public onlyOwner{
            authorizedTokens[token] = false;
        }

    function setFee(uint _newFee) public onlyOwner{
        fee = _newFee;
    }


    function trade(address token, address seller, uint256 amount, uint256 price) payable public{
        require(msg.value == fee, "Insufficient fee!");
        require(balances[token][seller] >= amount, "Insufficient Amount");
        require(balances[address(this)][msg.sender] >= amount * price, "Insufficient Balance!");


        balances[token][seller] -= amount;
        balances[token][msg.sender] += amount;
        balances[address(this)][msg.sender] -= amount * price;
        balances[address(this)][seller] += amount * price;

        emit Trade(token, msg.sender, seller, amount);
    }
}
