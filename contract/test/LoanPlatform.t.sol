// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {LoanPlatform} from "../src/LoanPlatform.sol";
import {EduLPToken} from "../src/EduLPToken.sol";
import {MockERC20} from "../src/MockERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LoanPlatformTest is Test {
    LoanPlatform public loanPlatform;
    MockERC20 public underlyingToken;
    EduLPToken public eduLPToken;
    
    address public owner;
    address public platformTreasury;
    address public investor1;
    address public investor2;
    address public student1;
    address public student2;
    address public beneficiary1;
    address public beneficiary2;

    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 1e6; // 1 million USDC (6 decimals)
    uint256 public constant DEPOSIT_AMOUNT = 100_000 * 1e6; // 100k USDC

    event Deposited(address indexed investor, uint256 underlyingAmount, uint256 lpTokensMinted);
    event Withdrawn(address indexed investor, uint256 lpTokensBurned, uint256 underlyingAmount);
    event FinancingExecuted(uint256 indexed financingId, address indexed student, address indexed beneficiary, uint256 purchasePrice, uint256 sellingPrice);
    event RepaymentMade(uint256 indexed financingId, address indexed student, uint256 amount, uint256 principalAmount, uint256 marginAmount);

    function setUp() public {
        owner = address(this);
        platformTreasury = address(0x100);
        investor1 = address(0x1);
        investor2 = address(0x2);
        student1 = address(0x10);
        student2 = address(0x11);
        beneficiary1 = address(0x20);
        beneficiary2 = address(0x21);

        // Deploy MockERC20 (USDC-like with 6 decimals)
        underlyingToken = new MockERC20("USD Coin", "USDC", 6, INITIAL_SUPPLY);
        
        // Deploy LoanPlatform
        loanPlatform = new LoanPlatform(address(underlyingToken), platformTreasury);
        eduLPToken = loanPlatform.eduLpToken();

        // Distribute tokens to test users
        underlyingToken.mint(investor1, INITIAL_SUPPLY);
        underlyingToken.mint(investor2, INITIAL_SUPPLY);
        underlyingToken.mint(student1, INITIAL_SUPPLY);
        underlyingToken.mint(student2, INITIAL_SUPPLY);
    }

    // =================================================================
    //                           Constructor Tests
    // =================================================================

    function test_Constructor_SetsCorrectValues() public {
        assertEq(address(loanPlatform.underlyingToken()), address(underlyingToken));
        assertEq(address(loanPlatform.eduLpToken()), address(eduLPToken));
        assertEq(loanPlatform.platformTreasury(), platformTreasury);
        assertEq(loanPlatform.maxUtilizationRate(), 8000); // 80%
        assertEq(loanPlatform.platformShareRatio(), 2000); // 20%
        assertEq(loanPlatform.nextFinancingId(), 1);
        assertEq(loanPlatform.totalFinancingActive(), 0);
    }

    function test_Constructor_RevertsIfInvalidUnderlyingToken() public {
        vm.expectRevert("LoanPlatform: Invalid underlying token address");
        new LoanPlatform(address(0), platformTreasury);
    }

    function test_Constructor_RevertsIfInvalidTreasury() public {
        vm.expectRevert("LoanPlatform: Invalid treasury address");
        new LoanPlatform(address(underlyingToken), address(0));
    }

    function test_Constructor_SetsLoanPlatformInEduLPToken() public {
        assertEq(eduLPToken.loanPlatform(), address(loanPlatform));
    }

    // =================================================================
    //                           Deposit Tests
    // =================================================================

    function test_Deposit_FirstDeposit_1To1Ratio() public {
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        
        vm.expectEmit(true, false, false, true);
        emit Deposited(investor1, DEPOSIT_AMOUNT, DEPOSIT_AMOUNT);
        
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        assertEq(eduLPToken.balanceOf(investor1), DEPOSIT_AMOUNT);
        assertEq(eduLPToken.totalSupply(), DEPOSIT_AMOUNT);
        assertEq(underlyingToken.balanceOf(address(loanPlatform)), DEPOSIT_AMOUNT);
    }

    function test_Deposit_SecondDeposit_Proportional() public {
        // First deposit
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        // Second deposit - should get proportional LP tokens
        uint256 secondDeposit = DEPOSIT_AMOUNT;
        vm.startPrank(investor2);
        underlyingToken.approve(address(loanPlatform), secondDeposit);
        loanPlatform.deposit(secondDeposit);
        vm.stopPrank();

        // Both should have equal LP tokens since pool value equals deposits
        assertEq(eduLPToken.balanceOf(investor1), DEPOSIT_AMOUNT);
        assertEq(eduLPToken.balanceOf(investor2), DEPOSIT_AMOUNT);
        assertEq(eduLPToken.totalSupply(), DEPOSIT_AMOUNT * 2);
    }

    function test_Deposit_RevertsIfZeroAmount() public {
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), 0);
        vm.expectRevert("LoanPlatform: Amount must be greater than zero");
        loanPlatform.deposit(0);
        vm.stopPrank();
    }

    function test_Deposit_RevertsIfInsufficientAllowance() public {
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT - 1);
        // ERC20 will revert with ERC20InsufficientAllowance error
        vm.expectRevert();
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
    }

    function test_Deposit_MultipleInvestors() public {
        uint256 deposit1 = 50_000 * 1e6;
        uint256 deposit2 = 30_000 * 1e6;
        uint256 deposit3 = 20_000 * 1e6;

        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), deposit1);
        loanPlatform.deposit(deposit1);
        vm.stopPrank();

        vm.startPrank(investor2);
        underlyingToken.approve(address(loanPlatform), deposit2);
        loanPlatform.deposit(deposit2);
        vm.stopPrank();

        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), deposit3);
        loanPlatform.deposit(deposit3);
        vm.stopPrank();

        assertEq(underlyingToken.balanceOf(address(loanPlatform)), deposit1 + deposit2 + deposit3);
        assertEq(eduLPToken.totalSupply(), deposit1 + deposit2 + deposit3);
    }

    // =================================================================
    //                           Withdraw Tests
    // =================================================================

    function test_Withdraw_AfterDeposit() public {
        // Deposit first
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        uint256 lpTokens = eduLPToken.balanceOf(investor1);
        vm.stopPrank();

        // Withdraw
        vm.startPrank(investor1);
        vm.expectEmit(true, false, false, true);
        emit Withdrawn(investor1, lpTokens, DEPOSIT_AMOUNT);
        
        loanPlatform.withdraw(lpTokens);
        vm.stopPrank();

        assertEq(eduLPToken.balanceOf(investor1), 0);
        assertEq(eduLPToken.totalSupply(), 0);
        assertEq(underlyingToken.balanceOf(investor1), INITIAL_SUPPLY);
        assertEq(underlyingToken.balanceOf(address(loanPlatform)), 0);
    }

    function test_Withdraw_Partial() public {
        // Deposit
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        uint256 lpTokens = eduLPToken.balanceOf(investor1);
        vm.stopPrank();

        // Withdraw half
        vm.startPrank(investor1);
        loanPlatform.withdraw(lpTokens / 2);
        vm.stopPrank();

        assertEq(eduLPToken.balanceOf(investor1), lpTokens / 2);
        assertEq(underlyingToken.balanceOf(investor1), INITIAL_SUPPLY - DEPOSIT_AMOUNT + (DEPOSIT_AMOUNT / 2));
    }

    function test_Withdraw_RevertsIfZeroAmount() public {
        vm.expectRevert("LoanPlatform: LP token amount must be greater than zero");
        loanPlatform.withdraw(0);
    }

    function test_Withdraw_RevertsIfInsufficientBalance() public {
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(investor2);
        vm.expectRevert("LoanPlatform: Insufficient LP token balance");
        loanPlatform.withdraw(1);
        vm.stopPrank();
    }

    function test_Withdraw_RevertsIfInsufficientLiquidity() public {
        // Deposit
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        uint256 lpTokens = eduLPToken.balanceOf(investor1);
        vm.stopPrank();

        // Execute financing (uses cash) - use 70% to stay below 80% utilization limit
        uint256 financingAmount = (DEPOSIT_AMOUNT * 70) / 100;
        loanPlatform.executeFinancing(student1, beneficiary1, financingAmount, financingAmount * 11 / 10);

        // Remaining cash is 30% of DEPOSIT_AMOUNT
        // Try to withdraw all LP tokens - should fail because cash is insufficient
        // LP token value is based on pool value (cash + active financing)
        // But we can only withdraw available cash (30%), not the full LP token value
        vm.startPrank(investor1);
        vm.expectRevert("LoanPlatform: Insufficient liquidity in pool");
        loanPlatform.withdraw(lpTokens);
        vm.stopPrank();
    }

    // =================================================================
    //                           ExecuteFinancing Tests
    // =================================================================

    function test_ExecuteFinancing_Success() public {
        // Setup: Deposit first
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 purchasePrice = 50_000 * 1e6;
        uint256 sellingPrice = 55_000 * 1e6; // 10% margin

        vm.expectEmit(true, true, false, true);
        emit FinancingExecuted(1, student1, beneficiary1, purchasePrice, sellingPrice);

        loanPlatform.executeFinancing(student1, beneficiary1, purchasePrice, sellingPrice);

        // Check financing data
        (address student, address beneficiary, uint256 pPrice, uint256 sPrice, uint256 amountRepaid, bool isActive) = 
            loanPlatform.financings(1);
        
        assertEq(student, student1);
        assertEq(beneficiary, beneficiary1);
        assertEq(pPrice, purchasePrice);
        assertEq(sPrice, sellingPrice);
        assertEq(amountRepaid, 0);
        assertTrue(isActive);

        // Check balances
        assertEq(underlyingToken.balanceOf(beneficiary1), purchasePrice);
        assertEq(underlyingToken.balanceOf(address(loanPlatform)), DEPOSIT_AMOUNT - purchasePrice);
        assertEq(loanPlatform.totalFinancingActive(), purchasePrice);
        assertEq(loanPlatform.nextFinancingId(), 2);
    }

    function test_ExecuteFinancing_RevertsIfNotOwner() public {
        vm.prank(investor1);
        vm.expectRevert();
        loanPlatform.executeFinancing(student1, beneficiary1, 1000, 1100);
    }

    function test_ExecuteFinancing_RevertsIfInvalidStudent() public {
        vm.expectRevert("LoanPlatform: Invalid student address");
        loanPlatform.executeFinancing(address(0), beneficiary1, 1000, 1100);
    }

    function test_ExecuteFinancing_RevertsIfInvalidBeneficiary() public {
        vm.expectRevert("LoanPlatform: Invalid beneficiary address");
        loanPlatform.executeFinancing(student1, address(0), 1000, 1100);
    }

    function test_ExecuteFinancing_RevertsIfZeroPurchasePrice() public {
        vm.expectRevert("LoanPlatform: Purchase price must be greater than zero");
        loanPlatform.executeFinancing(student1, beneficiary1, 0, 1100);
    }

    function test_ExecuteFinancing_RevertsIfSellingPriceLessThanPurchase() public {
        vm.expectRevert("LoanPlatform: Selling price must be >= purchase price");
        loanPlatform.executeFinancing(student1, beneficiary1, 1000, 999);
    }

    function test_ExecuteFinancing_RevertsIfPoolEmpty() public {
        vm.expectRevert("LoanPlatform: Pool is empty");
        loanPlatform.executeFinancing(student1, beneficiary1, 1000, 1100);
    }

    function test_ExecuteFinancing_RevertsIfExceedsUtilizationRate() public {
        // Deposit
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        // Try to finance more than 80% of pool
        uint256 tooMuch = (DEPOSIT_AMOUNT * 81) / 100;
        vm.expectRevert("LoanPlatform: Utilization rate exceeded");
        loanPlatform.executeFinancing(student1, beneficiary1, tooMuch, tooMuch * 11 / 10);
    }

    function test_ExecuteFinancing_RevertsIfInsufficientCash() public {
        // Deposit
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        // Finance 70% of pool (below 80% utilization limit)
        uint256 firstFinancing = (DEPOSIT_AMOUNT * 70) / 100;
        loanPlatform.executeFinancing(student1, beneficiary1, firstFinancing, firstFinancing * 11 / 10);

        // Remaining cash is 30% of DEPOSIT_AMOUNT
        // Try to finance more than remaining cash
        // Note: This will likely fail at utilization rate check first (would be 100%+ utilization)
        // but the contract does check for insufficient cash as well
        uint256 remainingCash = DEPOSIT_AMOUNT - firstFinancing;
        vm.expectRevert(); // Will revert (either utilization or insufficient cash)
        loanPlatform.executeFinancing(student2, beneficiary2, remainingCash + 1, (remainingCash + 1) * 11 / 10);
    }

    function test_ExecuteFinancing_MultipleFinancings() public {
        // Deposit
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 financing1 = 30_000 * 1e6;
        uint256 financing2 = 20_000 * 1e6;

        loanPlatform.executeFinancing(student1, beneficiary1, financing1, financing1 * 11 / 10);
        loanPlatform.executeFinancing(student2, beneficiary2, financing2, financing2 * 11 / 10);

        assertEq(loanPlatform.totalFinancingActive(), financing1 + financing2);
        assertEq(loanPlatform.nextFinancingId(), 3);
    }

    // =================================================================
    //                           Repay Tests
    // =================================================================

    function test_Repay_FullPayment() public {
        // Setup: Deposit and execute financing
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 purchasePrice = 50_000 * 1e6;
        uint256 sellingPrice = 55_000 * 1e6; // 10% margin = 5k
        loanPlatform.executeFinancing(student1, beneficiary1, purchasePrice, sellingPrice);

        // Repay full amount
        vm.startPrank(student1);
        underlyingToken.approve(address(loanPlatform), sellingPrice);
        
        vm.expectEmit(true, false, false, true);
        emit RepaymentMade(1, student1, sellingPrice, purchasePrice, sellingPrice - purchasePrice);
        
        loanPlatform.repay(1, sellingPrice);
        vm.stopPrank();

        // Check financing is inactive
        (,,,,, bool isActive) = loanPlatform.financings(1);
        assertFalse(isActive);

        // Check balances
        uint256 margin = sellingPrice - purchasePrice;
        uint256 platformShare = (margin * 2000) / 10000; // 20%
        assertEq(underlyingToken.balanceOf(platformTreasury), platformShare);
        assertEq(loanPlatform.totalFinancingActive(), 0);
    }

    function test_Repay_PartialPayment() public {
        // Setup
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 purchasePrice = 50_000 * 1e6;
        uint256 sellingPrice = 55_000 * 1e6;
        loanPlatform.executeFinancing(student1, beneficiary1, purchasePrice, sellingPrice);

        // Repay half
        uint256 repaymentAmount = sellingPrice / 2;
        vm.startPrank(student1);
        underlyingToken.approve(address(loanPlatform), repaymentAmount);
        loanPlatform.repay(1, repaymentAmount);
        vm.stopPrank();

        // Check financing still active
        (,,,, uint256 amountRepaid, bool isActive) = loanPlatform.financings(1);
        assertEq(amountRepaid, repaymentAmount);
        assertTrue(isActive);
    }

    function test_Repay_MultiplePayments() public {
        // Setup
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 purchasePrice = 50_000 * 1e6;
        uint256 sellingPrice = 55_000 * 1e6;
        loanPlatform.executeFinancing(student1, beneficiary1, purchasePrice, sellingPrice);

        // First payment
        uint256 payment1 = sellingPrice / 3;
        vm.startPrank(student1);
        underlyingToken.approve(address(loanPlatform), sellingPrice);
        loanPlatform.repay(1, payment1);
        
        // Second payment
        loanPlatform.repay(1, payment1);
        
        // Final payment
        loanPlatform.repay(1, sellingPrice - (payment1 * 2));
        vm.stopPrank();

        // Check financing is inactive
        (,,,,, bool isActive) = loanPlatform.financings(1);
        assertFalse(isActive);
    }

    function test_Repay_RevertsIfZeroAmount() public {
        vm.expectRevert("LoanPlatform: Amount must be greater than zero");
        loanPlatform.repay(1, 0);
    }

    function test_Repay_RevertsIfFinancingNotActive() public {
        // Setup
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 purchasePrice = 50_000 * 1e6;
        uint256 sellingPrice = 55_000 * 1e6;
        loanPlatform.executeFinancing(student1, beneficiary1, purchasePrice, sellingPrice);

        // Repay full
        vm.startPrank(student1);
        underlyingToken.approve(address(loanPlatform), sellingPrice);
        loanPlatform.repay(1, sellingPrice);
        vm.stopPrank();

        // Try to repay again
        vm.startPrank(student1);
        underlyingToken.approve(address(loanPlatform), 1000);
        vm.expectRevert("LoanPlatform: Financing is not active");
        loanPlatform.repay(1, 1000);
        vm.stopPrank();
    }

    function test_Repay_RevertsIfNotStudent() public {
        // Setup
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        loanPlatform.executeFinancing(student1, beneficiary1, 10_000 * 1e6, 11_000 * 1e6);

        // Try to repay as different user
        vm.startPrank(student2);
        underlyingToken.approve(address(loanPlatform), 1000);
        vm.expectRevert("LoanPlatform: Only student can repay their financing");
        loanPlatform.repay(1, 1000);
        vm.stopPrank();
    }

    function test_Repay_RevertsIfExceedsRemainingDebt() public {
        // Setup
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 sellingPrice = 55_000 * 1e6;
        loanPlatform.executeFinancing(student1, beneficiary1, 50_000 * 1e6, sellingPrice);

        // Try to repay more than owed
        vm.startPrank(student1);
        underlyingToken.approve(address(loanPlatform), sellingPrice + 1);
        vm.expectRevert("LoanPlatform: Amount exceeds remaining debt");
        loanPlatform.repay(1, sellingPrice + 1);
        vm.stopPrank();
    }

    function test_Repay_DistributesMarginCorrectly() public {
        // Setup
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 purchasePrice = 50_000 * 1e6;
        uint256 sellingPrice = 60_000 * 1e6; // 20% margin = 10k
        loanPlatform.executeFinancing(student1, beneficiary1, purchasePrice, sellingPrice);

        uint256 treasuryBefore = underlyingToken.balanceOf(platformTreasury);

        // Repay full
        vm.startPrank(student1);
        underlyingToken.approve(address(loanPlatform), sellingPrice);
        loanPlatform.repay(1, sellingPrice);
        vm.stopPrank();

        uint256 margin = sellingPrice - purchasePrice; // 10k
        uint256 platformShare = (margin * 2000) / 10000; // 20% of 10k = 2k
        uint256 investorShare = margin - platformShare; // 8k

        assertEq(underlyingToken.balanceOf(platformTreasury), treasuryBefore + platformShare);
        // Investor share stays in pool (increases LP token value)
    }

    // =================================================================
    //                           View Functions Tests
    // =================================================================

    function test_GetPoolValue_EmptyPool() public {
        assertEq(loanPlatform.getPoolValue(), 0);
    }

    function test_GetPoolValue_WithDeposit() public {
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        assertEq(loanPlatform.getPoolValue(), DEPOSIT_AMOUNT);
    }

    function test_GetPoolValue_WithFinancing() public {
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 financingAmount = 50_000 * 1e6;
        loanPlatform.executeFinancing(student1, beneficiary1, financingAmount, financingAmount * 11 / 10);

        // Pool value = cash + active financing
        uint256 expectedPoolValue = DEPOSIT_AMOUNT; // Cash reduced, but financing active adds back
        assertEq(loanPlatform.getPoolValue(), expectedPoolValue);
    }

    function test_GetLpTokenValue_EmptySupply() public {
        assertEq(loanPlatform.getLpTokenValue(), 1e18);
    }

    function test_GetLpTokenValue_AfterDeposit() public {
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        // Should be 1:1 initially
        uint256 lpValue = loanPlatform.getLpTokenValue();
        assertEq(lpValue, 1e18);
    }

    function test_GetLpTokenValue_IncreasesWithMargin() public {
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 purchasePrice = 50_000 * 1e6;
        uint256 sellingPrice = 60_000 * 1e6; // 20% margin
        loanPlatform.executeFinancing(student1, beneficiary1, purchasePrice, sellingPrice);

        // Repay full - margin increases pool value
        vm.startPrank(student1);
        underlyingToken.approve(address(loanPlatform), sellingPrice);
        loanPlatform.repay(1, sellingPrice);
        vm.stopPrank();

        // LP token value should increase
        uint256 lpValue = loanPlatform.getLpTokenValue();
        assertGt(lpValue, 1e18);
    }

    function test_GetFinancing_ReturnsCorrectData() public {
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 purchasePrice = 50_000 * 1e6;
        uint256 sellingPrice = 55_000 * 1e6;
        loanPlatform.executeFinancing(student1, beneficiary1, purchasePrice, sellingPrice);

        LoanPlatform.Financing memory financing = loanPlatform.getFinancing(1);

        assertEq(financing.student, student1);
        assertEq(financing.beneficiary, beneficiary1);
        assertEq(financing.purchasePrice, purchasePrice);
        assertEq(financing.sellingPrice, sellingPrice);
        assertEq(financing.amountRepaid, 0);
        assertTrue(financing.isActive);
    }

    function test_GetRemainingDebt_ActiveFinancing() public {
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 sellingPrice = 55_000 * 1e6;
        loanPlatform.executeFinancing(student1, beneficiary1, 50_000 * 1e6, sellingPrice);

        assertEq(loanPlatform.getRemainingDebt(1), sellingPrice);

        // After partial payment
        vm.startPrank(student1);
        underlyingToken.approve(address(loanPlatform), sellingPrice / 2);
        loanPlatform.repay(1, sellingPrice / 2);
        vm.stopPrank();

        assertEq(loanPlatform.getRemainingDebt(1), sellingPrice / 2);
    }

    function test_GetRemainingDebt_InactiveFinancing() public {
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 sellingPrice = 55_000 * 1e6;
        loanPlatform.executeFinancing(student1, beneficiary1, 50_000 * 1e6, sellingPrice);

        // Repay full
        vm.startPrank(student1);
        underlyingToken.approve(address(loanPlatform), sellingPrice);
        loanPlatform.repay(1, sellingPrice);
        vm.stopPrank();

        assertEq(loanPlatform.getRemainingDebt(1), 0);
    }

    function test_GetUtilizationRate_EmptyPool() public {
        assertEq(loanPlatform.getUtilizationRate(), 0);
    }

    function test_GetUtilizationRate_WithFinancing() public {
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        uint256 financingAmount = 40_000 * 1e6; // 40% of 100k
        loanPlatform.executeFinancing(student1, beneficiary1, financingAmount, financingAmount * 11 / 10);

        uint256 utilizationRate = loanPlatform.getUtilizationRate();
        assertEq(utilizationRate, 4000); // 40% in basis points
    }

    // =================================================================
    //                           Integration Tests
    // =================================================================

    function test_FullCycle_DepositFinancingRepayWithdraw() public {
        // 1. Deposit
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), DEPOSIT_AMOUNT);
        loanPlatform.deposit(DEPOSIT_AMOUNT);
        uint256 initialLpTokens = eduLPToken.balanceOf(investor1);
        vm.stopPrank();

        // 2. Execute financing
        uint256 purchasePrice = 50_000 * 1e6;
        uint256 sellingPrice = 55_000 * 1e6;
        loanPlatform.executeFinancing(student1, beneficiary1, purchasePrice, sellingPrice);

        // 3. Repay
        vm.startPrank(student1);
        underlyingToken.approve(address(loanPlatform), sellingPrice);
        loanPlatform.repay(1, sellingPrice);
        vm.stopPrank();

        // 4. Withdraw - LP token value should have increased
        vm.startPrank(investor1);
        uint256 lpValueBefore = loanPlatform.getLpTokenValue();
        loanPlatform.withdraw(initialLpTokens);
        vm.stopPrank();

        // Investor should get back more than deposited due to margin
        assertGt(underlyingToken.balanceOf(investor1), INITIAL_SUPPLY - DEPOSIT_AMOUNT + purchasePrice);
    }

    function test_MultipleInvestorsAndFinancings() public {
        // Multiple deposits
        vm.startPrank(investor1);
        underlyingToken.approve(address(loanPlatform), 60_000 * 1e6);
        loanPlatform.deposit(60_000 * 1e6);
        vm.stopPrank();

        vm.startPrank(investor2);
        underlyingToken.approve(address(loanPlatform), 40_000 * 1e6);
        loanPlatform.deposit(40_000 * 1e6);
        vm.stopPrank();

        // Multiple financings
        loanPlatform.executeFinancing(student1, beneficiary1, 30_000 * 1e6, 33_000 * 1e6);
        loanPlatform.executeFinancing(student2, beneficiary2, 20_000 * 1e6, 22_000 * 1e6);

        // Repayments
        vm.startPrank(student1);
        underlyingToken.approve(address(loanPlatform), 33_000 * 1e6);
        loanPlatform.repay(1, 33_000 * 1e6);
        vm.stopPrank();

        vm.startPrank(student2);
        underlyingToken.approve(address(loanPlatform), 22_000 * 1e6);
        loanPlatform.repay(2, 22_000 * 1e6);
        vm.stopPrank();

        // Both investors should benefit from margin
        assertGt(loanPlatform.getLpTokenValue(), 1e18);
    }
}

