// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "hardhat/console.sol";
abstract contract IBank {
    function deposit() public payable virtual;
    function withdraw(address user, uint256 amount) public virtual;
}

contract Bank is IBank {
    address public admin;
    mapping(address => uint256) public balances;
    // 记录存款金额前 3 名的用户
    address[3] public topDepositors;

    event Deposited(address indexed user, uint256 amount, uint256 timestamp);

    constructor() {
        admin = msg.sender;
    }

    function deposit() public payable virtual override {
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

    function withdraw(address user, uint256 amount) public virtual override {
        require(msg.sender == admin, "Bank: only admin can withdraw");
        require(balances[user] >= amount, "Bank: insufficient balance");
        balances[user] -= amount;
        payable(user).transfer(amount);
    }
}

contract BigBank is Bank {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier minAmount() {
        require(
            msg.value > 0.001 ether,
            "BigBank: deposit amount must be greater than 0.001 ether"
        );
        _;
    }

    function deposit() public payable override minAmount {
        // 调用父合约的 deposit 函数
        super.deposit();
    }

    function setAdmin(address _admin) public {
        require(
            msg.sender == owner,
            "BigBank: only current ownercan set admin contract"
        );
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "BigBank: only Admin contract can call this function"
        );
        _;
    }

    function withdraw(address user, uint256 amount) public override onlyAdmin {
        // 如果 user 是 admin，则提取所有余额
        if (user == admin) {
            amount = address(this).balance;
        } else {
            balances[user] -= amount;
        }
        payable(user).transfer(amount);
    }
}

contract Admin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Admin: only owner can perform this action"
        );
        _;
    }

    // Admin 合约调用 BigBank 的 withdraw 函数
    function adminWithdraw(IBank bank) public onlyOwner {
        // log balance
        console.log("balance", address(bank).balance);
        bank.withdraw(msg.sender, address(bank).balance);
    }

    receive() external payable {}
}
