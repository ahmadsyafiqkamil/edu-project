# Dokumentasi Kalkulator Murabahah

Dokumen ini menjelaskan logika perhitungan angsuran untuk pembiayaan Murabahah di platform ini.

## Rumus Perhitungan

Akad **Murabahah** adalah jual beli dengan margin keuntungan yang disepakati.

### 1. Menghitung Margin Keuntungan (Profit Margin)
Margin dihitung berdasarkan tingkat keuntungan tahunan (annual rate) yang diinginkan platform, dikalikan dengan harga pokok dan durasi pembiayaan.

$$ \text{Total Margin} = \frac{\text{Harga Pokok} \times \text{Rate Tahunan} \times \text{Durasi Bulan}}{12 \times 100\%} $$

Dalam implementasi smart contract, kita menggunakan Basis Points (Bps) di mana 1% = 100 Bps.

Rumus Solidity:
```solidity
totalMargin = (purchasePrice * marginRateBps * tenureMonths) / (12 * 10000);
```

### 2. Menghitung Harga Jual (Selling Price)
Harga jual adalah total yang harus dibayar mahasiswa.

$$ \text{Harga Jual} = \text{Harga Pokok} + \text{Total Margin} $$

### 3. Menghitung Angsuran Bulanan (Monthly Installment)
Angsuran bersifat tetap (*fixed*) setiap bulan.

$$ \text{Angsuran} = \frac{\text{Harga Jual}}{\text{Durasi Bulan}} $$

## Contoh Perhitungan

**Skenario:**
- **Harga Pokok (SPP):** 10.000 USDC
- **Margin Rate:** 5% per tahun (500 Bps)
- **Tenor:** 12 Bulan

**Perhitungan:**
1.  **Total Margin:**
    $$ (10.000 \times 500 \times 12) / (12 \times 10.000) = 500 \text{ USDC} $$
2.  **Harga Jual:**
    $$ 10.000 + 500 = 10.500 \text{ USDC} $$
3.  **Angsuran Bulanan:**
    $$ 10.500 / 12 = 875 \text{ USDC} $$

## Cara Menggunakan

### Di Smart Contract
Telah ditambahkan fungsi helper di `LoanPlatform.sol`:

```solidity
function quoteFinancing(
    uint256 _purchasePrice,
    uint256 _marginRateBps,
    uint256 _tenureMonths
) external pure returns (uint256 sellingPrice, uint256 totalMargin, uint256 monthlyInstallment);
```

Anda bisa memanggil fungsi ini (gratis, tanpa gas karena `pure`/`view`) dari frontend untuk menampilkan estimasi cicilan kepada mahasiswa sebelum mereka mengajukan.

### Contoh Script JavaScript/TypeScript

Gunakan fungsi ini di frontend/backend aplikasi Anda:

```javascript
/**
 * Menghitung detail pembiayaan Murabahah
 * @param {number} purchasePrice - Harga pokok (dalam satuan terkecil, misal wei/6 desimal)
 * @param {number} rateBps - Margin rate tahunan dalam basis points (e.g. 500 = 5%)
 * @param {number} months - Durasi bulan
 * @returns {object} Detail perhitungan
 */
function calculateMurabahah(purchasePrice, rateBps, months) {
  // Hindari floating point error dengan BigInt jika memungkinkan
  const price = BigInt(purchasePrice);
  const rate = BigInt(rateBps);
  const tenure = BigInt(months);
  const bps = BigInt(10000);
  const twelve = BigInt(12);

  // Rumus: (P * R * T) / (12 * 10000)
  const totalMargin = (price * rate * tenure) / (twelve * bps);
  const sellingPrice = price + totalMargin;
  const monthlyInstallment = sellingPrice / tenure;

  return {
    sellingPrice: sellingPrice.toString(),
    totalMargin: totalMargin.toString(),
    monthlyInstallment: monthlyInstallment.toString()
  };
}

// Contoh penggunaan (10,000 USDC, 5%, 12 bulan)
const result = calculateMurabahah(10000000000, 500, 12);
console.log(result);
```

## Pengujian

Telah dibuat unit test di `contract/test/MurabahahCalculator.t.sol` untuk memverifikasi logika perhitungan ini. Jalankan dengan:

```bash
forge test --match-contract MurabahahCalculatorTest
```

