// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract Bank {
    address public admin;
    mapping(address => uint256) public balances;
    // 记录存款金额前 3 名的用户
    address[3] public topDepositors;

    event Deposited(address indexed user, uint256 amount, uint256 timestamp);

    constructor() {
        admin = msg.sender;
    }

    function deposit() public payable {
        require(msg.value > 0, "Bank: deposit amount must be greater than 0");

        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value, block.timestamp);

        // update top depositors
        for (uint256 i = 0; i < 3; i++) {
            if (balances[msg.sender] > balances[topDepositors[i]]) {
                for (uint256 j = 2; j > i; j--) {
                    topDepositors[j] = topDepositors[j - 1];
                }
                topDepositors[i] = msg.sender;
                break;
            }
        }
    }

    function withdraw(address user, uint256 amount) public {
        require(msg.sender == admin, "Bank: only admin can withdraw");
        require(balances[user] >= amount, "Bank: insufficient balance");
        balances[user] -= amount;
        payable(user).transfer(amount);
    }
}
