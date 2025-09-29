// spdx-license-identifier: mit
pragma solidity ^0.8.0;

import "./myerc20.sol";

contract TokenBank {
    MyERC20 public token;
    mapping(address => uint256) public balances;

    constructor(address _token) {
        token = MyERC20(_token);
    }

    function deposit(uint256 _amount) public {
        token.transferFrom(msg.sender, address(this), _amount);
        balances[msg.sender] += _amount;
    }

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        token.transfer(msg.sender, _amount);
        balances[msg.sender] -= _amount;
    }
}
