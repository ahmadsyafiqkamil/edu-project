// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {MockERC20} from "../src/MockERC20.sol";

/**
 * @title DeployMockERC20
 * @notice Script untuk deploy MockERC20 token secara terpisah
 * 
 * CARA MENGGUNAKAN:
 * 1. Set environment variables:
 *    export PRIVATE_KEY=your_private_key
 *    export RPC_URL=https://rpc.sepolia-api.lisk.com/...
 * 
 * 2. Deploy:
 *    forge script script/DeployMockERC20.s.sol:DeployMockERC20 --rpc-url $RPC_URL --broadcast
 * 
 * 3. Optional: Set custom parameters via environment variables:
 *    export TOKEN_NAME="Mock USDC"
 *    export TOKEN_SYMBOL="mUSDC"
 *    export TOKEN_DECIMALS=6
 *    export INITIAL_SUPPLY=1000000000
 */
contract DeployMockERC20 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Get parameters from environment or use defaults
        string memory tokenName = vm.envOr("TOKEN_NAME", string("Mock USDC"));
        string memory tokenSymbol = vm.envOr("TOKEN_SYMBOL", string("mUSDC"));
        uint8 decimals = uint8(vm.envOr("TOKEN_DECIMALS", uint256(6)));
        uint256 initialSupply = vm.envOr("INITIAL_SUPPLY", uint256(1_000_000_000)) * 10**decimals;
        
        vm.startBroadcast(deployerPrivateKey);

        console.log("\n=== Deploying MockERC20 Token ===");
        console.log("Token Name:", tokenName);
        console.log("Token Symbol:", tokenSymbol);
        console.log("Decimals:", decimals);
        console.log("Initial Supply:", initialSupply);
        
        MockERC20 mockToken = new MockERC20(
            tokenName,
            tokenSymbol,
            decimals,
            initialSupply
        );
        
        console.log("MockERC20 deployed at:", address(mockToken));
        console.log("Deployer balance:", mockToken.balanceOf(msg.sender));

        vm.stopBroadcast();

        console.log("\n=== DEPLOYMENT SUMMARY ===");
        console.log("MockERC20 Address:", address(mockToken));
        console.log("Token Name:", mockToken.name());
        console.log("Token Symbol:", mockToken.symbol());
        console.log("Decimals:", mockToken.decimals());
        console.log("Total Supply:", mockToken.totalSupply());
    }
}




