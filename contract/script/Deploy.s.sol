// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {LoanPlatform} from "../src/LoanPlatform.sol";
import {EduLPToken} from "../src/EduLPToken.sol";
import {MockERC20} from "../src/MockERC20.sol";

/**
 * @title Deploy
 * @notice Script untuk deploy semua contract: MockERC20, LoanPlatform, dan EduLPToken
 * 
 * CARA MENGGUNAKAN:
 * 
 * 1. Set environment variables:
 *    export PRIVATE_KEY=your_private_key
 *    export RPC_URL=https://rpc.sepolia-api.lisk.com/...
 *    export PLATFORM_TREASURY=0xYourTreasuryWalletAddress
 * 
 * 2. Untuk Testnet dengan Mock Token (Development):
 *    forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL --broadcast --verify
 * 
 * 3. Untuk Testnet dengan Token yang Sudah Ada (Production):
 *    - Set UNDERLYING_TOKEN_ADDRESS environment variable
 *    - Atau uncomment bagian OPTION 2 di bawah
 * 
 * 4. Untuk Local Testing:
 *    forge script script/Deploy.s.sol:Deploy --fork-url http://localhost:8545
 */
contract Deploy is Script {
    // =================================================================
    //                           State Variables
    // =================================================================
    MockERC20 public mockToken;
    LoanPlatform public loanPlatform;
    EduLPToken public eduLPToken;
    
    address public underlyingTokenAddress;
    address public platformTreasury;
    address public deployer;

    function run() external {
        deployer = msg.sender;
        
        // Get environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        platformTreasury = vm.envAddress("PLATFORM_TREASURY");
        
        // Try to get underlying token address from env, otherwise deploy mock
        try vm.envAddress("UNDERLYING_TOKEN_ADDRESS") returns (address tokenAddr) {
            underlyingTokenAddress = tokenAddr;
            console.log("Using existing token at:", underlyingTokenAddress);
        } catch {
            // Deploy mock token if not provided
            underlyingTokenAddress = address(0);
        }
        
        vm.startBroadcast(deployerPrivateKey);

        // =================================================================
        // OPTION 1: Deploy Mock Token untuk Testing (jika belum ada)
        // =================================================================
        if (underlyingTokenAddress == address(0)) {
            console.log("\n=== Deploying MockERC20 Token ===");
            mockToken = new MockERC20(
                "Mock USDC",
                "mUSDC",
                6, // decimals (USDC uses 6 decimals)
                1_000_000_000 * 10**6 // 1 billion tokens untuk testing
            );
            underlyingTokenAddress = address(mockToken);
            console.log("MockERC20 deployed at:", address(mockToken));
            console.log("Token Name:", mockToken.name());
            console.log("Token Symbol:", mockToken.symbol());
            console.log("Token Decimals:", mockToken.decimals());
            console.log("Initial Supply:", mockToken.totalSupply());
        }

        // =================================================================
        // OPTION 2: Gunakan Token yang Sudah Ada (untuk Production/Testnet)
        // =================================================================
        // Uncomment dan set address jika ingin menggunakan token yang sudah ada
        // underlyingTokenAddress = 0x...; // Contoh: USDC Sepolia address
        // console.log("Using existing token at:", underlyingTokenAddress);

        // =================================================================
        // Deploy LoanPlatform (akan auto-deploy EduLPToken)
        // =================================================================
        console.log("\n=== Deploying LoanPlatform ===");
        console.log("Underlying Token:", underlyingTokenAddress);
        console.log("Platform Treasury:", platformTreasury);
        console.log("Deployer:", deployer);
        
        loanPlatform = new LoanPlatform(
            underlyingTokenAddress,
            platformTreasury
        );
        
        eduLPToken = loanPlatform.eduLpToken();
        
        console.log("LoanPlatform deployed at:", address(loanPlatform));
        console.log("EduLPToken deployed at:", address(eduLPToken));
        console.log("EduLPToken Name:", eduLPToken.name());
        console.log("EduLPToken Symbol:", eduLPToken.symbol());
        console.log("EduLPToken Owner:", eduLPToken.owner());
        console.log("LoanPlatform Owner:", loanPlatform.owner());

        vm.stopBroadcast();

        // =================================================================
        // Deployment Summary
        // =================================================================
        _printSummary();
        
        // =================================================================
        // Verification Info
        // =================================================================
        _printVerificationInfo();
    }

    function _printSummary() internal view {
        console.log("\n============================================================");
        console.log("           DEPLOYMENT SUMMARY");
        console.log("============================================================");
        console.log("");
        console.log("CONTRACTS DEPLOYED:");
        console.log("------------------------------------------------------------");
        
        if (underlyingTokenAddress == address(mockToken)) {
            console.log("MockERC20 (mUSDC):");
            console.log("  Address:", address(mockToken));
            console.log("  Name:", mockToken.name());
            console.log("  Symbol:", mockToken.symbol());
            console.log("  Decimals:", mockToken.decimals());
            console.log("  Total Supply:", mockToken.totalSupply());
        } else {
            console.log("Underlying Token (Existing):");
            console.log("  Address:", underlyingTokenAddress);
        }
        
        console.log("");
        console.log("LoanPlatform:");
        console.log("  Address:", address(loanPlatform));
        console.log("  Owner:", loanPlatform.owner());
        console.log("  Platform Treasury:", loanPlatform.platformTreasury());
        console.log("  Max Utilization Rate:", loanPlatform.maxUtilizationRate(), "(80%)");
        console.log("  Platform Share Ratio:", loanPlatform.platformShareRatio(), "(20%)");
        
        console.log("");
        console.log("EduLPToken:");
        console.log("  Address:", address(eduLPToken));
        console.log("  Name:", eduLPToken.name());
        console.log("  Symbol:", eduLPToken.symbol());
        console.log("  Decimals:", eduLPToken.decimals());
        console.log("  Owner:", eduLPToken.owner());
        console.log("  Loan Platform:", eduLPToken.loanPlatform());
        
        console.log("");
        console.log("CONFIGURATION:");
        console.log("------------------------------------------------------------");
        console.log("Deployer:", deployer);
        console.log("Platform Treasury:", platformTreasury);
        console.log("Underlying Token:", underlyingTokenAddress);
    }

    function _printVerificationInfo() internal view {
        console.log("\n============================================================");
        console.log("           VERIFICATION COMMANDS");
        console.log("============================================================");
        console.log("");
        console.log("To verify contracts, use the following commands:");
        console.log("");
        
        if (underlyingTokenAddress == address(mockToken)) {
            console.log("MockERC20:");
            console.log("  Address:", address(mockToken));
            console.log("  Command: forge verify-contract <ADDRESS> src/MockERC20.sol:MockERC20");
            console.log("");
        }
        
        console.log("LoanPlatform:");
        console.log("  Address:", address(loanPlatform));
        console.log("  Underlying Token:", underlyingTokenAddress);
        console.log("  Treasury:", platformTreasury);
        console.log("  Command: forge verify-contract <ADDRESS> src/LoanPlatform.sol:LoanPlatform");
        console.log("  Constructor Args: --constructor-args $(cast abi-encode \"constructor(address,address)\" <TOKEN> <TREASURY>)");
        console.log("");
        
        console.log("EduLPToken:");
        console.log("  Address:", address(eduLPToken));
        console.log("  Owner (LoanPlatform):", address(loanPlatform));
        console.log("  Command: forge verify-contract <ADDRESS> src/EduLPToken.sol:EduLPToken");
        console.log("  Constructor Args: --constructor-args $(cast abi-encode \"constructor(address)\" <LOAN_PLATFORM>)");
        console.log("");
    }
}

