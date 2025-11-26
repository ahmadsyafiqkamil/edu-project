# Quick Start Guide - Edu Finance Platform

## 🚀 Deployment Berhasil!

Semua smart contract telah berhasil di-deploy ke **Lisk Sepolia Testnet** dan terverifikasi di Blockscout.

## 📋 Contract Addresses

| Contract | Address | Explorer |
|----------|---------|----------|
| **MockERC20** | `0xfE0723E7904deF87F43da03C8eeB675eA8BeCC62` | [View →](https://sepolia-blockscout.lisk.com/address/0xfe0723e7904def87f43da03c8eeb675ea8becc62) |
| **LoanPlatform** | `0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA` | [View →](https://sepolia-blockscout.lisk.com/address/0x20cad8debfb7d39237e684fdfeb9cef61f8f10ea) |
| **EduLPToken** | `0x190DB7d150E0ea60eeeDf70014CAAB6b237a0533` | [View →](https://sepolia-blockscout.lisk.com/address/0x190db7d150e0ea60eeedf70014caab6b237a0533) |

## 🧪 Testing The Platform

### Step 1: Get Test Tokens (mUSDC)

```bash
# Mint test tokens to your wallet
cast send 0xfE0723E7904deF87F43da03C8eeB675eA8BeCC62 \
  "mint(address,uint256)" \
  YOUR_WALLET_ADDRESS \
  1000000000 \
  --rpc-url lisk_sepolia \
  --private-key $PRIVATE_KEY
```

### Step 2: Become an Investor (Deposit to Pool)

```bash
# 1. Approve LoanPlatform to spend your mUSDC
cast send 0xfE0723E7904deF87F43da03C8eeB675eA8BeCC62 \
  "approve(address,uint256)" \
  0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA \
  500000000 \
  --rpc-url lisk_sepolia \
  --private-key $PRIVATE_KEY

# 2. Deposit 500 mUSDC to the pool
cast send 0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA \
  "deposit(uint256)" \
  500000000 \
  --rpc-url lisk_sepolia \
  --private-key $PRIVATE_KEY

# 3. Check your eduLP token balance
cast call 0x190DB7d150E0ea60eeeDf70014CAAB6b237a0533 \
  "balanceOf(address)" \
  YOUR_WALLET_ADDRESS \
  --rpc-url lisk_sepolia
```

### Step 3: Execute a Financing (Admin Only)

```bash
# Execute financing for a student
# Parameters: student, beneficiary (university), purchasePrice, sellingPrice
cast send 0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA \
  "executeFinancing(address,address,uint256,uint256)" \
  STUDENT_WALLET_ADDRESS \
  UNIVERSITY_WALLET_ADDRESS \
  100000000 \
  110000000 \
  --rpc-url lisk_sepolia \
  --private-key $PRIVATE_KEY
```

### Step 4: Make Repayment (Student)

```bash
# 1. Student approves LoanPlatform
cast send 0xfE0723E7904deF87F43da03C8eeB675eA8BeCC62 \
  "approve(address,uint256)" \
  0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA \
  110000000 \
  --rpc-url lisk_sepolia \
  --private-key $STUDENT_PRIVATE_KEY

# 2. Student makes repayment (financing ID 1, amount 55 mUSDC)
cast send 0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA \
  "repay(uint256,uint256)" \
  1 \
  55000000 \
  --rpc-url lisk_sepolia \
  --private-key $STUDENT_PRIVATE_KEY
```

### Step 5: Check Pool Status

```bash
# Get pool value
cast call 0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA \
  "getPoolValue()" \
  --rpc-url lisk_sepolia

# Get LP token value
cast call 0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA \
  "getLpTokenValue()" \
  --rpc-url lisk_sepolia

# Get utilization rate
cast call 0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA \
  "getUtilizationRate()" \
  --rpc-url lisk_sepolia
```

### Step 6: Withdraw (Investor)

```bash
# Withdraw by burning LP tokens
cast send 0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA \
  "withdraw(uint256)" \
  YOUR_LP_TOKEN_AMOUNT \
  --rpc-url lisk_sepolia \
  --private-key $PRIVATE_KEY
```

## 🔍 View Functions (Read Only)

```bash
# Get financing details
cast call 0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA \
  "getFinancing(uint256)" \
  1 \
  --rpc-url lisk_sepolia

# Get remaining debt
cast call 0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA \
  "getRemainingDebt(uint256)" \
  1 \
  --rpc-url lisk_sepolia

# Check mUSDC balance
cast call 0xfE0723E7904deF87F43da03C8eeB675eA8BeCC62 \
  "balanceOf(address)" \
  YOUR_WALLET_ADDRESS \
  --rpc-url lisk_sepolia

# Check eduLP balance
cast call 0x190DB7d150E0ea60eeeDf70014CAAB6b237a0533 \
  "balanceOf(address)" \
  YOUR_WALLET_ADDRESS \
  --rpc-url lisk_sepolia
```

## 📊 Frontend Integration

### Using Web3.js or Ethers.js

```javascript
import { ethers } from 'ethers';
import deploymentConfig from './deployment-config.json';
import LoanPlatformABI from './out/LoanPlatform.sol/LoanPlatform.json';

// Connect to Lisk Sepolia
const provider = new ethers.JsonRpcProvider(deploymentConfig.network.rpcUrl);
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

// Create contract instance
const loanPlatform = new ethers.Contract(
  deploymentConfig.contracts.LoanPlatform.address,
  LoanPlatformABI.abi,
  signer
);

// Example: Deposit to pool
async function deposit(amount) {
  const tx = await loanPlatform.deposit(amount);
  await tx.wait();
  console.log('Deposit successful!');
}

// Example: Get pool value
async function getPoolValue() {
  const value = await loanPlatform.getPoolValue();
  console.log('Pool Value:', ethers.formatUnits(value, 6)); // 6 decimals for mUSDC
}
```

### Using wagmi (React)

```typescript
import { useContractWrite, useContractRead } from 'wagmi';
import { parseUnits } from 'viem';

const LOAN_PLATFORM_ADDRESS = '0x20CAd8deBFb7D39237e684FdfEB9CeF61f8F10eA';

// Deposit to pool
const { write: deposit } = useContractWrite({
  address: LOAN_PLATFORM_ADDRESS,
  abi: LoanPlatformABI,
  functionName: 'deposit',
});

// Read pool value
const { data: poolValue } = useContractRead({
  address: LOAN_PLATFORM_ADDRESS,
  abi: LoanPlatformABI,
  functionName: 'getPoolValue',
});
```

## 🔐 Important Addresses

- **Owner/Admin**: `0x366d3F2095b815e9fe65723ed8d53527B141B1E6`
- **Platform Treasury**: `0x5160352f875D9E77Fdf215c357Fc0FD5E1A3fC3f`

## ⚙️ Configuration

- **Max Utilization Rate**: 80% (8000 basis points)
- **Platform Share Ratio**: 20% (2000 basis points)
- **Investor Share**: 80% of margin profits

## 📝 Notes

1. **MockERC20 adalah test token** - untuk production gunakan stablecoin asli
2. **Decimals**: MockERC20 (6), EduLPToken (18)
3. **Permission**: Hanya owner yang bisa execute financing
4. **Murabahah Compliant**: Tidak ada bunga, hanya margin keuntungan fixed di awal

## 🐛 Troubleshooting

### "Insufficient LP token balance"
- Pastikan Anda sudah deposit ke pool terlebih dahulu

### "Only student can repay their financing"
- Pastikan Anda menggunakan wallet mahasiswa yang benar

### "Insufficient liquidity in pool"
- Pool tidak memiliki cukup dana tunai untuk penarikan
- Tunggu hingga ada repayment atau investor lain deposit

### "Utilization rate exceeded"
- Pool sudah mencapai batas utilisasi 80%
- Tunggu repayment atau investor deposit lebih banyak

## 📚 Documentation

- [Full Deployment Details](./DEPLOYMENT_ADDRESSES.md)
- [Contract Source Code](./src/)
- [Tests](./test/)
- [PRD](../tasks/prd-blockchain-student-loan-platform.md)

## 🎉 Next Steps

1. ✅ Contracts deployed and verified
2. 🔄 Test the complete flow
3. 🔄 Build frontend interface
4. 🔄 Add more features (notifications, analytics, etc.)
5. 🔄 Security audit before mainnet deployment

