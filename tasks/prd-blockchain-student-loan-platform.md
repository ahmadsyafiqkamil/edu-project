# Dokumen Kebutuhan Produk (PRD): Platform Pinjaman Mahasiswa Blockchain (MVP)

## 1. Pendahuluan/Gambaran Umum

Dokumen ini menguraikan persyaratan untuk Produk Minimum yang Layak (MVP) dari Platform Pinjaman Mahasiswa yang terdesentralisasi. Platform ini bertujuan untuk menyelesaikan tantangan aksesibilitas pinjaman mahasiswa dengan menghubungkan secara langsung mahasiswa yang mencari dana pendidikan dengan investor yang mencari peluang dengan dampak sosial. Dengan memanfaatkan teknologi blockchain, kami bertujuan untuk menciptakan ekosistem yang transparan, efisien, dan aman untuk originasi, pendanaan, dan pembayaran kembali pinjaman.

Tujuan utama dari MVP 3 minggu ini adalah untuk membangun dan memvalidasi perjalanan pengguna yang lengkap dari awal hingga akhir: dari seorang mahasiswa mengajukan pinjaman, investor mendanainya, mahasiswa menerima dana, hingga proses pembayaran kembali dimulai.

## 2. Tujuan

*   **G-1:** Membuat platform fungsional di mana mahasiswa dapat mendaftar dan mengajukan aplikasi pinjaman.
*   **G-2:** Memungkinkan investor untuk mendaftar, menyetor modal, dan melihat aplikasi pinjaman yang tersedia untuk didanai.
*   **G--3:** Berhasil memfasilitasi pencairan dana dari pool investor ke dompet mahasiswa setelah acara pendanaan berhasil.
*   **G-4:** Menerapkan mekanisme bagi mahasiswa untuk melakukan pembayaran kembali yang dilacak di blockchain.
*   **G-5:** Memvalidasi arsitektur teknis inti menggunakan smart contract untuk semua operasi keuangan penting.

## 3. User Stories

### Sebagai Mahasiswa...
*   **US-1:** Saya ingin membuat akun dan membangun profil sederhana agar saya dapat mengajukan pinjaman.
*   **US-2:** Saya ingin mengisi formulir aplikasi pinjaman yang jelas dan lugas, dengan menyebutkan jumlah yang saya butuhkan dan tujuan pinjaman.
*   **US-3:** Saya ingin dapat melihat status aplikasi pinjaman saya (misalnya, tertunda, didanai, aktif, dilunasi) di dasbor pribadi.
*   **US-4:** Saya ingin menerima jumlah pinjaman secara aman langsung ke dompet mata uang kripto saya yang terhubung setelah aplikasi saya didanai.
*   **US-5:** Saya ingin melihat jadwal pembayaran saya dan dapat melakukan pembayaran kembali bulanan/berkala melalui platform.

### Sebagai Investor...
*   **US-6:** Saya ingin membuat akun untuk berpartisipasi sebagai pemberi pinjaman di platform.
*   **US-7:** Saya ingin dapat menyetor modal (misalnya, stablecoin seperti USDC) ke dalam brankas platform atau smart contract yang aman.
*   **US-8:** Saya ingin menelusuri daftar aplikasi pinjaman mahasiswa, dengan detail dasar tentang permintaan mahasiswa, sehingga saya dapat memilih mana yang akan didanai.
*   **US-9:** Saya ingin mengikat sejumlah modal yang saya setorkan ke satu atau lebih pinjaman mahasiswa.
*   **US-10:** Saya ingin dasbor sederhana untuk melacak investasi saya, melihat pinjaman mana yang telah saya danai, dan melihat status pembayaran kembali.

## 4. Persyaratan Fungsional

### FR-1: Manajemen Pengguna (Bersama)
*   **FR-1.1:** Sistem harus memungkinkan pengguna untuk menghubungkan dompet mata uang kripto mereka (misalnya, MetaMask) untuk mendaftar.
*   **FR-1.2:** Pengguna harus memilih peran saat pendaftaran: "Mahasiswa" atau "Investor".
*   **FR-1.3:** Sistem harus menyediakan fungsionalitas login/logout dasar yang terikat dengan alamat dompet pengguna.

### FR-2: Fungsionalitas Khusus Mahasiswa
*   **FR-2.1:** Sistem harus menyediakan formulir bagi mahasiswa untuk mengajukan aplikasi pinjaman. Formulir akan mencakup:
    *   Jumlah Pinjaman yang Diminta (dalam stablecoin yang ditentukan, misalnya, USDC).
    *   Tujuan Pinjaman (misalnya, biaya kuliah, biaya hidup).
    *   Informasi Universitas/Program Studi.
    *   Periode Pembayaran Kembali yang Diminta.
