# Dokumentasi Kontrak Smart Contract

## Daftar Isi
1. [EduLPToken.sol](#edulptokensol)
2. [LoanPlatform.sol](#loanplatformsol)
3. [MockERC20.sol](#mockerc20sol)

---

## EduLPToken.sol

### Deskripsi
Kontrak `EduLPToken` adalah token ERC20 yang mewakili kepemilikan proporsional investor dalam liquidity pool platform pembiayaan pendidikan. Token ini hanya dapat di-mint dan di-burn oleh kontrak `LoanPlatform`.

### Inheritance
- `ERC20`: Dari OpenZeppelin, memberikan fungsi standar token ERC20 (transfer, balance, dll)
- `Ownable`: Dari OpenZeppelin, memberikan kontrol kepemilikan kontrak

### State Variables

#### `loanPlatform` (address public)
- **Tipe**: `address`
- **Visibilitas**: Public
- **Deskripsi**: Alamat kontrak `LoanPlatform` yang memiliki otoritas untuk melakukan mint dan burn token LP. Hanya dapat di-set sekali oleh owner.

### Events

#### `EduLPTokenMinted(address indexed to, uint256 amount)`
- **Parameter**:
  - `to`: Alamat yang menerima token LP
  - `amount`: Jumlah token LP yang di-mint
- **Deskripsi**: Dipanggil ketika token LP baru di-mint

#### `EduLPTokenBurned(address indexed from, uint256 amount)`
- **Parameter**:
  - `from`: Alamat yang token LP-nya dibakar
  - `amount`: Jumlah token LP yang di-burn
- **Deskripsi**: Dipanggil ketika token LP dibakar

### Modifiers

#### `onlyLoanPlatform()`
- **Deskripsi**: Memastikan hanya kontrak `LoanPlatform` yang dapat memanggil fungsi tertentu
- **Penggunaan**: Digunakan pada fungsi `mint()` dan `burn()`

### Functions

#### `constructor(address initialOwner)`
- **Tipe**: Constructor
- **Parameter**:
  - `initialOwner`: Alamat yang akan menjadi owner kontrak
- **Deskripsi**: 
  - Menginisialisasi kontrak dengan nama "Education LP Token" dan symbol "eduLP"
  - Menetapkan owner kontrak
  - Memanggil constructor ERC20 dan Ownable
- **Visibility**: Public

#### `setLoanPlatform(address _loanPlatform) external onlyOwner()`
- **Tipe**: External, hanya owner
- **Parameter**:
  - `_loanPlatform`: Alamat kontrak LoanPlatform
- **Deskripsi**: 
  - Menetapkan alamat kontrak LoanPlatform
  - Hanya dapat dipanggil sekali (loanPlatform harus address(0))
  - Validasi alamat tidak boleh address(0)
- **Revert Conditions**:
  - Jika alamat adalah address(0): "Invalid address"
  - Jika loanPlatform sudah di-set: "already set"
- **Visibility**: External (hanya owner)

#### `mint(address to, uint256 amount) external onlyLoanPlatform`
- **Tipe**: External, hanya LoanPlatform
- **Parameter**:
  - `to`: Alamat yang akan menerima token LP
  - `amount`: Jumlah token LP yang akan di-mint
- **Deskripsi**: 
  - Membuat token LP baru dan mengirimkannya ke alamat `to`
  - Hanya dapat dipanggil oleh kontrak LoanPlatform
  - Memicu event `EduLPTokenMinted`
- **Visibility**: External (hanya LoanPlatform)

#### `burn(address from, uint256 amount) external onlyLoanPlatform`
- **Tipe**: External, hanya LoanPlatform
- **Parameter**:
  - `from`: Alamat yang token LP-nya akan dibakar
  - `amount`: Jumlah token LP yang akan di-burn
- **Deskripsi**: 
  - Membakar token LP dari alamat `from`
  - Hanya dapat dipanggil oleh kontrak LoanPlatform
  - Memicu event `EduLPTokenBurned`
- **Revert Conditions**:
  - Jika saldo `from` tidak cukup: Revert dari ERC20 internal
- **Visibility**: External (hanya LoanPlatform)

#### `decimals() public pure override returns (uint8)`
- **Tipe**: Pure, override
- **Return**: `uint8` - Nilai 18
- **Deskripsi**: 
  - Mengembalikan jumlah desimal token (18 desimal)
  - Meng-override fungsi dari ERC20
- **Visibility**: Public

#### `remainingSupply() external view returns (uint256)`
- **Tipe**: View
- **Return**: `uint256` - Sisa supply yang dapat di-mint
- **Deskripsi**: 
  - Menghitung sisa supply yang tersedia untuk di-mint
  - Formula: `type(uint256).max - totalSupply()`
  - Berguna untuk mengetahui kapasitas maksimum token
- **Visibility**: External

---

## LoanPlatform.sol

### Deskripsi
Kontrak utama yang mengelola liquidity pool untuk pembiayaan pendidikan berbasis prinsip Murabahah (jual-beli syariah). Platform ini memungkinkan investor untuk menyetor dana dan mendapatkan token LP, serta mahasiswa untuk mendapatkan pembiayaan pendidikan dengan prinsip jual-beli bukan bunga (riba).

### Inheritance
- `Ownable`: Kontrol kepemilikan untuk fungsi admin

### State Variables

#### `underlyingToken` (IERC20 public immutable)
- **Tipe**: `IERC20`
- **Visibilitas**: Public, Immutable
- **Deskripsi**: Token stablecoin yang digunakan sebagai underlying asset (misal: USDC, USDT). Tidak dapat diubah setelah deployment.

#### `eduLpToken` (EduLPToken public immutable)
- **Tipe**: `EduLPToken`
- **Visibilitas**: Public, Immutable
- **Deskripsi**: Token LP yang mewakili kepemilikan di pool. Dibuat saat konstruksi dan tidak dapat diubah.

#### `maxUtilizationRate` (uint256 public)
- **Tipe**: `uint256`
- **Visibilitas**: Public
- **Deskripsi**: Tingkat utilisasi maksimum pool dalam basis points (1 basis point = 0.01%). Default: 8000 (80%). Format: 8000 = 80.00%

#### `platformShareRatio` (uint256 public)
- **Tipe**: `uint256`
- **Visibilitas**: Public
- **Deskripsi**: Proporsi margin keuntungan untuk platform dalam basis points. Default: 2000 (20%). Format: 2000 = 20.00%

#### `platformTreasury` (address public)
- **Tipe**: `address`
- **Visibilitas**: Public
- **Deskripsi**: Alamat dompet untuk menerima bagian margin keuntungan platform

#### `totalFinancingActive` (uint256 public)
- **Tipe**: `uint256`
- **Visibilitas**: Public
- **Deskripsi**: Total dana yang sedang dipinjamkan keluar (nilai total purchasePrice dari semua pembiayaan aktif)

#### `financings` (mapping(uint256 => Financing) public)
- **Tipe**: Mapping
- **Visibilitas**: Public
- **Deskripsi**: Mapping dari ID pembiayaan ke struct Financing

#### `nextFinancingId` (uint256 public)
- **Tipe**: `uint256`
- **Visibilitas**: Public
- **Deskripsi**: ID berikutnya yang akan digunakan untuk pembiayaan baru. Dimulai dari 1.

### Structs

#### `Financing`
```solidity
struct Financing {
    address student;            // Alamat mahasiswa yang dibiayai
    address beneficiary;        // Alamat institusi (universitas) yang menerima dana
    uint256 purchasePrice;      // Harga Pokok (yang dikirim ke universitas)
    uint256 sellingPrice;       // Harga Jual (total kewajiban mahasiswa)
    uint256 amountRepaid;       // Jumlah yang sudah dibayar kembali
    bool isActive;              // Status pembiayaan
}
```

- **Deskripsi**: Menyimpan informasi lengkap tentang pembiayaan Murabahah
  - `student`: Alamat mahasiswa yang berutang
  - `beneficiary`: Alamat institusi yang menerima dana langsung
  - `purchasePrice`: Harga pokok pembelian (dikirim ke universitas)
  - `sellingPrice`: Harga jual kepada mahasiswa (purchasePrice + margin)
  - `amountRepaid`: Total yang sudah dibayar mahasiswa
  - `isActive`: Status aktif pembiayaan

### Events

#### `Deposited(address indexed investor, uint256 underlyingAmount, uint256 lpTokensMinted)`
- **Parameter**:
  - `investor`: Alamat investor yang menyetor
  - `underlyingAmount`: Jumlah stablecoin yang disetor
  - `lpTokensMinted`: Jumlah token LP yang di-mint
- **Deskripsi**: Dipanggil saat investor menyetor dana ke pool

#### `Withdrawn(address indexed investor, uint256 lpTokensBurned, uint256 underlyingAmount)`
- **Parameter**:
  - `investor`: Alamat investor yang menarik dana
  - `lpTokensBurned`: Jumlah token LP yang dibakar
  - `underlyingAmount`: Jumlah stablecoin yang diterima
- **Deskripsi**: Dipanggil saat investor menarik dana dari pool

#### `FinancingExecuted(uint256 indexed financingId, address indexed student, address indexed beneficiary, uint256 purchasePrice, uint256 sellingPrice)`
- **Parameter**:
  - `financingId`: ID pembiayaan yang baru dibuat
  - `student`: Alamat mahasiswa
  - `beneficiary`: Alamat institusi pendidikan
  - `purchasePrice`: Harga pokok
  - `sellingPrice`: Harga jual
- **Deskripsi**: Dipanggil saat pembiayaan baru dieksekusi

#### `RepaymentMade(uint256 indexed financingId, address indexed student, uint256 amount, uint256 principalAmount, uint256 marginAmount)`
- **Parameter**:
  - `financingId`: ID pembiayaan
  - `student`: Alamat mahasiswa yang membayar
  - `amount`: Total jumlah pembayaran
  - `principalAmount`: Bagian pokok dari pembayaran
  - `marginAmount`: Bagian margin dari pembayaran
- **Deskripsi**: Dipanggil saat mahasiswa melakukan pembayaran angsuran

### Functions

#### `constructor(address _underlyingTokenAddress, address _platformTreasury) Ownable(msg.sender)`
- **Tipe**: Constructor
- **Parameter**:
  - `_underlyingTokenAddress`: Alamat token stablecoin
  - `_platformTreasury`: Alamat treasury platform
- **Deskripsi**: 
  - Menginisialisasi kontrak LoanPlatform
  - Membuat kontrak EduLPToken baru
  - Menetapkan konfigurasi default:
    - `maxUtilizationRate`: 8000 (80%)
    - `platformShareRatio`: 2000 (20%)
    - `nextFinancingId`: 1
  - Menyetel loanPlatform di EduLPToken
- **Revert Conditions**:
  - Jika `_underlyingTokenAddress` adalah address(0): "LoanPlatform: Invalid underlying token address"
  - Jika `_platformTreasury` adalah address(0): "LoanPlatform: Invalid treasury address"
- **Visibility**: Public

#### `deposit(uint256 _amount) external`
- **Tipe**: External
- **Parameter**:
  - `_amount`: Jumlah stablecoin yang akan disetor
- **Deskripsi**: 
  - Fungsi untuk investor menyetor dana ke pool
  - Menerima stablecoin dan memberikan token LP secara proporsional
  - Formula LP token:
    - Jika pool kosong: `lpTokens = _amount` (ratio 1:1)
    - Jika pool sudah ada: `lpTokens = (_amount * totalSupply) / poolValue`
  - Transfer stablecoin dari investor ke kontrak
  - Mint token LP ke investor
  - Memicu event `Deposited`
- **Revert Conditions**:
  - Jika `_amount` = 0: "LoanPlatform: Amount must be greater than zero"
  - Jika transfer gagal: "LoanPlatform: Transfer failed"
  - Jika LP tokens yang di-mint = 0: "LoanPlatform: LP tokens to mint is zero"
- **Visibility**: External
- **Access Control**: Public (siapa saja bisa deposit)

#### `withdraw(uint256 _lpTokenAmount) external`
- **Tipe**: External
- **Parameter**:
  - `_lpTokenAmount`: Jumlah token LP yang akan ditukar
- **Deskripsi**: 
  - Fungsi untuk investor menarik dana dari pool
  - Membakar token LP dan mengembalikan stablecoin secara proporsional
  - Formula: `underlyingAmount = (_lpTokenAmount * poolValue) / totalSupply`
  - Validasi likuiditas tunai cukup untuk penarikan
  - Burn token LP dari investor
  - Transfer stablecoin ke investor
  - Memicu event `Withdrawn`
- **Revert Conditions**:
  - Jika `_lpTokenAmount` = 0: "LoanPlatform: LP token amount must be greater than zero"
  - Jika saldo LP token tidak cukup: "LoanPlatform: Insufficient LP token balance"
  - Jika tidak ada LP token dalam sirkulasi: "LoanPlatform: No LP tokens in circulation"
  - Jika likuiditas tidak cukup: "LoanPlatform: Insufficient liquidity in pool"
  - Jika transfer gagal: "LoanPlatform: Transfer failed"
- **Visibility**: External
- **Access Control**: Public (investor dengan LP token)

#### `executeFinancing(address _student, address _beneficiary, uint256 _purchasePrice, uint256 _sellingPrice) external onlyOwner`
- **Tipe**: External, hanya owner
- **Parameter**:
  - `_student`: Alamat mahasiswa yang dibiayai
  - `_beneficiary`: Alamat institusi pendidikan
  - `_purchasePrice`: Harga pokok pembelian
  - `_sellingPrice`: Harga jual kepada mahasiswa
- **Deskripsi**: 
  - Fungsi admin untuk mengeksekusi pembiayaan Murabahah
  - Transfer `purchasePrice` langsung ke institusi pendidikan (bukan ke mahasiswa)
  - Validasi tingkat utilisasi tidak melebihi batas maksimum
  - Mencatat pembiayaan baru dalam mapping
  - Memicu event `FinancingExecuted`
- **Revert Conditions**:
  - Jika `_student` adalah address(0): "LoanPlatform: Invalid student address"
  - Jika `_beneficiary` adalah address(0): "LoanPlatform: Invalid beneficiary address"
  - Jika `_purchasePrice` = 0: "LoanPlatform: Purchase price must be greater than zero"
  - Jika `_sellingPrice` < `_purchasePrice`: "LoanPlatform: Selling price must be >= purchase price"
  - Jika pool kosong: "LoanPlatform: Pool is empty"
  - Jika tingkat utilisasi melebihi batas: "LoanPlatform: Utilization rate exceeded"
  - Jika likuiditas tunai tidak cukup: "LoanPlatform: Insufficient cash in pool"
  - Jika transfer ke beneficiary gagal: "LoanPlatform: Transfer to beneficiary failed"
- **Visibility**: External (hanya owner)
- **Access Control**: Owner only

#### `repay(uint256 _financingId, uint256 _amount) external`
- **Tipe**: External
- **Parameter**:
  - `_financingId`: ID pembiayaan yang akan dibayar
  - `_amount`: Jumlah yang dibayar
- **Deskripsi**: 
  - Fungsi untuk mahasiswa membayar angsuran pembiayaan
  - Memisahkan pembayaran menjadi pokok dan margin
  - Formula pemisahan:
    - `principalAmount = (_amount * purchasePrice) / sellingPrice`
    - `marginAmount = _amount - principalAmount`
  - Distribusi margin:
    - 80% untuk investor (tetap di pool, meningkatkan nilai LP token)
    - 20% untuk platform (ditransfer ke platformTreasury)
  - Update `amountRepaid` dan `totalFinancingActive`
  - Jika lunas, set `isActive = false`
  - Memicu event `RepaymentMade`
- **Revert Conditions**:
  - Jika `_amount` = 0: "LoanPlatform: Amount must be greater than zero"
  - Jika pembiayaan tidak aktif: "LoanPlatform: Financing is not active"
  - Jika bukan mahasiswa yang membayar: "LoanPlatform: Only student can repay their financing"
  - Jika jumlah melebihi sisa utang: "LoanPlatform: Amount exceeds remaining debt"
  - Jika transfer gagal: "LoanPlatform: Transfer failed"
  - Jika transfer ke treasury gagal: "LoanPlatform: Transfer to treasury failed"
- **Visibility**: External
- **Access Control**: Hanya mahasiswa yang memiliki pembiayaan tersebut

#### `getPoolValue() public view returns (uint256)`
- **Tipe**: View
- **Return**: `uint256` - Total nilai pool dalam stablecoin
- **Deskripsi**: 
  - Menghitung total nilai aset di pool
  - Formula: `balanceOf(underlyingToken) + totalFinancingActive`
  - Nilai pool = tunai + dana yang dipinjamkan
- **Visibility**: Public

#### `getLpTokenValue() public view returns (uint256)`
- **Tipe**: View
- **Return**: `uint256` - Nilai 1 token LP dalam stablecoin (dengan 18 desimal)
- **Deskripsi**: 
  - Menghitung nilai per token LP
  - Formula: `(poolValue * 1e18) / totalSupply`
  - Jika supply = 0, return 1e18 (asumsi 1:1)
  - Nilai LP token meningkat seiring dengan margin keuntungan yang masuk
- **Visibility**: Public

#### `getFinancing(uint256 _financingId) external view returns (Financing memory)`
- **Tipe**: View
- **Parameter**:
  - `_financingId`: ID pembiayaan
- **Return**: `Financing memory` - Struct dengan semua detail pembiayaan
- **Deskripsi**: 
  - Mengembalikan informasi lengkap pembiayaan berdasarkan ID
  - Termasuk semua field dari struct Financing
- **Visibility**: External

#### `getRemainingDebt(uint256 _financingId) external view returns (uint256)`
- **Tipe**: View
- **Parameter**:
  - `_financingId`: ID pembiayaan
- **Return**: `uint256` - Sisa kewajiban yang harus dibayar
- **Deskripsi**: 
  - Menghitung sisa utang mahasiswa
  - Formula: `sellingPrice - amountRepaid`
  - Jika pembiayaan tidak aktif, return 0
- **Visibility**: External

#### `getUtilizationRate() external view returns (uint256)`
- **Tipe**: View
- **Return**: `uint256` - Tingkat utilisasi dalam basis points (contoh: 8000 = 80%)
- **Deskripsi**: 
  - Menghitung persentase dana yang sedang dipinjamkan
  - Formula: `(totalFinancingActive * 10000) / poolValue`
  - Return 0 jika pool kosong
  - Format: 8000 = 80.00%
- **Visibility**: External

---

## MockERC20.sol

### Deskripsi
Kontrak token ERC20 mock untuk keperluan testing dan development. Token ini dapat digunakan sebagai `underlyingToken` di `LoanPlatform` selama fase pengembangan dan pengujian.

### Inheritance
- `ERC20`: Dari OpenZeppelin, implementasi standar ERC20

### State Variables

#### `_decimals` (uint8 private)
- **Tipe**: `uint8`
- **Visibilitas**: Private
- **Deskripsi**: Jumlah desimal token. Dapat diset saat konstruksi (biasanya 6 untuk USDC, 18 untuk token umum).

### Functions

#### `constructor(string memory name, string memory symbol, uint8 decimals_, uint256 initialSupply) ERC20(name, symbol)`
- **Tipe**: Constructor
- **Parameter**:
  - `name`: Nama token (misal: "Mock USDC")
  - `symbol`: Simbol token (misal: "mUSDC")
  - `decimals_`: Jumlah desimal token (misal: 6 untuk USDC, 18 untuk token standar)
  - `initialSupply`: Jumlah token awal yang akan di-mint ke deployer
- **Deskripsi**: 
  - Menginisialisasi token ERC20 dengan nama dan symbol
  - Menetapkan jumlah desimal
  - Mint `initialSupply` token ke alamat yang melakukan deploy
- **Visibility**: Public

#### `decimals() public view virtual override returns (uint8)`
- **Tipe**: View, Virtual, Override
- **Return**: `uint8` - Jumlah desimal token
- **Deskripsi**: 
  - Mengembalikan jumlah desimal token
  - Override fungsi dari ERC20 untuk menggunakan nilai custom
- **Visibility**: Public

#### `mint(address to, uint256 amount) external`
- **Tipe**: External
- **Parameter**:
  - `to`: Alamat yang akan menerima token
  - `amount`: Jumlah token yang akan di-mint
- **Deskripsi**: 
  - Fungsi untuk membuat token baru (untuk testing)
  - Dapat dipanggil oleh siapa saja (tidak ada access control)
  - **PERINGATAN**: Hanya untuk testing/development, jangan digunakan di mainnet tanpa access control
- **Visibility**: External
- **Access Control**: Public (tidak ada pembatasan)

---

## Catatan Penting

### Prinsip Syariah
Platform ini menggunakan akad **Murabahah** (jual-beli), bukan riba (bunga):
- Platform membeli dari institusi pendidikan (purchase price)
- Platform menjual kepada mahasiswa dengan margin keuntungan (selling price)
- Mahasiswa membayar secara angsuran (pokok + margin)
- Margin dibagi antara investor pool (80%) dan platform (20%)

### Keamanan
- Semua fungsi penting memiliki validasi input
- Access control menggunakan OpenZeppelin Ownable
- EduLPToken hanya dapat di-mint/burn oleh LoanPlatform
- Transfer menggunakan safe transfer dari ERC20

### Keterbatasan
- `MockERC20` tidak memiliki access control pada `mint()` - hanya untuk testing
- Tidak ada mekanisme emergency pause
- Tidak ada mekanisme upgrade (kontrak immutable)

---

## Cara Menggunakan

### Prasyarat
- Wallet dengan koneksi ke blockchain (MetaMask, WalletConnect, dll)
- Token stablecoin (USDC/USDT) untuk transaksi
- Akses ke kontrak yang sudah di-deploy

---

### 1. Deploy Kontrak

#### Langkah 1: Deploy MockERC20 (untuk Testing)
```solidity
// Deploy MockERC20 dengan parameter:
// name: "USD Coin"
// symbol: "USDC"
// decimals: 6
// initialSupply: 1_000_000 * 10**6 (1 juta USDC)
MockERC20 underlyingToken = new MockERC20("USD Coin", "USDC", 6, 1_000_000 * 10**6);
```

#### Langkah 2: Deploy LoanPlatform
```solidity
// Deploy LoanPlatform dengan parameter:
// _underlyingTokenAddress: address(underlyingToken)
// _platformTreasury: 0x... (alamat treasury platform)
LoanPlatform loanPlatform = new LoanPlatform(
    address(underlyingToken),
    0x... // platformTreasury address
);
```

#### Langkah 3: Verifikasi Deployment
- `EduLPToken` akan otomatis dibuat oleh `LoanPlatform`
- Dapatkan alamat token LP: `loanPlatform.eduLpToken()`
- Verifikasi konfigurasi: `maxUtilizationRate` (default: 8000 = 80%), `platformShareRatio` (default: 2000 = 20%)

---

### 2. Alur Investor (Penyedia Dana)

#### 2.1 Deposit Dana ke Pool

**Langkah-langkah:**
1. **Approve token** ke kontrak LoanPlatform
2. **Panggil fungsi deposit** dengan jumlah yang ingin disetor
3. **Terima token LP** sebagai bukti kepemilikan

**Contoh menggunakan ethers.js:**
```javascript
const underlyingToken = new ethers.Contract(usdcAddress, erc20ABI, signer);
const loanPlatform = new ethers.Contract(platformAddress, loanPlatformABI, signer);

// 1. Approve token
const depositAmount = ethers.parseUnits("100000", 6); // 100k USDC (6 decimals)
await underlyingToken.approve(platformAddress, depositAmount);

// 2. Deposit
const tx = await loanPlatform.deposit(depositAmount);
const receipt = await tx.wait();

// 3. Cek balance LP token
const eduLPToken = new ethers.Contract(
    await loanPlatform.eduLpToken(),
    erc20ABI,
    signer
);
const lpBalance = await eduLPToken.balanceOf(signer.address);
console.log(`LP Token Balance: ${ethers.formatUnits(lpBalance, 18)}`);
```

**Contoh menggunakan web3.js:**
```javascript
const depositAmount = web3.utils.toBN(100000).mul(web3.utils.toBN(10).pow(web3.utils.toBN(6)));

// 1. Approve
await underlyingToken.methods.approve(platformAddress, depositAmount).send({from: investorAddress});

// 2. Deposit
await loanPlatform.methods.deposit(depositAmount).send({from: investorAddress});

// 3. Cek LP balance
const lpTokenAddress = await loanPlatform.methods.eduLpToken().call();
const lpBalance = await eduLPToken.methods.balanceOf(investorAddress).call();
```

**Event yang dipicu:**
- `Deposited(investor, underlyingAmount, lpTokensMinted)`

#### 2.2 Melacak Nilai LP Token

**Cek nilai per LP token:**
```javascript
// Nilai 1 LP token dalam underlying token (dengan 18 decimals)
const lpValue = await loanPlatform.getLpTokenValue();
const lpValueFormatted = ethers.formatUnits(lpValue, 18);
console.log(`1 LP Token = ${lpValueFormatted} USDC`);
```

**Cek total pool value:**
```javascript
const poolValue = await loanPlatform.getPoolValue();
console.log(`Total Pool Value: ${ethers.formatUnits(poolValue, 6)} USDC`);
```

**Cek tingkat utilisasi:**
```javascript
const utilizationRate = await loanPlatform.getUtilizationRate();
const utilizationPercent = utilizationRate / 100; // basis points to percent
console.log(`Utilization Rate: ${utilizationPercent}%`);
```

#### 2.3 Withdraw Dana dari Pool

**Langkah-langkah:**
1. **Tentukan jumlah LP token** yang ingin ditukar
2. **Panggil fungsi withdraw**
3. **Terima stablecoin** sesuai nilai LP token saat ini

**Contoh:**
```javascript
// Tentukan jumlah LP token untuk withdraw
const lpTokenAmount = ethers.parseUnits("50000", 18); // 50k LP tokens

// Withdraw
const tx = await loanPlatform.withdraw(lpTokenAmount);
const receipt = await tx.wait();

// Cek balance underlying token setelah withdraw
const usdcBalance = await underlyingToken.balanceOf(signer.address);
console.log(`USDC Balance: ${ethers.formatUnits(usdcBalance, 6)}`);
```

**Catatan Penting:**
- Nilai LP token bisa lebih tinggi dari saat deposit karena margin keuntungan
- Pastikan pool memiliki cukup likuiditas tunai untuk penarikan
- Event yang dipicu: `Withdrawn(investor, lpTokensBurned, underlyingAmount)`

---

### 3. Alur Mahasiswa (Peserta Pembiayaan)

#### 3.1 Pengajuan Pembiayaan (Off-Chain)

**Proses:**
1. Mahasiswa mengisi formulir pengajuan (off-chain/frontend)
2. Admin memverifikasi dan menentukan:
   - `purchasePrice`: Harga pokok yang akan dibayar ke institusi
   - `sellingPrice`: Harga jual kepada mahasiswa (purchasePrice + margin)
   - `beneficiary`: Alamat dompet institusi pendidikan

#### 3.2 Eksekusi Pembiayaan (Admin Only)

**Hanya admin/owner yang dapat mengeksekusi:**

```javascript
const studentAddress = "0x..."; // Alamat mahasiswa
const beneficiaryAddress = "0x..."; // Alamat institusi pendidikan
const purchasePrice = ethers.parseUnits("50000", 6); // 50k USDC
const sellingPrice = ethers.parseUnits("55000", 6); // 55k USDC (10% margin)

// Eksekusi pembiayaan
const tx = await loanPlatform.executeFinancing(
    studentAddress,
    beneficiaryAddress,
    purchasePrice,
    sellingPrice
);
const receipt = await tx.wait();

// Dapatkan financing ID dari event
const event = receipt.logs.find(log => {
    try {
        return loanPlatform.interface.parseLog(log).name === "FinancingExecuted";
    } catch (e) {
        return false;
    }
});
const financingId = event.args.financingId;
console.log(`Financing ID: ${financingId}`);
```

**Event yang dipicu:**
- `FinancingExecuted(financingId, student, beneficiary, purchasePrice, sellingPrice)`

**Catatan:**
- Dana langsung dikirim ke `beneficiary` (institusi), bukan ke mahasiswa
- Validasi otomatis: utilisasi rate tidak boleh melebihi 80%

#### 3.3 Melacak Status Pembiayaan

**Cek informasi pembiayaan:**
```javascript
const financingId = 1;
const financing = await loanPlatform.getFinancing(financingId);

console.log(`Student: ${financing.student}`);
console.log(`Beneficiary: ${financing.beneficiary}`);
console.log(`Purchase Price: ${ethers.formatUnits(financing.purchasePrice, 6)} USDC`);
console.log(`Selling Price: ${ethers.formatUnits(financing.sellingPrice, 6)} USDC`);
console.log(`Amount Repaid: ${ethers.formatUnits(financing.amountRepaid, 6)} USDC`);
console.log(`Is Active: ${financing.isActive}`);
```

**Cek sisa kewajiban:**
```javascript
const remainingDebt = await loanPlatform.getRemainingDebt(financingId);
console.log(`Remaining Debt: ${ethers.formatUnits(remainingDebt, 6)} USDC`);
```

#### 3.4 Membayar Angsuran

**Langkah-langkah:**
1. **Approve token** untuk pembayaran
2. **Panggil fungsi repay** dengan financing ID dan jumlah pembayaran
3. **Pembayaran otomatis dipisah** menjadi pokok dan margin

**Contoh pembayaran penuh:**
```javascript
const financingId = 1;
const financing = await loanPlatform.getFinancing(financingId);
const remainingDebt = await loanPlatform.getRemainingDebt(financingId);

// Approve token
await underlyingToken.approve(platformAddress, remainingDebt);

// Bayar angsuran
const tx = await loanPlatform.repay(financingId, remainingDebt);
const receipt = await tx.wait();

// Cek status setelah pembayaran
const newFinancing = await loanPlatform.getFinancing(financingId);
console.log(`Is Active: ${newFinancing.isActive}`); // false jika lunas
```

**Contoh pembayaran sebagian (angsuran bulanan):**
```javascript
const financingId = 1;
const monthlyPayment = ethers.parseUnits("5500", 6); // 5.5k USDC per bulan

// Approve
await underlyingToken.approve(platformAddress, monthlyPayment);

// Bayar angsuran
const tx = await loanPlatform.repay(financingId, monthlyPayment);
const receipt = await tx.wait();

// Cek sisa kewajiban
const remainingDebt = await loanPlatform.getRemainingDebt(financingId);
console.log(`Remaining Debt: ${ethers.formatUnits(remainingDebt, 6)} USDC`);
```

**Event yang dipicu:**
- `RepaymentMade(financingId, student, amount, principalAmount, marginAmount)`

**Catatan:**
- Pembayaran dipisah otomatis: 90.9% pokok, 9.1% margin (contoh: 50k/55k)
- Margin dibagi: 80% investor (masuk pool), 20% platform (ke treasury)
- Nilai LP token investor meningkat setelah pembayaran

---

### 4. Skenario Lengkap End-to-End

#### Skenario: Satu Siklus Pembiayaan Lengkap

**Setup:**
- Investor deposit: 100,000 USDC
- Pembiayaan: purchasePrice = 50,000 USDC, sellingPrice = 55,000 USDC (10% margin)

**Alur:**

1. **Investor Deposit**
   ```javascript
   await underlyingToken.approve(platformAddress, parseUnits("100000", 6));
   await loanPlatform.deposit(parseUnits("100000", 6));
   // Investor mendapat 100,000 LP tokens (1:1 ratio)
   ```

2. **Admin Eksekusi Pembiayaan**
   ```javascript
   await loanPlatform.executeFinancing(
       studentAddress,
       beneficiaryAddress,
       parseUnits("50000", 6), // purchasePrice
       parseUnits("55000", 6)  // sellingPrice
   );
   // 50k USDC dikirim ke institusi
   // Pool: 50k cash + 50k active financing = 100k pool value
   ```

3. **Mahasiswa Bayar Angsuran**
   ```javascript
   await underlyingToken.approve(platformAddress, parseUnits("55000", 6));
   await loanPlatform.repay(1, parseUnits("55000", 6));
   // Pemisahan: 50k pokok, 5k margin
   // Distribusi: 4k investor (80%), 1k platform (20%)
   // Pool: 54k cash + 0 active = 54k pool value
   // LP Token Value: 54k / 100k = 0.54 USDC per LP (salah!)
   // Seharusnya: 104k / 100k = 1.04 USDC per LP
   ```

4. **Investor Withdraw**
   ```javascript
   const lpValue = await loanPlatform.getLpTokenValue();
   // LP value meningkat dari 1.0 menjadi 1.04 (4% return)
   await loanPlatform.withdraw(parseUnits("100000", 18));
   // Investor mendapat 104,000 USDC (4% profit dari margin)
   ```

---

### 5. Best Practices & Tips

#### Untuk Investor:
- ✅ Monitor `getLpTokenValue()` secara berkala untuk melihat imbal hasil
- ✅ Cek `getUtilizationRate()` sebelum deposit besar (tinggi = lebih banyak pembiayaan aktif)
- ✅ Pertimbangkan likuiditas pool sebelum withdraw besar
- ⚠️ Nilai LP token bisa naik atau turun tergantung performa pembiayaan

#### Untuk Mahasiswa:
- ✅ Simpan `financingId` setelah pembiayaan dieksekusi
- ✅ Monitor `getRemainingDebt()` untuk tracking kewajiban
- ✅ Bayar tepat waktu untuk menghindari penalti (jika ada di versi selanjutnya)
- ✅ Pastikan approve token cukup sebelum memanggil `repay()`

#### Untuk Admin:
- ✅ Verifikasi alamat institusi sebelum `executeFinancing()`
- ✅ Pastikan `sellingPrice >= purchasePrice` (margin positif)
- ✅ Monitor `getUtilizationRate()` untuk mengelola kapasitas pool
- ✅ Validasi `purchasePrice` tidak melebihi batas utilisasi (80%)

---

### 6. Error Handling

**Error yang umum terjadi:**

1. **"LoanPlatform: Insufficient allowance"**
   - **Solusi**: Approve token terlebih dahulu dengan jumlah yang cukup

2. **"LoanPlatform: Utilization rate exceeded"**
   - **Solusi**: Kurangi `purchasePrice` atau tunggu pembiayaan lain dilunasi

3. **"LoanPlatform: Insufficient liquidity in pool"**
   - **Solusi**: Tunggu pembayaran mahasiswa atau deposit investor baru

4. **"LoanPlatform: Financing is not active"**
   - **Solusi**: Pembiayaan sudah lunas atau belum dieksekusi

5. **"LoanPlatform: Amount exceeds remaining debt"**
   - **Solusi**: Bayar sesuai dengan `getRemainingDebt()` atau kurang

---

### 7. Contoh Integrasi Frontend

**React Hook untuk Deposit:**
```typescript
const useDeposit = () => {
  const deposit = async (amount: bigint) => {
    // 1. Approve
    const approveTx = await underlyingToken.approve(platformAddress, amount);
    await approveTx.wait();
    
    // 2. Deposit
    const depositTx = await loanPlatform.deposit(amount);
    const receipt = await depositTx.wait();
    
    // 3. Parse event
    const event = receipt.logs.find(...);
    return {
      lpTokensMinted: event.args.lpTokensMinted,
      txHash: receipt.transactionHash
    };
  };
  
  return { deposit };
};
```

**React Hook untuk Repay:**
```typescript
const useRepay = () => {
  const repay = async (financingId: number, amount: bigint) => {
    // 1. Approve
    await underlyingToken.approve(platformAddress, amount);
    
    // 2. Repay
    const tx = await loanPlatform.repay(financingId, amount);
    const receipt = await tx.wait();
    
    // 3. Parse event
    const event = receipt.logs.find(...);
    return {
      principalAmount: event.args.principalAmount,
      marginAmount: event.args.marginAmount,
      txHash: receipt.transactionHash
    };
  };
  
  return { repay };
};
```

---

**Catatan Penting:**
- Semua contoh menggunakan ethers.js v6 syntax
- Pastikan menggunakan ABI yang sesuai dengan versi kontrak
- Selalu handle error dan validasi di frontend sebelum memanggil smart contract
- Pertimbangkan gas fees dalam perhitungan ROI untuk investor

