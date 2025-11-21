# Dokumen Kebutuhan Produk (PRD): Platform Pembiayaan Pendidikan Syariah (MVP)

## 1. Pendahuluan/Gambaran Umum

Dokumen ini menguraikan persyaratan untuk Produk Minimum yang Layak (MVP) dari Platform Pembiayaan Pendidikan Syariah. Platform ini bertujuan untuk menyediakan akses pembiayaan yang sesuai dengan prinsip syariah bagi mahasiswa dengan menghubungkan mereka secara langsung dengan penyedia dana (investor) melalui model *liquidity pool*.

Dengan memanfaatkan teknologi blockchain, kami bertujuan untuk menciptakan ekosistem yang transparan, efisien, dan aman untuk pembiayaan pendidikan berdasarkan **akad *Murabahah*** (jual beli dengan margin keuntungan), di mana platform membeli jasa pendidikan untuk mahasiswa dan menjualnya kembali dengan harga angsuran yang disepakati di awal, **tanpa unsur bunga (*riba*)**.

Tujuan utama MVP ini adalah memvalidasi alur lengkap: dari investor menyetor dana, mahasiswa mengajukan pembiayaan, dana dicairkan ke institusi pendidikan, hingga mahasiswa membayar angsuran kembali ke pool.

## 2. Tujuan

*   **G-1:** Membuat platform fungsional di mana mahasiswa dapat mengajukan pembiayaan pendidikan untuk tujuan yang spesifik.
*   **G-2:** Memungkinkan investor (penyedia dana) untuk menyetor modal ke dalam *liquidity pool* syariah dan mendapatkan imbal hasil dari margin keuntungan.
*   **G-3:** Berhasil memfasilitasi pencairan dana pembiayaan **langsung ke institusi pendidikan** yang dituju.
*   **G-4:** Menerapkan mekanisme bagi mahasiswa untuk membayar angsuran yang dilacak secara transparan di blockchain.
*   **G-5:** Memvalidasi arsitektur teknis inti menggunakan smart contract untuk semua transaksi keuangan sesuai prinsip syariah.

## 3. User Stories

### Sebagai Mahasiswa (Peserta Pembiayaan)...
*   **US-1:** Saya ingin membuat akun agar dapat mengajukan pembiayaan untuk biaya pendidikan saya.
*   **US-2:** Saya ingin mengisi formulir pengajuan pembiayaan yang jelas, menyebutkan jasa pendidikan yang dibutuhkan (misal: SPP), harganya, dan detail institusi pendidikan.
*   **US-3:** Saya ingin melihat status pengajuan saya (misal: menunggu persetujuan, disetujui, lunas) di dasbor pribadi.
*   **US-4:** Saya ingin platform membayarkan biaya pendidikan saya langsung ke universitas setelah pembiayaan disetujui.
*   **US-5:** Saya ingin melihat jadwal angsuran saya yang **tetap dan tidak berubah**, dan dapat membayar angsuran bulanan melalui platform.

### Sebagai Investor (Penyedia Dana)...
*   **US-6:** Saya ingin membuat akun untuk berpartisipasi sebagai penyedia dana di dalam *liquidity pool* yang sesuai syariah.
*   **US-7:** Saya ingin dapat menyetor modal (stablecoin) ke dalam *liquidity pool* dan menerima token LP (`eduLP`) sebagai bukti kepemilikan.
*   **US-8:** Saya ingin keuntungan saya berasal dari bagi hasil atas margin keuntungan transaksi jual-beli, bukan dari bunga.
*   **US-9:** Saya ingin dasbor sederhana untuk melacak total modal saya, nilai token LP saya, dan estimasi imbal hasil yang didapatkan.

## 4. Persyaratan Fungsional

### FR-1: Manajemen Pengguna
*   **FR-1.1:** Sistem harus memungkinkan pengguna mendaftar menggunakan dompet kripto mereka.
*   **FR-1.2:** Pengguna harus memilih peran: "Mahasiswa" atau "Investor".

### FR-2: Alur Pembiayaan Mahasiswa (Akad Murabahah)
*   **FR-2.1:** Sistem harus menyediakan formulir pengajuan pembiayaan yang mengharuskan mahasiswa mengisi:
    *   **Harga Pokok Jasa:** Jumlah biaya pendidikan yang harus dibayar.
    *   **Tujuan Pembiayaan:** Detail (misal: SPP Semester Ganjil 2025/2026).
    *   **Alamat Dompet Penerima:** Alamat dompet kripto milik institusi pendidikan (wajib).
