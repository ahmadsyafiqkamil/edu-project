// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract MockERC20Test is Test {
    MockERC20 public token;
    address public deployer;
    address public user1;
    address public user2;

    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 1e6; // 1 million with 6 decimals
    uint256 public constant MINT_AMOUNT = 100_000 * 1e6;

    function setUp() public {
        deployer = address(this);
        user1 = address(0x1);
        user2 = address(0x2);

        token = new MockERC20("USD Coin", "USDC", 6, INITIAL_SUPPLY);
    }

    // =================================================================
    //                           Constructor Tests
    // =================================================================

    function test_Constructor_SetsNameAndSymbol() public {
        assertEq(token.name(), "USD Coin");
        assertEq(token.symbol(), "USDC");
    }

    function test_Constructor_SetsDecimals() public {
        assertEq(token.decimals(), 6);
    }

    function test_Constructor_MintsInitialSupply() public {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY);
    }

    function test_Constructor_DifferentDecimals() public {
        MockERC20 token18 = new MockERC20("Test Token", "TEST", 18, 1000 * 1e18);
        assertEq(token18.decimals(), 18);
        assertEq(token18.totalSupply(), 1000 * 1e18);
    }

    // =================================================================
    //                           Mint Tests
    // =================================================================

    function test_Mint_ToUser() public {
        token.mint(user1, MINT_AMOUNT);

        assertEq(token.balanceOf(user1), MINT_AMOUNT);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + MINT_AMOUNT);
    }

    function test_Mint_ToDeployer() public {
        uint256 balanceBefore = token.balanceOf(deployer);
        token.mint(deployer, MINT_AMOUNT);

        assertEq(token.balanceOf(deployer), balanceBefore + MINT_AMOUNT);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + MINT_AMOUNT);
    }

    function test_Mint_MultipleTimes() public {
        token.mint(user1, MINT_AMOUNT);
        token.mint(user2, MINT_AMOUNT);
        token.mint(user1, MINT_AMOUNT / 2);

        assertEq(token.balanceOf(user1), MINT_AMOUNT + MINT_AMOUNT / 2);
        assertEq(token.balanceOf(user2), MINT_AMOUNT);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + MINT_AMOUNT * 2 + MINT_AMOUNT / 2);
    }

    function test_Mint_ZeroAmount() public {
        token.mint(user1, 0);

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function test_Mint_LargeAmount() public {
        uint256 largeAmount = 1_000_000_000 * 1e6; // 1 billion
        token.mint(user1, largeAmount);

        assertEq(token.balanceOf(user1), largeAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + largeAmount);
    }

    // =================================================================
    //                           ERC20 Standard Tests
    // =================================================================

    function test_Transfer_Success() public {
        uint256 transferAmount = 10_000 * 1e6;
        token.transfer(user1, transferAmount);

        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY - transferAmount);
        assertEq(token.balanceOf(user1), transferAmount);
    }

    function test_Transfer_RevertsIfInsufficientBalance() public {
        vm.expectRevert();
        token.transfer(user1, INITIAL_SUPPLY + 1);
    }

    function test_TransferFrom_Success() public {
        uint256 transferAmount = 10_000 * 1e6;
        
        vm.startPrank(deployer);
        token.approve(user1, transferAmount);
        vm.stopPrank();

        vm.prank(user1);
        token.transferFrom(deployer, user2, transferAmount);

        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY - transferAmount);
        assertEq(token.balanceOf(user2), transferAmount);
    }

    function test_TransferFrom_RevertsIfInsufficientAllowance() public {
        uint256 transferAmount = 10_000 * 1e6;
        
        vm.startPrank(deployer);
        token.approve(user1, transferAmount - 1);
        vm.stopPrank();

        vm.prank(user1);
        vm.expectRevert();
        token.transferFrom(deployer, user2, transferAmount);
    }

    function test_Approve_Success() public {
        uint256 allowanceAmount = 50_000 * 1e6;
        token.approve(user1, allowanceAmount);

        assertEq(token.allowance(deployer, user1), allowanceAmount);
    }

    function test_Approve_CanIncreaseAllowance() public {
        uint256 firstAllowance = 10_000 * 1e6;
        uint256 secondAllowance = 20_000 * 1e6;

        token.approve(user1, firstAllowance);
        assertEq(token.allowance(deployer, user1), firstAllowance);

        token.approve(user1, secondAllowance);
        assertEq(token.allowance(deployer, user1), secondAllowance);
    }

    // =================================================================
    //                           Integration Tests
    // =================================================================

    function test_FullCycle_MintTransferApprove() public {
        // Mint to user1
        token.mint(user1, MINT_AMOUNT);
        assertEq(token.balanceOf(user1), MINT_AMOUNT);

        // Transfer from user1 to user2
        vm.prank(user1);
        token.transfer(user2, MINT_AMOUNT / 2);
        assertEq(token.balanceOf(user1), MINT_AMOUNT / 2);
        assertEq(token.balanceOf(user2), MINT_AMOUNT / 2);

        // Approve and transferFrom
        vm.prank(user1);
        token.approve(deployer, MINT_AMOUNT / 2);
        
        token.transferFrom(user1, user2, MINT_AMOUNT / 2);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), MINT_AMOUNT);
    }

    function test_MultipleUsers_MintAndTransfer() public {
        // Mint to multiple users
        token.mint(user1, MINT_AMOUNT);
        token.mint(user2, MINT_AMOUNT * 2);

        assertEq(token.balanceOf(user1), MINT_AMOUNT);
        assertEq(token.balanceOf(user2), MINT_AMOUNT * 2);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + MINT_AMOUNT * 3);

        // Transfer between users
        vm.prank(user2);
        token.transfer(user1, MINT_AMOUNT);

        assertEq(token.balanceOf(user1), MINT_AMOUNT * 2);
        assertEq(token.balanceOf(user2), MINT_AMOUNT);
    }
}



