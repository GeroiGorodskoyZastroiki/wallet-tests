// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Wallet {
    address public owner;

    // Структура для хранения информации о транзакциях
    struct Transaction {
        uint amount;
        uint timestamp;
    }

    // Mapping для хранения транзакций по адресам отправителей
    mapping(address => Transaction[]) public transactions;

    // Проверка на владельца
    modifier isOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    // Из-за payable становится возможным пополнением при создании (1)
    constructor() payable { 
        owner = msg.sender;
        transactions[msg.sender].push(Transaction(msg.value, block.timestamp));
    }

    // Функция для снятия всех средств (2)
    function withdrawAll() public isOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        payable(owner).transfer(balance);
    }

    // Функция для снятия конкретной суммы (3)
    function withdraw(uint amount) public isOwner {
        require(amount <= address(this).balance, "Small balance");
        payable(owner).transfer(amount);
    }

    // Функция для перевода определённой суммы (4)
    function transferTo(address payable to, uint amount) public isOwner {
        require(amount <= address(this).balance, "Small balance");
        require(to != address(0), "Wrong address");
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");
    }

    // Функция для получения текущего баланса контракта (5)
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Метод для получения всех транзакций по адресу
    function getTransactionCount(address _address) public view returns (uint256) {
        return transactions[_address].length;
    }

    // Функция для получения эфира извне (6)
    receive() external payable {
        transactions[msg.sender].push(Transaction(msg.value, block.timestamp));
    }

    // Функция для получения всех транзакций по адресу
    function getTransactionInfo(address _address, uint index) public view returns (uint, uint) {
        require(index < transactions[_address].length, "Wrong index");
        Transaction storage transaction = transactions[_address][index];
        return (transaction.timestamp, transaction.amount);
    }
}