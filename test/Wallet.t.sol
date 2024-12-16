// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Wallet.sol";

contract WalletTest is Test {
    Wallet wallet;
    address owner = address(0x1234);
    address user = address(0x5678);

    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        wallet = new Wallet{value: 1 ether}();
    }

    function testInitialBalance() public {
        assertEq(wallet.getBalance(), 1 ether, "Initial balance should be 1 ether");
    }

    function testReceiveEther() public {
        uint256 amount = 1 ether;

        vm.deal(user, amount);

        vm.prank(user);

        (bool success, ) = address(wallet).call{value: amount}("");
        require(success, "Ether transfer failed");

        assertEq(wallet.getBalance(), 2 ether, "Balance should increase after receiving ether");

        uint256 transactionCount = wallet.getTransactionCount(user);
        assertEq(transactionCount, 1, "User should have 1 transaction");

        (uint256 timestamp, uint256 receivedAmount) = wallet.getTransactionInfo(user, 0);
        assertEq(receivedAmount, amount, "Transaction amount should match sent value");
        assertTrue(timestamp > 0, "Transaction timestamp should be set");
    }

    function testWithdrawAll() public {
        vm.prank(owner);
        wallet.withdrawAll();

        assertEq(wallet.getBalance(), 0, "Balance should be 0 after withdrawAll");
    }

    function testWithdraw() public {
        uint256 amount = 0.5 ether;

        vm.prank(owner);
        wallet.withdraw(amount);

        assertEq(wallet.getBalance(), 0.5 ether, "Balance should decrease by the amount withdrawn");
    }

    function testTransferTo() public {
        uint256 amount = 0.5 ether;

        vm.prank(owner);
        wallet.transferTo(payable(user), amount);

        assertEq(wallet.getBalance(), 0.5 ether, "Balance should decrease by the amount transferred");
        assertEq(user.balance, amount, "Recipient should receive the transferred amount");
    }
}
