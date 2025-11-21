# Skema Database & Kontrak (Model Liquidity Pool MVP)

Berikut adalah rincian arsitektur teknis untuk database PostgreSQL dan smart contract berdasarkan model Liquidity Pool yang disederhanakan.

---

## 1. Skema Database (ERD) untuk PostgreSQL

Database ini dirancang untuk mendukung backend NestJS. Tujuannya adalah untuk menyimpan data yang sulit atau mahal untuk dikueri langsung dari blockchain, serta untuk mengelola data off-chain seperti profil pengguna.

### Tabel: `Users` (`Pengguna`)
Menyimpan informasi dasar untuk semua pengguna, baik mahasiswa maupun investor.

| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `UUID` | Primary Key |
| `walletAddress` | `VARCHAR(42)` | Alamat dompet Ethereum, unik. |
| `role` | `ENUM('student', 'investor')` | Peran pengguna di platform. |
| `createdAt` | `TIMESTAMPZ` | Waktu pendaftaran. |
| `updatedAt` | `TIMESTAMPZ` | Waktu pembaruan terakhir. |

### Tabel: `Loans` (`Pinjaman`)
Menyimpan data pengajuan pinjaman yang dibuat oleh mahasiswa.

| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `UUID` | Primary Key |
| `studentId` | `UUID` | Foreign Key ke `Users.id`. |
| `amount` | `DECIMAL` | Jumlah pinjaman yang diajukan. |
| `purpose` | `TEXT` | Deskripsi tujuan pinjaman. |
| `status` | `ENUM('pending', 'approved', 'active', 'repaid', 'default')` | Status pinjaman saat ini. |
| `createdAt` | `TIMESTAMPZ` | Waktu pengajuan. |
| `updatedAt` | `TIMESTAMPZ` | Waktu pembaruan terakhir. |

### Tabel: `Deposits` (`Setoran`)
Mencatat riwayat setiap setoran yang dilakukan investor ke dalam Liquidity Pool. Data ini diisi oleh backend setelah mendengarkan event dari smart contract.

| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `UUID` | Primary Key |
| `investorId` | `UUID` | Foreign Key ke `Users.id`. |
| `amount` | `DECIMAL` | Jumlah stablecoin yang disetor. |
| `lpTokensReceived`| `DECIMAL` | Jumlah token `eduLP` yang diterima. |
| `txHash` | `VARCHAR(66)` | Hash transaksi on-chain. |
| `createdAt` | `TIMESTAMPZ` | Waktu setoran. |

### Tabel: `Withdrawals` (`Penarikan`)
Mencatat riwayat setiap penarikan yang dilakukan investor dari Liquidity Pool.

| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `UUID` | Primary Key |
| `investorId` | `UUID` | Foreign Key ke `Users.id`. |
| `amountWithdrawn`| `DECIMAL` | Jumlah stablecoin yang ditarik. |
| `lpTokensBurned` | `DECIMAL` | Jumlah token `eduLP` yang dibakar. |
| `txHash` | `VARCHAR(66)` | Hash transaksi on-chain. |
| `createdAt` | `TIMESTAMPZ` | Waktu penarikan. |

---

## 2. Fungsi Utama Smart Contract (`LoanPlatform.sol`)

Berikut adalah fungsi-fungsi inti yang akan ada di dalam smart contract untuk mengelola logika Liquidity Pool.

- **`deposit(uint256 _amount)`**
  - **Tujuan:** Investor menyetor stablecoin ke pool.
  - **Logika:** Menerima `_amount` stablecoin, menghitung jumlah `eduLP` yang setara untuk dicetak (mint), lalu mentransfer `eduLP` tersebut ke `msg.sender`.
  - **Emit Event:** `Deposited(address investor, uint256 amount, uint256 lpTokens)`

- **`withdraw(uint256 _lpTokenAmount)`**
  - **Tujuan:** Investor menukarkan `eduLP` miliknya kembali menjadi stablecoin.
  - **Logika:** Membakar (burn) `_lpTokenAmount` `eduLP` dari `msg.sender`, menghitung jumlah stablecoin yang setara untuk dikembalikan (termasuk imbal hasil), lalu mentransfer stablecoin tersebut.
  - **Emit Event:** `Withdrawn(address investor, uint256 lpTokens, uint256 withdrawnAmount)`

- **`approveLoan(uint256 _loanId, address _studentAddress, uint256 _loanAmount)`**
  - **Tujuan:** Fungsi khusus admin untuk menyetujui dan mencairkan pinjaman.
  - **Logika:**
    1.  Memeriksa apakah `msg.sender` adalah admin.
    2.  **Memeriksa Tingkat Utilisasi:** Memastikan `(total dana dipinjam + _loanAmount) / total aset di pool <= maxUtilizationRate`. Jika tidak, batalkan transaksi.
    3.  Mentransfer `_loanAmount` stablecoin dari kontrak ke `_studentAddress`.
    4.  Mencatat pinjaman baru secara on-chain.
  - **Emit Event:** `LoanApproved(uint256 loanId, address student, uint256 amount)`

- **`repay(uint256 _loanId, uint256 _amount)`**
  - **Tujuan:** Mahasiswa membayar cicilan pinjaman.
  - **Logika:** Menerima `_amount` stablecoin dari mahasiswa dan menambahkannya kembali ke total aset di dalam pool.
  - **Emit Event:** `LoanRepaid(uint256 loanId, address student, uint256 amount)`




