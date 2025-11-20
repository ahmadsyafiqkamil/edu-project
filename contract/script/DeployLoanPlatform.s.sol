// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {LoanPlatform} from "../src/LoanPlatform.sol";
import {EduLPToken} from "../src/EduLPToken.sol";

/**
 * @title DeployLoanPlatform
 * @notice Script untuk deploy LoanPlatform (akan auto-deploy EduLPToken)
 * 
 * CARA MENGGUNAKAN:
 * 1. Set environment variables:
 *    export PRIVATE_KEY=your_private_key
 *    export RPC_URL=https://rpc.sepolia-api.lisk.com/...
 *    export UNDERLYING_TOKEN_ADDRESS=0x... (address token yang sudah ada)
 *    export PLATFORM_TREASURY=0xYourTreasuryWalletAddress
 * 
 * 2. Deploy:
 *    forge script script/DeployLoanPlatform.s.sol:DeployLoanPlatform --rpc-url $RPC_URL --broadcast
 */
contract DeployLoanPlatform is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address underlyingTokenAddress = vm.envAddress("UNDERLYING_TOKEN_ADDRESS");
        address platformTreasury = vm.envAddress("PLATFORM_TREASURY");
        
        vm.startBroadcast(deployerPrivateKey);

        console.log("\n=== Deploying LoanPlatform ===");
        console.log("Underlying Token:", underlyingTokenAddress);
        console.log("Platform Treasury:", platformTreasury);
        console.log("Deployer:", msg.sender);
        
        LoanPlatform loanPlatform = new LoanPlatform(
            underlyingTokenAddress,
            platformTreasury
        );
        
        EduLPToken eduLPToken = loanPlatform.eduLpToken();
        
        console.log("LoanPlatform deployed at:", address(loanPlatform));
        console.log("EduLPToken deployed at:", address(eduLPToken));

        vm.stopBroadcast();

        console.log("\n=== DEPLOYMENT SUMMARY ===");
        console.log("LoanPlatform Address:", address(loanPlatform));
        console.log("EduLPToken Address:", address(eduLPToken));
        console.log("EduLPToken Name:", eduLPToken.name());
        console.log("EduLPToken Symbol:", eduLPToken.symbol());
        console.log("LoanPlatform Owner:", loanPlatform.owner());
        console.log("Platform Treasury:", loanPlatform.platformTreasury());
        console.log("Max Utilization Rate:", loanPlatform.maxUtilizationRate());
        console.log("Platform Share Ratio:", loanPlatform.platformShareRatio());
    }
}


