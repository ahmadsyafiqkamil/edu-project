# Cara Mendapatkan Address untuk Constructor LoanPlatform

## Quick Answer

### 1. `_underlyingTokenAddress`
**BUKAN** address dari EduLPToken.  
**ADALAH** address dari token ERC20 yang sudah ada (seperti USDC, USDT, DAI).

**Cara Mendapatkan:**
- **Untuk Testing**: Deploy MockERC20 (lihat `script/Deploy.s.sol`)
- **Untuk Testnet**: Cari address USDC/USDT di testnet explorer
- **Untuk Mainnet**: Gunakan address USDC/USDT yang sudah terkenal

### 2. `_platformTreasury`
**BUKAN** address dari LoanPlatform contract.  
**ADALAH** address wallet yang akan menerima fee platform (20%).

**Cara Mendapatkan:**
- Gunakan address wallet MetaMask Anda sendiri
- Atau buat wallet baru khusus untuk treasury

---

## Langkah-Langkah Praktis

### Opsi A: Untuk Development/Testing (Mudah)

1. **Deploy Mock Token** (untuk `_underlyingTokenAddress`):
   ```bash
   # Mock token akan di-deploy otomatis oleh script Deploy.s.sol
   ```

2. **Gunakan Wallet Anda** (untuk `_platformTreasury`):
   - Buka MetaMask
   - Copy address wallet Anda
   - Contoh: `0x1234...5678`

3. **Deploy LoanPlatform**:
   ```bash
   export PRIVATE_KEY=your_private_key
   export PLATFORM_TREASURY=0xYourWalletAddress
   forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL --broadcast
   ```

### Opsi B: Untuk Testnet dengan Token Real

1. **Cari Address USDC di Testnet**:
   - Buka [Sepolia Explorer](https://sepolia.etherscan.io/)
   - Cari "USDC" atau "USD Coin"
   - Copy contract address
   - Contoh Sepolia USDC: `0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8`

2. **Gunakan Wallet Anda** (untuk `_platformTreasury`):
   - Sama seperti Opsi A

3. **Edit Deploy.s.sol**:
   ```solidity
   // Ganti bagian OPTION 2
   address underlyingTokenAddress = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8; // USDC Sepolia
   ```

### Opsi C: Untuk Mainnet (Production)

1. **Gunakan USDC Mainnet**:
   - Address: `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
   - Atau USDT: `0xdAC17F958D2ee523a2206206994597C13D831ec7`

2. **Gunakan Multi-Sig Wallet** (untuk `_platformTreasury`):
   - Lebih aman untuk production
   - Atau gunakan wallet tim yang terpercaya

---

## Contoh Lengkap

### Scenario: Testing di Local/Testnet

```solidity
// Di Deploy.s.sol, script akan:
// 1. Deploy MockERC20 -> dapat address: 0xMockToken123...
// 2. Deploy LoanPlatform dengan:
//    - _underlyingTokenAddress = 0xMockToken123...
//    - _platformTreasury = 0xYourWalletAddress
```

### Scenario: Production

```solidity
// Manual deployment:
LoanPlatform platform = new LoanPlatform(
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, // USDC Mainnet
    0xYourTreasuryWalletAddress                   // Wallet tim
);
```

---

## Checklist Sebelum Deploy

- [ ] Sudah punya wallet untuk treasury (`_platformTreasury`)
- [ ] Sudah tahu address token yang akan digunakan (`_underlyingTokenAddress`)
- [ ] Sudah set environment variables (PRIVATE_KEY, PLATFORM_TREASURY, RPC_URL)
- [ ] Sudah test di testnet dulu sebelum mainnet

---

## FAQ

**Q: Apakah `_underlyingTokenAddress` adalah EduLPToken?**  
A: TIDAK. EduLPToken dibuat otomatis di dalam constructor LoanPlatform.

**Q: Apakah `_platformTreasury` adalah LoanPlatform contract?**  
A: TIDAK. Ini adalah wallet yang akan menerima fee platform.

**Q: Perlu buat contract baru untuk kedua address?**  
A: TIDAK. Gunakan token yang sudah ada (USDC/USDT) dan wallet biasa untuk treasury.

**Q: Bisa pakai address(0)?**  
A: TIDAK. Constructor akan reject dengan error "Invalid address".