*   **FR-2.2:** Mahasiswa harus memiliki dasbor pribadi untuk melihat status aplikasi pinjaman aktif mereka.

### FR-3: Fungsionalitas Khusus Investor
*   **FR-3.1:** Sistem harus menyediakan antarmuka bagi investor untuk menyetor stablecoin (misalnya, USDC) ke dalam smart contract platform.
*   **FR-3.2:** Sistem harus menampilkan daftar semua aplikasi pinjaman mahasiswa yang tertunda untuk ditinjau oleh investor.
*   **FR-3.3:** Investor harus dapat mengalokasikan dana dari saldo yang mereka setorkan ke aplikasi pinjaman tertentu.
*   **FR-3.4:** Investor harus memiliki dasbor pribadi yang menunjukkan:
    *   Total modal yang disetor.
    *   Modal yang dialokasikan untuk pinjaman.
    *   Daftar pinjaman yang telah mereka danai.

### FR-4: Logika Inti Pinjaman & Pembayaran Kembali (Smart Contract)
*   **FR-4.1:** Sistem harus secara otomatis mencairkan jumlah pinjaman penuh ke dompet mahasiswa setelah aplikasi mereka 100% didanai.
*   **FR-4.2:** Sistem harus menyediakan fungsi bagi mahasiswa untuk melakukan pembayaran kembali. Fungsi ini akan mentransfer dana dari dompet mahasiswa kembali ke kontrak platform.

## 5. Non-Goals (Di Luar Cakupan untuk MVP)

*   **Tidak ada penilaian kredit yang kompleks:** MVP tidak akan menyertakan model penilaian kredit atau penilaian risiko otomatis untuk mahasiswa. Keputusan pendanaan ada di tangan investor.
*   **Tidak ada pasar sekunder:** Investor tidak dapat memperdagangkan atau menjual posisi pinjaman mereka kepada investor lain.
*   **Hanya satu mata uang:** Platform akan beroperasi dengan satu stablecoin (misalnya, USDC). Tidak ada dukungan untuk beberapa mata uang fiat atau kripto.
*   **Tidak ada analitik lanjutan:** Dasbor akan sederhana dan tidak akan menyediakan perhitungan ROI yang kompleks, analisis portofolio, atau tren pasar.
*   **Hanya web:** Tidak ada aplikasi seluler asli (iOS/Android) yang akan dikembangkan untuk MVP.

## 6. Pertimbangan Desain (Opsional)

*   Antarmuka pengguna harus bersih, sederhana, dan intuitif.
*   Fokus utama adalah pada fungsionalitas dan kegunaan, bukan pada desain yang rumit.
*   Ini harus dengan jelas membedakan alur pengguna untuk Mahasiswa vs. Investor.

## 7. Pertimbangan Teknis (Opsional)

*   Logika inti (pool pendanaan, kontrak pinjaman, pencairan, pembayaran kembali) harus dibangun menggunakan smart contract Solidity di blockchain yang kompatibel dengan EVM.
*   Frontend akan menjadi aplikasi web yang berinteraksi dengan smart contract (misalnya, menggunakan ethers.js atau web3.js).
*   Otentikasi pengguna akan ditangani melalui koneksi dompet (misalnya, MetaMask).

## 8. Metrik Keberhasilan

*   Metrik keberhasilan utama untuk MVP adalah penyelesaian yang berhasil dan bebas dari kesalahan dari setidaknya **satu** siklus pinjaman dari awal hingga akhir:
    1.  Seorang mahasiswa berhasil mengajukan pinjaman.
    2.  Seorang investor berhasil menyetor dana.
    3.  Investor mengalokasikan dana untuk pinjaman mahasiswa.
    4.  Pinjaman didanai sepenuhnya.
    5.  Dana berhasil dicairkan ke dompet mahasiswa.

## 9. Pertanyaan Terbuka

*   Jaringan blockchain spesifik mana yang akan kita gunakan untuk men-deploy MVP (misalnya, testnet Ethereum seperti Sepolia, atau solusi Layer-2 seperti Polygon/Arbitrum untuk biaya gas yang lebih rendah)?
*   Stablecoin mana yang akan digunakan untuk semua transaksi (misalnya, USDC, DAI)?


