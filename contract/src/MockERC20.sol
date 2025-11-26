// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockERC20
 * @notice Mock token ERC20 untuk testing dan development
 *         Token ini bisa digunakan sebagai underlyingToken di LoanPlatform
 */
contract MockERC20 is ERC20 {
    uint8 private _decimals;
    // _mint(msg.sender, 1_000_000 * 10**6); // 1 million USDC
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _decimals = decimals_;
        _mint(msg.sender, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @notice Mint token baru (untuk testing)
     * @param to Address yang akan menerima token
     * @param amount Jumlah token yang akan di-mint
     */
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}







