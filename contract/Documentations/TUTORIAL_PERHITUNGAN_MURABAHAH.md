# Tutorial: Perhitungan Murabahah untuk SPP 10 Juta, Tenor 1 Tahun

## 📚 Konsep Dasar Murabahah

**Murabahah** adalah akad jual-beli dengan margin keuntungan yang **disepakati di awal**. Berbeda dengan pinjaman konvensional yang menggunakan bunga, Murabahah menggunakan prinsip:

1. Platform **membeli** jasa pendidikan (SPP) untuk mahasiswa
2. Platform **menjual kembali** kepada mahasiswa dengan harga yang sudah ditentukan
3. Harga jual = Harga pokok + Margin keuntungan (yang sudah disepakati)

**PENTING:** Margin keuntungan ini **FIXED** (tetap) dan tidak berubah selama masa pembiayaan, sesuai prinsip syariah.

---

## 🎯 Kasus Anda

- **SPP yang Dibutuhkan:** Rp 10.000.000 (Harga Pokok)
- **Tenor:** 12 bulan (1 tahun)
- **Margin Rate:** Misalkan platform menetapkan **5% per tahun** (500 basis points)

---

## 📊 Langkah-Langkah Perhitungan

### **Langkah 1: Hitung Total Margin Keuntungan**

Rumus:
```
Total Margin = (Harga Pokok × Margin Rate × Tenor Bulan) / (12 × 10000)
```

Perhitungan:
```
Total Margin = (10.000.000 × 500 × 12) / (12 × 10.000)
             = (10.000.000 × 500 × 12) / 120.000
             = 60.000.000.000 / 120.000
             = 500.000
```

**Total Margin = Rp 500.000**

**Penjelasan:**
- Margin rate 5% per tahun = 500 basis points (Bps)
- Karena tenor 1 tahun penuh (12 bulan), margin yang dikenakan adalah 5% dari harga pokok
- 5% × Rp 10.000.000 = Rp 500.000

---

### **Langkah 2: Hitung Harga Jual (Total Kewajiban)**

Rumus:
```
Harga Jual = Harga Pokok + Total Margin
```

Perhitungan:
```
Harga Jual = 10.000.000 + 500.000
           = 10.500.000
```

**Total yang Harus Dibayar Mahasiswa = Rp 10.500.000**

---

### **Langkah 3: Hitung Angsuran Bulanan**

Rumus:
```
Angsuran Bulanan = Harga Jual / Tenor Bulan
```

Perhitungan:
```
Angsuran Bulanan = 10.500.000 / 12
                 = 875.000
```

**Angsuran Bulanan = Rp 875.000**

---

## 📋 Ringkasan Perhitungan

| Item | Nilai |
|------|-------|
| **Harga Pokok (SPP)** | Rp 10.000.000 |
| **Margin Rate (Tahunan)** | 5% |
| **Tenor** | 12 bulan |
| **Total Margin** | Rp 500.000 |
| **Harga Jual (Total Kewajiban)** | Rp 10.500.000 |
| **Angsuran Bulanan** | Rp 875.000 |

---

## 💡 Contoh Skenario Lain

### **Skenario A: Tenor 6 Bulan (Margin Rate 5%)**

- Harga Pokok: Rp 10.000.000
- Margin Rate: 5% per tahun
- Tenor: 6 bulan

**Perhitungan:**
```
Total Margin = (10.000.000 × 500 × 6) / (12 × 10.000)
             = 30.000.000.000 / 120.000
             = 250.000

Harga Jual = 10.000.000 + 250.000 = 10.250.000
Angsuran Bulanan = 10.250.000 / 6 = 1.708.333
```

**Hasil:** Angsuran bulanan lebih besar (Rp 1.708.333) karena tenor lebih pendek.

---

### **Skenario B: Tenor 12 Bulan (Margin Rate 10%)**

- Harga Pokok: Rp 10.000.000
- Margin Rate: 10% per tahun
- Tenor: 12 bulan

**Perhitungan:**
```
Total Margin = (10.000.000 × 1000 × 12) / (12 × 10.000)
             = 120.000.000.000 / 120.000
             = 1.000.000

Harga Jual = 10.000.000 + 1.000.000 = 11.000.000
Angsuran Bulanan = 11.000.000 / 12 = 916.667
```

**Hasil:** Total kewajiban lebih besar karena margin rate lebih tinggi.

---

## 🔍 Perbedaan dengan Pinjaman Konvensional

| Aspek | Murabahah (Syariah) | Pinjaman Konvensional |
|-------|---------------------|----------------------|
| **Dasar Hukum** | Jual-beli dengan margin | Pinjaman dengan bunga |
| **Perhitungan** | Margin **FIXED** di awal | Bunga bisa berubah (floating) |
| **Kepastian** | Total kewajiban **sudah pasti** sejak awal | Total kewajiban bisa berubah |
| **Prinsip** | Platform membeli lalu menjual kembali | Pemberi pinjaman memberikan uang |

---

## ✅ Keuntungan Murabahah untuk Mahasiswa

1. **Transparan:** Total kewajiban sudah jelas sejak awal
2. **Tetap:** Angsuran tidak berubah selama masa pembiayaan
3. **Sesuai Syariah:** Tidak ada unsur riba (bunga)
4. **Dana Langsung ke Universitas:** Platform membayar langsung ke institusi pendidikan

---

## 🧮 Cara Menggunakan Kalkulator di Smart Contract

Jika Anda ingin menghitung sendiri menggunakan smart contract:

```solidity
// Contoh: Hitung untuk SPP 10 juta, margin 5%, tenor 12 bulan
// Asumsi: 1 USDC = Rp 15.000, jadi 10 juta = 666.666.666 (dalam satuan terkecil, 6 desimal)

uint256 purchasePrice = 666666666; // 10 juta dalam USDC (6 desimal)
uint256 marginRateBps = 500;        // 5% = 500 basis points
uint256 tenureMonths = 12;          // 12 bulan

(uint256 sellingPrice, uint256 totalMargin, uint256 monthlyInstallment) = 
    loanPlatform.quoteFinancing(purchasePrice, marginRateBps, tenureMonths);

// Hasil:
// sellingPrice = 700000000 (10.5 juta)
// totalMargin = 33333334 (500 ribu)
// monthlyInstallment = 58333333 (875 ribu per bulan)
```

---

## 📝 Catatan Penting

1. **Margin Rate adalah Annual Rate:** Margin 5% per tahun berarti jika tenor 1 tahun penuh, margin yang dikenakan adalah 5% dari harga pokok.

2. **Angsuran Tetap:** Setiap bulan mahasiswa membayar jumlah yang sama (Rp 875.000) selama 12 bulan.

3. **Tidak Ada Bunga Berbunga:** Berbeda dengan sistem bunga kompound, Murabahah menggunakan margin flat yang sudah ditentukan di awal.

4. **Dana Langsung ke Universitas:** Platform akan mentransfer Rp 10.000.000 langsung ke rekening universitas, bukan ke mahasiswa.

---

## 🎓 Kesimpulan

Untuk kasus Anda:
- **SPP:** Rp 10.000.000
- **Tenor:** 12 bulan
- **Margin:** 5% per tahun

**Total yang harus dibayar:** Rp 10.500.000  
**Angsuran bulanan:** Rp 875.000 (selama 12 bulan)

Semua angka ini **FIXED** dan tidak akan berubah selama masa pembiayaan! ✅

