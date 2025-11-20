# Deployment Scripts

Script untuk deploy semua contract ke blockchain network.

## File Script

1. **Deploy.s.sol** - Script utama untuk deploy semua contract sekaligus
2. **DeployMockERC20.s.sol** - Script untuk deploy MockERC20 token secara terpisah
3. **DeployLoanPlatform.s.sol** - Script untuk deploy LoanPlatform (auto-deploy EduLPToken)

## Cara Menggunakan

### 1. Deploy Semua Contract (Recommended)

Script `Deploy.s.sol` akan deploy semua contract yang diperlukan:

```bash
# Set environment variables
export PRIVATE_KEY=your_private_key
export RPC_URL=https://rpc.sepolia-api.lisk.com/...
export PLATFORM_TREASURY=0xYourTreasuryWalletAddress

# Optional: Gunakan token yang sudah ada
export UNDERLYING_TOKEN_ADDRESS=0x... # Jika tidak di-set, akan deploy MockERC20

# Deploy
forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL --broadcast --verify
```

**Fitur:**
- Otomatis deploy MockERC20 jika `UNDERLYING_TOKEN_ADDRESS` tidak di-set
- Deploy LoanPlatform dengan parameter yang benar
- EduLPToken otomatis di-deploy oleh LoanPlatform
- Menampilkan summary lengkap setelah deployment

### 2. Deploy MockERC20 Terpisah

Jika ingin deploy MockERC20 terpisah:

```bash
export PRIVATE_KEY=your_private_key
export RPC_URL=https://rpc.sepolia-api.lisk.com/...

# Optional: Custom parameters
export TOKEN_NAME="Mock USDC"
export TOKEN_SYMBOL="mUSDC"
export TOKEN_DECIMALS=6
export INITIAL_SUPPLY=1000000000

forge script script/DeployMockERC20.s.sol:DeployMockERC20 --rpc-url $RPC_URL --broadcast
```

### 3. Deploy LoanPlatform Terpisah

Jika MockERC20 sudah di-deploy sebelumnya:

```bash
export PRIVATE_KEY=your_private_key
export RPC_URL=https://rpc.sepolia-api.lisk.com/...
export UNDERLYING_TOKEN_ADDRESS=0x... # Address MockERC20 atau token lain
export PLATFORM_TREASURY=0xYourTreasuryWalletAddress

forge script script/DeployLoanPlatform.s.sol:DeployLoanPlatform --rpc-url $RPC_URL --broadcast
```

## Environment Variables

### Required
- `PRIVATE_KEY` - Private key untuk deploy (tanpa 0x prefix)
- `RPC_URL` - RPC endpoint untuk network
- `PLATFORM_TREASURY` - Address wallet untuk platform treasury (hanya untuk DeployLoanPlatform)

### Optional
- `UNDERLYING_TOKEN_ADDRESS` - Address token yang sudah ada (jika tidak di-set, akan deploy MockERC20)
- `TOKEN_NAME` - Nama token untuk MockERC20 (default: "Mock USDC")
- `TOKEN_SYMBOL` - Symbol token untuk MockERC20 (default: "mUSDC")
- `TOKEN_DECIMALS` - Decimals token (default: 6)
- `INITIAL_SUPPLY` - Initial supply tanpa decimals (default: 1000000000)

## Network Configuration

### Lisk Sepolia Testnet

```bash
export RPC_URL=https://rpc.sepolia-api.lisk.com/5bec97bedf0944d481a25ea6a55e985c
export BLOCKSCOUT_API_KEY=your_api_key
```

### Local Network (Anvil)

```bash
export RPC_URL=http://localhost:8545
```

## Verification

Setelah deployment, contract bisa di-verify menggunakan Forge:

```bash
# Verify MockERC20
forge verify-contract <ADDRESS> \
  src/MockERC20.sol:MockERC20 \
  --chain-id <CHAIN_ID> \
  --etherscan-api-key $BLOCKSCOUT_API_KEY

# Verify LoanPlatform
forge verify-contract <ADDRESS> \
  src/LoanPlatform.sol:LoanPlatform \
  --chain-id <CHAIN_ID> \
  --etherscan-api-key $BLOCKSCOUT_API_KEY \
  --constructor-args $(cast abi-encode "constructor(address,address)" <TOKEN> <TREASURY>)

# Verify EduLPToken
forge verify-contract <ADDRESS> \
  src/EduLPToken.sol:EduLPToken \
  --chain-id <CHAIN_ID> \
  --etherscan-api-key $BLOCKSCOUT_API_KEY \
  --constructor-args $(cast abi-encode "constructor(address)" <LOAN_PLATFORM>)
```

## Catatan Penting

1. **EduLPToken** di-deploy otomatis oleh `LoanPlatform` constructor, tidak perlu deploy terpisah
2. **Owner** dari EduLPToken adalah LoanPlatform contract (bukan deployer)
3. **Platform Treasury** harus di-set dengan benar karena tidak bisa diubah setelah deployment
4. Pastikan memiliki cukup gas untuk deployment
5. Simpan semua address yang di-deploy untuk referensi selanjutnya

## Troubleshooting

### Error: "Invalid private key"
- Pastikan PRIVATE_KEY tidak memiliki prefix `0x`
- Pastikan private key valid

### Error: "Insufficient funds"
- Pastikan wallet memiliki cukup ETH/token untuk gas fees

### Error: "Contract verification failed"
- Pastikan constructor args sesuai dengan yang digunakan saat deploy
- Pastikan chain-id benar
- Pastikan API key valid


