### Linimasa Proyek & Alokasi Peran

*   **Linimasa:** 15 November 2025 - 26 November 2025 (12 hari)
*   **Tim:**
    *   **1 Pengembang Backend & Smart Contract (SC/BE):** Bertanggung jawab atas smart contract, API NestJS, dan database.
    *   **1 Desainer UI/UX:** Bertanggung jawab atas semua pekerjaan desain di Figma.
    *   **1 Pengembang Frontend (FE):** Bertanggung jawab untuk mengimplementasikan UI dan menghubungkannya dengan API backend.

---

## Arsitektur MVP: Model Liquidity Pool Disederhanakan

Untuk mencapai target dalam 12 hari, MVP ini akan mengimplementasikan versi sederhana dari model Liquidity Pool. Fokusnya adalah memvalidasi alur inti sambil menjaga keamanan dasar.

-   **Dalam Cakupan (In-Scope):**
    -   **Satu Liquidity Pool:** Investor menyetor dana ke dalam satu pool utama.
    -   **Token LP (eduLP):** Investor menerima token ERC20 (`eduLP`) sebagai bukti kepemilikan saham di dalam pool.
    -   **Pinjaman dari Pool:** Pinjaman yang disetujui oleh admin akan menarik dana dari pool umum.
    -   **Kontrol Tingkat Utilisasi:** Smart contract akan memberlakukan batas maksimal dana yang dapat dipinjamkan (misalnya, 80% dari total pool) untuk menjaga likuiditas.
-   **Di Luar Cakupan (Out-of-Scope untuk MVP ini):**
    -   **Yield Farming Aset Idle:** Dana yang tidak terpakai di pool tidak akan diinvestasikan ke protokol DeFi lain.
    -   **Reserve Fund Otomatis:** Mekanisme dana cadangan untuk menutupi gagal bayar akan ditunda ke versi berikutnya.
    -   **Periode Kunci (Lock Period) Kompleks:** Untuk MVP, penarikan dana oleh investor tidak akan dibatasi oleh periode kunci.

---

## File yang Relevan

-   **Smart Contracts (Foundry):**
    -   `contracts/src/LoanPlatform.sol` - Kontrak utama yang mengelola pool, pinjaman, dan tingkat utilisasi.
    -   `contracts/src/EduLPToken.sol` - Kontrak untuk token LP (ERC20).
    -   `contracts/script/Deploy.s.sol`
    -   `contracts/test/LoanPlatform.t.sol`
-   **Backend (NestJS):**
    -   `backend/src/blockchain/blockchain.service.ts` - Layanan untuk berinteraksi dengan kontrak dan melacak metrik pool.
    -   `backend/src/pools/pools.module.ts` - Modul baru untuk menyediakan data pool (total likuiditas, APY, utilisasi) ke frontend.
-   **Frontend (React):**
    -   `frontend/src/wagmi.ts` - Konfigurasi untuk Wagmi, Viem, dan RainbowKit.
    -   `frontend/src/components/Dashboard/PoolStats.tsx` - Komponen untuk menampilkan statistik pool.

---

## Rincian Tugas & Linimasa

### Fase 1: Pengaturan, Desain & Arsitektur (15 Nov - 17 Nov)

-   [ ] **1.0 Pengaturan Proyek**
    -   [ ] 1.1 **(SC/BE)** Inisialisasi proyek Foundry, NestJS, dan konfigurasikan PostgreSQL.
    -   [ ] 1.2 **(FE)** Inisialisasi proyek React + Vite + TypeScript dan instal semua dependensi.
-   [ ] **2.0 Desain UI/UX**
    -   [ ] 2.1 **(UI/UX)** Buat wireframe di Figma, termasuk tampilan untuk statistik pool (Total Likuiditas, Utilisasi, APY Sederhana).
-   [ ] **3.0 Fondasi Smart Contract & Backend**
    -   [ ] 3.1 **(SC/BE)** Buat kontrak `EduLPToken.sol` (ERC20 standar).
    -   [ ] 3.2 **(SC/BE)** Implementasikan kerangka dasar `LoanPlatform.sol` yang akan berinteraksi dengan token LP.
    -   [ ] 3.3 **(SC/BE)** Tentukan skema database yang diperbarui (menghapus `Investments`, menambah `Deposits`).

### Fase 2: Logika Inti & Finalisasi Desain (18 Nov - 20 Nov)

-   [ ] **3.0 Pengembangan Smart Contract & Backend**
    -   [ ] 3.4 **(SC/BE)** Implementasikan fungsi `deposit()` (mint `eduLP`) dan `withdraw()` (burn `eduLP`) di `LoanPlatform.sol`.
    -   [ ] 3.5 **(SC/BE)** Implementasikan fungsi `approveLoan()` dengan **pengecekan tingkat utilisasi**.
    -   [ ] 3.6 **(SC/BE)** Tulis unit test yang komprehensif untuk semua logika pool dan pinjaman.
    -   [ ] 3.7 **(SC/BE)** Implementasikan endpoint API di NestJS untuk data pool dasar.
-   [ ] **2.0 Desain UI/UX**
    -   [ ] 2.2 **(UI/UX)** Finalisasi desain high-fidelity di Figma.
-   [ ] **4.0 Kerangka Frontend**
    -   [ ] 4.1 **(FE)** Konfigurasikan Wagmi & RainbowKit.
    -   [ ] 4.2 **(FE)** Bangun komponen UI statis dengan TailwindCSS.

### Fase 3: Integrasi & Implementasi Fitur (21 Nov - 23 Nov)

-   [ ] **3.0 Deployment Smart Contract & Integrasi Backend**
    -   [ ] 3.8 **(SC/BE)** Deploy semua kontrak ke testnet Sepolia.
    -   [ ] 3.9 **(SC/BE)** Implementasikan `BlockchainService` untuk sinkronisasi event (Deposit, Withdraw, LoanCreated).
-   [ ] **4.0 Integrasi Frontend**
    -   [ ] 4.3 **(FE)** Hubungkan fungsi `deposit` dan `withdraw` menggunakan hook Wagmi.
    -   [ ] 4.4 **(FE)** Tampilkan statistik pool (Total Likuiditas, Utilisasi, dll.) dari API backend menggunakan TanStack React Query.
    -   [ ] 4.5 **(FE)** Implementasikan dasbor mahasiswa dan admin (hanya untuk approve loan).
-   [ ] **2.0 Tinjauan UI/UX**
    -   [ ] 2.3 **(UI/UX)** Tinjau implementasi frontend.

### Fase 4: Pengujian, Perbaikan Bug & Deployment (24 Nov - 26 Nov)

-   [ ] **5.0 Pengujian Full-Stack**
    -   [ ] 5.1 **(SEMUA TIM)** Lakukan pengujian end-to-end pada alur utama: Investor Deposit -> Admin Approve Loan -> Mahasiswa Repay -> Investor Withdraw.
    -   [ ] 5.2 **(SC/BE & FE)** Perbaiki bug yang ditemukan.
-   [ ] **6.0 Deployment Final**
    -   [ ] 6.1 **(SC/BE)** Deploy backend NestJS.
    -   [ ] 6.2 **(FE)** Deploy frontend React.
-   [ ] **7.0 Tinjauan Akhir**
    -   [ ] 7.1 **(SEMUA TIM)** Lakukan tinjauan akhir dan persetujuan.

