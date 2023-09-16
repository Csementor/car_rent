// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BurnableToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer( address indexed from ,address  indexed to , uint256 value);
    event Burn(address indexed burner, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
        
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10**uint256(_decimals);
        balances[msg.sender] = totalSupply;
        
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }

     function transfer(address _to, uint256 _value) external  returns(bool){
        require(_value > 0, "Amount must be greater than 0");
        require(_value <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    } 

    function burn(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        require(_amount <= balances[msg.sender], "Insufficient balance");
        
        totalSupply -= _amount;
        emit Burn(msg.sender, _amount);
    }
}
