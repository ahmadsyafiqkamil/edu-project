// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;






// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import {EduLPToken} from "./EduLPToken.sol";

// /**
//  * @title LoanPlatform
//  * @notice Kontrak ini mengelola liquidity pool untuk pembiayaan pendidikan syariah (akad Murabahah).
//  */
// contract LoanPlatform is Ownable {

//     // =================================================================
//     //                           State Variables
//     // =================================================================

//     // --- Token ---
//     IERC20 public immutable underlyingToken; // Token stablecoin yg digunakan (misal: USDC)
//     EduLPToken public immutable eduLpToken; // Token LP kita

//     // --- Konfigurasi Platform ---
//     uint256 public maxUtilizationRate; // Contoh: 8000 (untuk 80.00%) -> 80 * 10**2
//     uint256 public platformShareRatio; // Contoh: 2000 (untuk 20.00%) -> 20 * 10**2
//     address public platformTreasury;   // Alamat dompet untuk menampung keuntungan platform

//     // --- Akuntansi Pool ---
//     uint256 public totalFinancingActive; // Total dana yg sedang dipinjamkan keluar

//     // --- Data Pembiayaan ---
//     struct Financing {
//         address student;            // Alamat mahasiswa yg dibiayai
//         address beneficiary;        // Alamat institusi (universitas) yg menerima dana
//         uint256 purchasePrice;      // Harga Pokok (yg dikirim ke universitas)
//         uint256 sellingPrice;       // Harga Jual (total kewajiban mahasiswa)
//         uint256 amountRepaid;       // Jumlah yg sudah dibayar kembali
//         bool isActive;              // Status pembiayaan
//     }
//     mapping(uint256 => Financing) public financings;
//     uint256 public nextFinancingId;

//     // =================================================================
//     //                                Events
//     // =================================================================

//     event Deposited(address indexed investor, uint256 underlyingAmount, uint256 lpTokensMinted);
//     event Withdrawn(address indexed investor, uint256 lpTokensBurned, uint256 underlyingAmount);
//     event FinancingExecuted(uint256 indexed financingId, address indexed student, address indexed beneficiary, uint256 purchasePrice, uint256 sellingPrice);
//     event RepaymentMade(uint256 indexed financingId, address indexed student, uint256 amount);

//     // =================================================================
//     //                           Constructor
//     // =================================================================

//     constructor(address _underlyingTokenAddress, address _platformTreasury) Ownable(msg.sender) {
//         underlyingToken = IERC20(_underlyingTokenAddress);
//         eduLpToken = new EduLPToken();
//         platformTreasury = _platformTreasury;
//         maxUtilizationRate = 8000; // Default 80%
//         platformShareRatio = 2000; // Default 20%
//         nextFinancingId = 1;
//     }

//     // =================================================================
//     //                       Fungsi untuk Investor
//     // =================================================================

//     /**
//      * @notice Menyetor stablecoin ke dalam pool dan mendapatkan token LP.
//      * @param _amount Jumlah stablecoin yg disetor.
//      */
//     function deposit(uint256 _amount) external {
//         // TODO: Implementasi logika
//         // 1. Validasi _amount > 0.
//         // 2. Hitung jumlah LP token yg akan di-mint berdasarkan nilai pool saat ini.
//         //    (Jika pool kosong, 1 underlying = 1 LP. Jika tidak, hitung proporsional).
//         // 3. Panggil `underlyingToken.transferFrom(msg.sender, address(this), _amount)`.
//         // 4. Panggil `eduLpToken.mint(msg.sender, lpAmountToMint)`.
//         // 5. Emit event `Deposited`.
//     }

//     /**
//      * @notice Menarik stablecoin dari pool dengan menukar (membakar) token LP.
//      * @param _lpTokenAmount Jumlah token LP yg akan ditukar.
//      */
//     function withdraw(uint256 _lpTokenAmount) external {
//         // TODO: Implementasi logika
//         // 1. Validasi _lpTokenAmount > 0 dan pengguna memiliki cukup LP.
//         // 2. Hitung jumlah stablecoin yg akan diterima berdasarkan nilai pool saat ini.
//         // 3. Pastikan pool memiliki cukup likuiditas tunai untuk penarikan.
//         // 4. Panggil `eduLpToken.burn(msg.sender, _lpTokenAmount)`.
//         // 5. Panggil `underlyingToken.transfer(msg.sender, underlyingAmountToWithdraw)`.
//         // 6. Emit event `Withdrawn`.
//     }

//     // =================================================================
//     //                 Fungsi untuk Admin & Mahasiswa
//     // =================================================================

//     /**
//      * @notice [ADMIN] Menyetujui dan mengeksekusi pembiayaan Murabahah.
//      * @param _student Alamat dompet mahasiswa.
//      * @param _beneficiary Alamat dompet institusi pendidikan.
//      * @param _purchasePrice Harga pokok yg akan dibayarkan ke institusi.
//      * @param _sellingPrice Harga jual yg akan menjadi kewajiban mahasiswa.
//      */
//     function executeFinancing(address _student, address _beneficiary, uint256 _purchasePrice, uint256 _sellingPrice) external onlyOwner {
//         // TODO: Implementasi logika
//         // 1. Validasi input. Pastikan _sellingPrice >= _purchasePrice.
//         // 2. CEK TINGKAT UTILISASI:
//         //    require((totalFinancingActive + _purchasePrice) * 10000 / getPoolValue() <= maxUtilizationRate, "Utilization rate exceeded");
//         // 3. Panggil `underlyingToken.transfer(_beneficiary, _purchasePrice)`.
//         // 4. Update `totalFinancingActive += _purchasePrice`.
//         // 5. Buat entri baru di mapping `financings`.
//         // 6. Emit event `FinancingExecuted`.
//     }

//     /**
//      * @notice [MAHASISWA] Membayar angsuran pembiayaan.
//      * @param _financingId ID pembiayaan yg akan dibayar.
//      * @param _amount Jumlah yg dibayar.
//      */
//     function repay(uint256 _financingId, uint256 _amount) external {
//         // TODO: Implementasi logika
//         // 1. Validasi bahwa pembiayaan ada, aktif, dan msg.sender adalah mahasiswa yg bersangkutan.
//         // 2. Panggil `underlyingToken.transferFrom(msg.sender, address(this), _amount)`.
//         // 3. Pisahkan pembayaran _amount menjadi pokok dan margin.
//         // 4. Bagian margin dibagi lagi sesuai `platformShareRatio`.
//         // 5. Kirim bagian platform ke `platformTreasury`. Bagian investor tetap di pool.
//         // 6. Update `financings[_financingId].amountRepaid`.
//         // 7. Update `totalFinancingActive` (dikurangi porsi pokok yg dibayar).
//         // 8. Emit event `RepaymentMade`.
//     }


//     // =================================================================
//     //                 Fungsi View & Helper (Read-Only)
//     // =================================================================

//     /**
//      * @notice Menghitung total nilai aset di dalam pool.
//      * @return Total nilai (tunai + dana yg dipinjamkan).
//      */
//     function getPoolValue() public view returns (uint256) {
//         return underlyingToken.balanceOf(address(this)) + totalFinancingActive;
//     }

//     /**
//      * @notice Menghitung nilai dari 1 token LP dalam stablecoin.
//      */
//     function getLpTokenValue() public view returns (uint256) {
//         if (eduLpToken.totalSupply() == 0) {
//             return 1e18; // Asumsi 1:1 jika supply masih 0, dengan 18 desimal
//         }
//         return (getPoolValue() * 1e18) / eduLpToken.totalSupply();
//     }
// }