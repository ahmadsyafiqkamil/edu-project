# Deployment Addresses - Lisk Sepolia Testnet

## Network Information
- **Network**: Lisk Sepolia
- **Chain ID**: 4202
- **RPC URL**: https://rpc.sepolia-api.lisk.com/5bec97bedf0944d481a25ea6a55e985c
- **Block Explorer**: https://sepolia-blockscout.lisk.com
- **Deployment Date**: November 21, 2025

## Deployed Contracts

### MockERC20 (Test USDC)
- **Contract Address**: `0xfE0723E7904deF87F43da03C8eeB675eA8BeCC62`
- **Transaction Hash**: `0x13ab3ee30e605b3e4e3bb81aad966ef3e59f10107d7146eeaec810172c4baf78`
- **Block**: 29185963
- **Token Name**: Mock USDC
- **Token Symbol**: mUSDC
- **Decimals**: 6
- **Initial Supply**: 1,000,000,000 mUSDC
- **Explorer**: https://sepolia-blockscout.lisk.com/address/0xfe0723e7904def87f43da03c8eeb675ea8becc62
- **Verified**: ✅ Yes

### LoanPlatform (Main Contract)
- **Contract Address**: `0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA`
- **Transaction Hash**: `0x211e679e7443b696b675ee2d7e9ec7c46ca1d3e2af72166d4b5addbd02441c1e`
- **Block**: 29186065
- **Owner**: `0x366d3F2095b815e9fe65723ed8d53527B141B1E6`
- **Platform Treasury**: `0x5160352f875D9E77Fdf215c357Fc0FD5E1A3fC3f`
- **Underlying Token**: `0xfE0723E7904deF87F43da03C8eeB675eA8BeCC62` (MockERC20)
- **Max Utilization Rate**: 8000 (80%)
- **Platform Share Ratio**: 2000 (20%)
- **Explorer**: https://sepolia-blockscout.lisk.com/address/0x20cad8debfb7d39237e684fdfeb9cef61f8f10ea
- **Verified**: ✅ Yes

### EduLPToken (Liquidity Pool Token)
- **Contract Address**: `0x190DB7d150E0ea60eeeDf70014CAAB6b237a0533`
- **Transaction Hash**: (Deployed via LoanPlatform constructor)
- **Block**: 29186065
- **Token Name**: Education LP Token
- **Token Symbol**: eduLP
- **Decimals**: 18
- **Owner**: `0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA` (LoanPlatform)
- **Loan Platform**: `0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA`
- **Explorer**: https://sepolia-blockscout.lisk.com/address/0x190db7d150e0ea60eeedf70014caab6b237a0533
- **Verified**: ✅ Yes

## Contract Interactions

### For Investors (Liquidity Providers)
1. **Approve MockERC20 to LoanPlatform**: 
   - Call `approve(0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA, amount)` on MockERC20
2. **Deposit**: 
   - Call `deposit(amount)` on LoanPlatform
3. **Withdraw**: 
   - Call `withdraw(lpTokenAmount)` on LoanPlatform

### For Admin
1. **Execute Financing**: 
   - Call `executeFinancing(studentAddress, beneficiaryAddress, purchasePrice, sellingPrice)` on LoanPlatform

### For Students
1. **Approve MockERC20 to LoanPlatform**: 
   - Call `approve(0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA, amount)` on MockERC20
2. **Make Repayment**: 
   - Call `repay(financingId, amount)` on LoanPlatform

## View Functions

### Pool Information
- `getPoolValue()` - Get total pool value
- `getLpTokenValue()` - Get value of 1 LP token
- `getUtilizationRate()` - Get current utilization rate

### Financing Information
- `getFinancing(financingId)` - Get financing details
- `getRemainingDebt(financingId)` - Get remaining debt for a financing

## Important Notes

1. **Underlying Token**: This deployment uses MockERC20 for testing. For production, replace with actual stablecoin (e.g., USDC).

2. **Platform Treasury**: Set to `0x5160352f875D9E77Fdf215c357Fc0FD5E1A3fC3f`. Make sure this address is secure and controlled properly.

3. **Max Utilization Rate**: Currently set to 80%, meaning maximum 80% of pool funds can be used for active financing.

4. **Profit Sharing**: 80% to investors (LP holders), 20% to platform treasury.

5. **Testing**: To test the system, you can use MockERC20's `mint(address, amount)` function to create test tokens.

## Gas Costs
- MockERC20 Deployment: 590,513 gas (≈ $0.0006 @ 0.001 gwei)
- LoanPlatform + EduLPToken Deployment: 2,393,454 gas (≈ $0.0006 @ 0.000254 gwei)

## Next Steps

1. ✅ All contracts deployed and verified
2. 🔄 Test deposit/withdraw flow
3. 🔄 Test financing execution
4. 🔄 Test repayment flow
5. 🔄 Integrate with frontend

## Smart Contract Architecture

```
MockERC20 (mUSDC)
    ↓ (underlying token)
LoanPlatform
    ├─ Creates/Manages → EduLPToken (eduLP)
    ├─ Receives deposits from → Investors
    ├─ Provides financing to → Students (via Universities)
    └─ Distributes profits to → Platform Treasury + LP Holders
```

## Support
For questions or issues, contact the development team.

