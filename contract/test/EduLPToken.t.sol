// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {EduLPToken} from "../src/EduLPToken.sol";

contract EduLPTokenTest is Test {
    EduLPToken public eduLPToken;
    address public owner;
    address public loanPlatform;
    address public user1;
    address public user2;

    event EduLPTokenMinted(address indexed to, uint256 amount);
    event EduLPTokenBurned(address indexed from, uint256 amount);

    function setUp() public {
        owner = address(this);
        loanPlatform = address(0x123);
        user1 = address(0x1);
        user2 = address(0x2);

        eduLPToken = new EduLPToken(owner);
    }

    // =================================================================
    //                           Constructor Tests
    // =================================================================

    function test_Constructor_SetsNameAndSymbol() public view {
        assertEq(eduLPToken.name(), "Education LP Token");
        assertEq(eduLPToken.symbol(), "eduLP");
    }

    function test_Constructor_SetsOwner() public view {
        assertEq(eduLPToken.owner(), owner);
    }

    function test_Constructor_InitialSupplyIsZero() public view {
        assertEq(eduLPToken.totalSupply(), 0);
    }

    // =================================================================
    //                           setLoanPlatform Tests
    // =================================================================

    function test_SetLoanPlatform_OnlyOwner() public {
        eduLPToken.setLoanPlatform(loanPlatform);
        assertEq(eduLPToken.loanPlatform(), loanPlatform);
    }

    function test_SetLoanPlatform_RevertsIfNotOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        eduLPToken.setLoanPlatform(loanPlatform);
    }

    function test_SetLoanPlatform_RevertsIfZeroAddress() public {
        vm.expectRevert("Invalid address");
        eduLPToken.setLoanPlatform(address(0));
    }

    function test_SetLoanPlatform_RevertsIfAlreadySet() public {
        eduLPToken.setLoanPlatform(loanPlatform);
        vm.expectRevert("already set");
        eduLPToken.setLoanPlatform(address(0x456));
    }

    // =================================================================
    //                           Mint Tests
    // =================================================================

    function test_Mint_OnlyLoanPlatform() public {
        eduLPToken.setLoanPlatform(loanPlatform);
        
        vm.prank(loanPlatform);
        eduLPToken.mint(user1, 1000e18);
        
        assertEq(eduLPToken.balanceOf(user1), 1000e18);
        assertEq(eduLPToken.totalSupply(), 1000e18);
    }

    function test_Mint_RevertsIfNotLoanPlatform() public {
        eduLPToken.setLoanPlatform(loanPlatform);
        
        vm.prank(user1);
        vm.expectRevert("EduLPToken: Only loan platform can call");
        eduLPToken.mint(user1, 1000e18);
    }

    function test_Mint_RevertsIfLoanPlatformNotSet() public {
        vm.prank(loanPlatform);
        vm.expectRevert("EduLPToken: Only loan platform can call");
        eduLPToken.mint(user1, 1000e18);
    }

    function test_Mint_EmitsEvent() public {
        eduLPToken.setLoanPlatform(loanPlatform);
        
        vm.expectEmit(true, false, false, true);
        emit EduLPTokenMinted(user1, 1000e18);
        
        vm.prank(loanPlatform);
        eduLPToken.mint(user1, 1000e18);
    }

    function test_Mint_MultipleTimes() public {
        eduLPToken.setLoanPlatform(loanPlatform);
        
        vm.startPrank(loanPlatform);
        eduLPToken.mint(user1, 1000e18);
        eduLPToken.mint(user2, 2000e18);
        eduLPToken.mint(user1, 500e18);
        vm.stopPrank();
        
        assertEq(eduLPToken.balanceOf(user1), 1500e18);
        assertEq(eduLPToken.balanceOf(user2), 2000e18);
        assertEq(eduLPToken.totalSupply(), 3500e18);
    }

    // =================================================================
    //                           Burn Tests
    // =================================================================

    function test_Burn_OnlyLoanPlatform() public {
        eduLPToken.setLoanPlatform(loanPlatform);
        
        vm.startPrank(loanPlatform);
        eduLPToken.mint(user1, 1000e18);
        eduLPToken.burn(user1, 500e18);
        vm.stopPrank();
        
        assertEq(eduLPToken.balanceOf(user1), 500e18);
        assertEq(eduLPToken.totalSupply(), 500e18);
    }

    function test_Burn_RevertsIfNotLoanPlatform() public {
        eduLPToken.setLoanPlatform(loanPlatform);
        
        vm.prank(loanPlatform);
        eduLPToken.mint(user1, 1000e18);
        
        vm.prank(user1);
        vm.expectRevert("EduLPToken: Only loan platform can call");
        eduLPToken.burn(user1, 500e18);
    }

    function test_Burn_EmitsEvent() public {
        eduLPToken.setLoanPlatform(loanPlatform);
        
        vm.startPrank(loanPlatform);
        eduLPToken.mint(user1, 1000e18);
        
        vm.expectEmit(true, false, false, true);
        emit EduLPTokenBurned(user1, 500e18);
        
        eduLPToken.burn(user1, 500e18);
        vm.stopPrank();
    }

    function test_Burn_AllTokens() public {
        eduLPToken.setLoanPlatform(loanPlatform);
        
        vm.startPrank(loanPlatform);
        eduLPToken.mint(user1, 1000e18);
        eduLPToken.burn(user1, 1000e18);
        vm.stopPrank();
        
        assertEq(eduLPToken.balanceOf(user1), 0);
        assertEq(eduLPToken.totalSupply(), 0);
    }

    // =================================================================
    //                           Decimals Tests
    // =================================================================

    function test_Decimals_Returns18() public view {
        assertEq(eduLPToken.decimals(), 18);
    }

    // =================================================================
    //                           RemainingSupply Tests
    // =================================================================

    function test_RemainingSupply_WhenEmpty() public view {
        uint256 remaining = eduLPToken.remainingSupply();
        assertEq(remaining, type(uint256).max);
    }

    function test_RemainingSupply_AfterMint() public {
        eduLPToken.setLoanPlatform(loanPlatform);
        
        vm.prank(loanPlatform);
        eduLPToken.mint(user1, 1000e18);
        
        uint256 remaining = eduLPToken.remainingSupply();
        assertEq(remaining, type(uint256).max - 1000e18);
    }

    function test_RemainingSupply_AfterBurn() public {
        eduLPToken.setLoanPlatform(loanPlatform);
        
        vm.startPrank(loanPlatform);
        eduLPToken.mint(user1, 1000e18);
        eduLPToken.burn(user1, 500e18);
        vm.stopPrank();
        
        uint256 remaining = eduLPToken.remainingSupply();
        assertEq(remaining, type(uint256).max - 500e18);
    }

    // =================================================================
    //                           Integration Tests
    // =================================================================

    function test_FullCycle_MintAndBurn() public {
        eduLPToken.setLoanPlatform(loanPlatform);
        
        vm.startPrank(loanPlatform);
        // Mint to multiple users
        eduLPToken.mint(user1, 1000e18);
        eduLPToken.mint(user2, 2000e18);
        
        assertEq(eduLPToken.totalSupply(), 3000e18);
        
        // Burn from user1
        eduLPToken.burn(user1, 500e18);
        
        assertEq(eduLPToken.balanceOf(user1), 500e18);
        assertEq(eduLPToken.balanceOf(user2), 2000e18);
        assertEq(eduLPToken.totalSupply(), 2500e18);
        vm.stopPrank();
    }
}

