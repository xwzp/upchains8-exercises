// spdx-license-identifier: mit
pragma solidity ^0.8.0;

import "./myerc20.sol";

contract TokenBank {
    MyERC20 public immutable token;
    mapping(address => uint256) public balances;

    constructor(address _token) {
        token = MyERC20(_token);
    }

    function deposit(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0");
        balances[msg.sender] += _amount;
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
    }

    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        require(token.transfer(msg.sender, _amount), "Transfer failed");
        balances[msg.sender] -= _amount;
    }
}