*   **FR-2.2:** Sistem (melalui admin) akan menentukan **Harga Jual** (Harga Pokok + Margin Keuntungan) dan menawarkannya kepada mahasiswa.
*   **FR-2.3:** Setelah mahasiswa menyetujui, sistem akan mencairkan dana sebesar **Harga Pokok** langsung ke alamat dompet institusi.
*   **FR-2.4:** Sistem harus menyediakan antarmuka bagi mahasiswa untuk membayar angsuran bulanan dari total **Harga Jual**.

### FR-3: Alur Liquidity Pool Investor
*   **FR-3.1:** Sistem harus menyediakan antarmuka bagi investor untuk menyetor stablecoin ke *liquidity pool*.
*   **FR-3.2:** Atas setiap setoran, sistem (smart contract) harus mencetak (`mint`) token `eduLP` secara proporsional kepada investor.
*   **FR-3.3:** Sistem harus menyediakan antarmuka bagi investor untuk menarik dana dengan menukarkan (`burn`) token `eduLP` mereka dengan stablecoin yang setara nilainya saat itu.

### FR-4: Logika Ekonomi & Bagi Hasil (Smart Contract)
*   **FR-4.1:** Smart contract harus mampu memisahkan pembayaran angsuran dari mahasiswa menjadi porsi pengembalian pokok dan porsi margin keuntungan.
*   **FR-4.2:** Margin keuntungan yang terkumpul harus dibagi sesuai rasio yang ditentukan (misal: 80% untuk pool investor, 20% untuk kas platform).
*   **FR-4.3:** Bagian keuntungan untuk investor harus dimasukkan kembali ke *liquidity pool* untuk meningkatkan nilai token `eduLP`.
*   **FR-4.4:** Bagian keuntungan untuk platform harus ditransfer ke alamat dompet terpisah (`platformTreasury`).

## 5. Non-Goals (Di Luar Cakupan untuk MVP)

*   **Akad Selain Murabahah:** MVP ini tidak akan mendukung akad syariah lain seperti *Ijarah* (sewa), *Musyarakah*, atau *Qardhul Hasan*.
*   **Verifikasi Otomatis Institusi:** Proses verifikasi alamat dompet institusi pendidikan akan dilakukan secara manual oleh tim untuk MVP.
*   **Pasar Sekunder untuk Token LP:** Investor tidak dapat memperdagangkan token `eduLP` mereka.

## 6. Pertimbangan Desain & Terminologi

*   **Wajib:** Semua terminologi di UI/UX harus diubah untuk mencerminkan prinsip syariah.
    *   `Loan` -> `Pembiayaan` / `Financing`
    *   `Interest` -> `Margin Keuntungan` / `Profit Margin`
    *   `Borrower` -> `Mahasiswa` / `Peserta Pembiayaan`
    *   `Lender` -> `Investor` / `Penyedia Dana`
*   Alur pengajuan harus jelas menunjukkan bahwa dana akan dikirim ke institusi, bukan ke mahasiswa.

## 7. Pertimbangan Teknis

*   Smart contract `LoanPlatform.sol` harus memiliki logika untuk membedakan antara harga pokok dan harga jual dalam setiap pembiayaan.
*   Logika pencairan dana harus secara ketat mengirim dana hanya ke alamat `beneficiary` (institusi).

## 8. Metrik Keberhasilan

*   Berhasilnya minimal satu siklus pembiayaan syariah end-to-end:
    1.  Investor menyetor dana ke pool.
    2.  Mahasiswa mengajukan pembiayaan dan disetujui.
    3.  Dana sebesar **harga pokok** berhasil dicairkan ke dompet institusi.
    4.  Mahasiswa berhasil membayar minimal satu kali angsuran.
    5.  Margin keuntungan dari angsuran tersebut berhasil didistribusikan (ke pool dan ke kas platform).
    6.  Investor dapat menarik dananya dengan nilai `eduLP` yang sudah sedikit meningkat.

## 9. Pertanyaan Terbuka

*   Berapa rasio bagi hasil (Profit Sharing Ratio) awal yang akan ditetapkan antara investor dan platform? (Saran: 80/20)
*   Berapa margin keuntungan standar yang akan ditawarkan kepada mahasiswa? (perlu riset pasar)


