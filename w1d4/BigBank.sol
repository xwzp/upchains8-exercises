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

    function deposit() public payable virtual {
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

    function withdraw(address user, uint256 amount) public virtual {
        require(msg.sender == admin, "Bank: only admin can withdraw");
        require(balances[user] >= amount, "Bank: insufficient balance");
        balances[user] -= amount;
        payable(user).transfer(amount);
    }
}

contract BigBank is Bank {
    address public adminContract; // 存储 Admin 合约的地址

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

    // 设置 Admin 合约地址（只能由当前 admin 调用）
    function setAdminContract(address _adminContract) public {
        require(
            msg.sender == admin,
            "BigBank: only current admin can set admin contract"
        );
        require(
            _adminContract != address(0),
            "BigBank: admin contract cannot be zero address"
        );
        adminContract = _adminContract;
    }

    modifier onlyAdminContract() {
        require(
            msg.sender == adminContract,
            "BigBank: only Admin contract can call this function"
        );
        _;
    }

    function withdraw(
        address user,
        uint256 amount
    ) public override onlyAdminContract {
        require(balances[user] >= amount, "BigBank: insufficient balance");
        balances[user] -= amount;
        payable(user).transfer(amount);
    }
}

contract Admin {
    address public owner;
    BigBank public bigBank;

    constructor(address _bigBankAddress) {
        owner = msg.sender;
        bigBank = BigBank(_bigBankAddress);
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Admin: only owner can perform this action"
        );
        _;
    }

    // Admin 合约调用 BigBank 的 withdraw 函数
    function withdraw(address user, uint256 amount) public onlyOwner {
        bigBank.withdraw(user, amount);
    }
}
