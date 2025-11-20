# Penjelasan Address di Constructor LoanPlatform

## 1. `_underlyingTokenAddress` (Parameter Pertama)

### Apa itu?
- **BUKAN** address dari `EduLPToken`
- **ADALAH** address dari token ERC20 stablecoin yang sudah ada di blockchain
- Token ini digunakan sebagai "underlying asset" di liquidity pool

### Contoh Token yang Bisa Digunakan:
- **USDC** (USD Coin) - Stablecoin paling populer
- **USDT** (Tether)
- **DAI** (Dai Stablecoin)
- Token ERC20 lainnya yang sudah di-deploy

### Bagaimana Mendapatkan Address-nya?

#### Untuk Testnet (Sepolia/Lisk Sepolia):
- **USDC Sepolia**: `0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8` (contoh, cek di explorer)
- Atau buat mock token sendiri untuk testing

#### Untuk Mainnet:
- **USDC Ethereum**: `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- **USDT Ethereum**: `0xdAC17F958D2ee523a2206206994597C13D831ec7`

### Apakah Perlu Membuat Contract Baru?
- **TIDAK** untuk production (gunakan token yang sudah ada seperti USDC)
- **YA** untuk testing (buat mock ERC20 token)

---

## 2. `_platformTreasury` (Parameter Kedua)

### Apa itu?
- **BUKAN** address dari contract `LoanPlatform`
- **ADALAH** address wallet atau contract yang akan menerima bagian keuntungan platform (20%)
- Address ini akan menerima transfer dari fungsi `repay()` saat mahasiswa membayar angsuran

### Bisa Berupa:
1. **EOA (Externally Owned Account)**: Wallet biasa seperti MetaMask
   - Contoh: `0x1234567890123456789012345678901234567890`
   - Paling sederhana untuk MVP

2. **Smart Contract**: Contract khusus untuk treasury
   - Lebih kompleks, bisa ditambahkan logika tambahan
   - Contoh: Multi-sig wallet, timelock contract

### Bagaimana Mendapatkan Address-nya?

#### Opsi 1: Gunakan Wallet Anda Sendiri (Paling Sederhana)
```javascript
// Di MetaMask atau wallet lain, copy address wallet Anda
// Contoh: 0xYourWalletAddress123...
```

#### Opsi 2: Buat Wallet Baru Khusus untuk Treasury
- Buat wallet baru di MetaMask
- Simpan private key dengan aman
- Gunakan address wallet tersebut

#### Opsi 3: Buat Contract Treasury (Opsional, untuk Production)
- Buat contract khusus untuk menerima dan mengelola dana platform
- Deploy contract tersebut
- Gunakan address contract yang di-deploy

### Apakah Perlu Membuat Contract Baru?
- **TIDAK** untuk MVP (gunakan wallet biasa)
- **OPSIONAL** untuk production (bisa buat contract treasury jika perlu)

---

## Ringkasan

| Parameter | Apa Itu? | Perlu Buat Contract? | Contoh |
|-----------|----------|----------------------|--------|
| `_underlyingTokenAddress` | Address token ERC20 yang sudah ada (USDC, USDT, dll) | ❌ Tidak (kecuali untuk testing) | `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` (USDC Mainnet) |
| `_platformTreasury` | Address wallet/contract yang terima fee platform | ❌ Tidak (gunakan wallet biasa) | `0xYourWalletAddress...` |

---

## Contoh Deployment

Lihat file `script/Deploy.s.sol` untuk contoh lengkap deployment script.





