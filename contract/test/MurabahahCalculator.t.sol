// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/MurabahahCalculator.sol";

contract MurabahahCalculatorTest is Test {
    
    // Wrapper contract to test the library
    function calculate(uint256 p, uint256 r, uint256 t) public pure returns (uint256, uint256, uint256) {
        return MurabahahCalculator.calculateFinancingDetail(p, r, t);
    }

    function testCalculateInstallment() public pure {
        uint256 principal = 10_000 * 1e6; // 10,000 USDC (assuming 6 decimals)
        uint256 rateBps = 500; // 5% per annum
        uint256 tenure = 12; // 12 months

        (uint256 sellingPrice, uint256 margin, uint256 installment) = calculate(principal, rateBps, tenure);

        // Expected Margin: 10,000 * 5% * (12/12) = 500 USDC
        // Expected Selling Price: 10,500 USDC
        // Expected Installment: 10,500 / 12 = 875 USDC

        assertEq(margin, 500 * 1e6, "Margin calculation wrong");
        assertEq(sellingPrice, 10_500 * 1e6, "Selling price wrong");
        assertEq(installment, 875 * 1e6, "Installment wrong");
    }

    function testCalculateInstallmentShortTenure() public pure {
        uint256 principal = 12_000 * 1e6; 
        uint256 rateBps = 1000; // 10% per annum
        uint256 tenure = 6; // 6 months

        (uint256 sellingPrice, uint256 margin, uint256 installment) = calculate(principal, rateBps, tenure);

        // Expected Margin: 12,000 * 10% * (6/12) = 600 USDC
        // Expected Selling Price: 12,600 USDC
        // Expected Installment: 12,600 / 6 = 2,100 USDC

        assertEq(margin, 600 * 1e6, "Margin calculation wrong");
        assertEq(sellingPrice, 12_600 * 1e6, "Selling price wrong");
        assertEq(installment, 2_100 * 1e6, "Installment wrong");
    }
}

