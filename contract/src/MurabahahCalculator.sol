// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title MurabahahCalculator
 * @notice Helper contract to calculate Murabahah financing details (margin, selling price, installments).
 *         Useful for off-chain estimation or on-chain verification.
 */
library MurabahahCalculator {
    
    /**
     * @notice Calculates the Murabahah selling price and monthly installment.
     * @param _purchasePrice The cost price of the asset/service (Harga Pokok).
     * @param _marginRateBps The annual profit margin rate in basis points (e.g., 500 = 5%).
     * @param _tenureMonths The financing tenure in months.
     * @return sellingPrice The total price to be paid by the student (Harga Jual).
     * @return totalMargin The total profit margin amount.
     * @return monthlyInstallment The monthly payment amount.
     */
    function calculateFinancingDetail(
        uint256 _purchasePrice,
        uint256 _marginRateBps,
        uint256 _tenureMonths
    ) internal pure returns (uint256 sellingPrice, uint256 totalMargin, uint256 monthlyInstallment) {
        require(_tenureMonths > 0, "Tenure must be > 0");
        
        // Calculate Total Margin
        // Formula: Margin = (Principal * Rate * Tenure) / (12 * 10000)
        // We multiply first to avoid precision loss
        // 10000 is for Basis Points (100% = 10000)
        
        totalMargin = (_purchasePrice * _marginRateBps * _tenureMonths) / (12 * 10000);
        
        // Calculate Selling Price
        sellingPrice = _purchasePrice + totalMargin;
        
        // Calculate Monthly Installment
        // Note: This integer division might leave a small remainder. 
        // In a real app, the last installment usually adjusts for this, 
        // or we round up/down consistently. Here we use floor division.
        monthlyInstallment = sellingPrice / _tenureMonths;
    }

    /**
     * @notice Calculates the effective margin rate given a fixed selling price.
     *         Useful if the admin sets a fixed selling price manually.
     * @param _purchasePrice Cost price.
     * @param _sellingPrice Selling price.
     * @param _tenureMonths Tenure in months.
     * @return effectiveRateBps The effective annual margin rate in basis points.
     */
    function calculateEffectiveRate(
        uint256 _purchasePrice,
        uint256 _sellingPrice,
        uint256 _tenureMonths
    ) internal pure returns (uint256 effectiveRateBps) {
        require(_sellingPrice >= _purchasePrice, "Selling price < Purchase price");
        require(_tenureMonths > 0, "Tenure must be > 0");
        require(_purchasePrice > 0, "Purchase price must be > 0");

        uint256 totalMargin = _sellingPrice - _purchasePrice;
        
        // Inverse of the margin formula:
        // Margin = (Principal * Rate * Tenure) / (12 * 10000)
        // Rate = (Margin * 12 * 10000) / (Principal * Tenure)
        
        effectiveRateBps = (totalMargin * 12 * 10000) / (_purchasePrice * _tenureMonths);
    }
}

