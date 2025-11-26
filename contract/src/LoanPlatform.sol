// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {EduLPToken} from "./EduLPToken.sol";

/**
 * @title LoanPlatform
 * @notice Kontrak ini mengelola liquidity pool untuk pembiayaan pendidikan syariah (akad Murabahah).
 *         Menggunakan prinsip jual-beli dengan margin keuntungan, bukan bunga (riba).
 */
contract LoanPlatform is Ownable {

    // =================================================================
    //                           State Variables
    // =================================================================

    // --- Token ---
    IERC20 public immutable underlyingToken; // Token stablecoin yg digunakan (misal: USDC)
    EduLPToken public immutable eduLpToken; // Token LP kita

    // --- Konfigurasi Platform ---
    uint256 public maxUtilizationRate; // Contoh: 8000 (untuk 80.00%) -> 80 * 10**2
    uint256 public platformShareRatio; // Contoh: 2000 (untuk 20.00%) -> 20 * 10**2
    address public platformTreasury;   // Alamat dompet untuk menampung keuntungan platform

    // --- Akuntansi Pool ---
    uint256 public totalFinancingActive; // Total dana yg sedang dipinjamkan keluar

    // --- Data Pembiayaan ---
    struct Financing {
        address student;            // Alamat mahasiswa yg dibiayai
        address beneficiary;        // Alamat institusi (universitas) yg menerima dana
        uint256 purchasePrice;      // Harga Pokok (yg dikirim ke universitas)
        uint256 sellingPrice;       // Harga Jual (total kewajiban mahasiswa)
        uint256 amountRepaid;       // Jumlah yg sudah dibayar kembali
        bool isActive;              // Status pembiayaan
    }
    mapping(uint256 => Financing) public financings;
    uint256 public nextFinancingId;

    // =================================================================
    //                                Events
    // =================================================================

    event Deposited(address indexed investor, uint256 underlyingAmount, uint256 lpTokensMinted);
    event Withdrawn(address indexed investor, uint256 lpTokensBurned, uint256 underlyingAmount);
    event FinancingExecuted(uint256 indexed financingId, address indexed student, address indexed beneficiary, uint256 purchasePrice, uint256 sellingPrice);
    event RepaymentMade(uint256 indexed financingId, address indexed student, uint256 amount, uint256 principalAmount, uint256 marginAmount);

    // =================================================================
    //                           Constructor
    // =================================================================

    /**
     * @notice Membuat kontrak LoanPlatform baru
     * @param _underlyingTokenAddress Alamat token stablecoin (misal: USDC)
     * @param _platformTreasury Alamat dompet untuk keuntungan platform
     */
    constructor(address _underlyingTokenAddress, address _platformTreasury) Ownable(msg.sender) {
        require(_underlyingTokenAddress != address(0), "LoanPlatform: Invalid underlying token address");
        require(_platformTreasury != address(0), "LoanPlatform: Invalid treasury address");
        
        underlyingToken = IERC20(_underlyingTokenAddress);
        eduLpToken = new EduLPToken(address(this)); // LoanPlatform is the owner so it can set loanPlatform
        platformTreasury = _platformTreasury;
        maxUtilizationRate = 8000; // Default 80%
        platformShareRatio = 2000; // Default 20%
        nextFinancingId = 1;
        
        // Set loanPlatform address di EduLPToken agar bisa mint/burn
        eduLpToken.setLoanPlatform(address(this));
    }

    // =================================================================
    //                       Fungsi untuk Investor
    // =================================================================

    /**
     * @notice Menyetor stablecoin ke dalam pool dan mendapatkan token LP.
     *         LP token mewakili kepemilikan proporsional investor di pool.
     * @param _amount Jumlah stablecoin yg disetor.
     */
    function deposit(uint256 _amount) external {
        require(_amount > 0, "LoanPlatform: Amount must be greater than zero");
        
        uint256 totalSupply = eduLpToken.totalSupply();
        uint256 poolValue = getPoolValue();
        
        uint256 lpTokensToMint;
        
        // Jika pool kosong, 1:1 ratio (1 underlying = 1 LP token)
        if (totalSupply == 0) {
            lpTokensToMint = _amount;
        } else {
            // Hitung proporsional berdasarkan pool value
            // Formula: lpTokens = (amount * totalSupply) / poolValue
            // Ini memastikan investor mendapat proporsi yang benar dari pool
            lpTokensToMint = (_amount * totalSupply) / poolValue;
            require(lpTokensToMint > 0, "LoanPlatform: LP tokens to mint is zero");
        }
        
        // Transfer stablecoin dari investor ke kontrak
        require(
            underlyingToken.transferFrom(msg.sender, address(this), _amount),
            "LoanPlatform: Transfer failed"
        );
        
        // Mint LP tokens ke investor
        eduLpToken.mint(msg.sender, lpTokensToMint);
        
        emit Deposited(msg.sender, _amount, lpTokensToMint);
    }

    /**
     * @notice Menarik stablecoin dari pool dengan menukar (membakar) token LP.
     *         Investor mendapat imbal hasil karena nilai LP token meningkat dari margin keuntungan.
     * @param _lpTokenAmount Jumlah token LP yg akan ditukar.
     */
    function withdraw(uint256 _lpTokenAmount) external {
        require(_lpTokenAmount > 0, "LoanPlatform: LP token amount must be greater than zero");
        require(
            eduLpToken.balanceOf(msg.sender) >= _lpTokenAmount,
            "LoanPlatform: Insufficient LP token balance"
        );
        
        uint256 totalSupply = eduLpToken.totalSupply();
        require(totalSupply > 0, "LoanPlatform: No LP tokens in circulation");
        
        // Hitung underlying amount yang akan diterima
        // Formula: underlyingAmount = (lpTokenAmount * poolValue) / totalSupply
        uint256 poolValue = getPoolValue();
        uint256 underlyingAmountToWithdraw = (_lpTokenAmount * poolValue) / totalSupply;
        
        // Validasi pool memiliki cukup likuiditas tunai untuk penarikan
        uint256 availableCash = underlyingToken.balanceOf(address(this));
        require(
            availableCash >= underlyingAmountToWithdraw,
            "LoanPlatform: Insufficient liquidity in pool"
        );
        
        // Burn LP tokens dari investor
        eduLpToken.burn(msg.sender, _lpTokenAmount);
        
        // Transfer stablecoin ke investor
        require(
            underlyingToken.transfer(msg.sender, underlyingAmountToWithdraw),
            "LoanPlatform: Transfer failed"
        );
        
        emit Withdrawn(msg.sender, _lpTokenAmount, underlyingAmountToWithdraw);
    }

    // =================================================================
    //                 Fungsi untuk Admin & Mahasiswa
    // =================================================================

    /**
     * @notice [ADMIN] Menyetujui dan mengeksekusi pembiayaan Murabahah.
     *         Dana dikirim langsung ke institusi pendidikan (beneficiary), bukan ke mahasiswa.
     * @param _student Alamat dompet mahasiswa.
     * @param _beneficiary Alamat dompet institusi pendidikan.
     * @param _purchasePrice Harga pokok yg akan dibayarkan ke institusi.
     * @param _sellingPrice Harga jual yg akan menjadi kewajiban mahasiswa (pokok + margin).
     */
    function executeFinancing(
        address _student,
        address _beneficiary,
        uint256 _purchasePrice,
        uint256 _sellingPrice
    ) external onlyOwner {
        require(_student != address(0), "LoanPlatform: Invalid student address");
        require(_beneficiary != address(0), "LoanPlatform: Invalid beneficiary address");
        require(_purchasePrice > 0, "LoanPlatform: Purchase price must be greater than zero");
        require(_sellingPrice >= _purchasePrice, "LoanPlatform: Selling price must be >= purchase price");
        
        uint256 poolValue = getPoolValue();
        require(poolValue > 0, "LoanPlatform: Pool is empty");
        
        // CEK TINGKAT UTILISASI: Pastikan tidak melebihi maxUtilizationRate (80%)
        // Formula: (totalFinancingActive + purchasePrice) * 10000 / poolValue <= maxUtilizationRate
        uint256 newTotalFinancing = totalFinancingActive + _purchasePrice;
        uint256 utilizationRate = (newTotalFinancing * 10000) / poolValue;
        require(
            utilizationRate <= maxUtilizationRate,
            "LoanPlatform: Utilization rate exceeded"
        );
        
        // Validasi pool memiliki cukup likuiditas tunai
        uint256 availableCash = underlyingToken.balanceOf(address(this));
        require(
            availableCash >= _purchasePrice,
            "LoanPlatform: Insufficient cash in pool"
        );
        
        // Transfer purchasePrice (harga pokok) ke beneficiary (institusi pendidikan)
        require(
            underlyingToken.transfer(_beneficiary, _purchasePrice),
            "LoanPlatform: Transfer to beneficiary failed"
        );
        
        // Update totalFinancingActive
        totalFinancingActive = newTotalFinancing;
        
        // Buat entri baru di mapping financings
        uint256 financingId = nextFinancingId;
        financings[financingId] = Financing({
            student: _student,
            beneficiary: _beneficiary,
            purchasePrice: _purchasePrice,
            sellingPrice: _sellingPrice,
            amountRepaid: 0,
            isActive: true
        });
        nextFinancingId++;
        
        emit FinancingExecuted(financingId, _student, _beneficiary, _purchasePrice, _sellingPrice);
    }

    /**
     * @notice [MAHASISWA] Membayar angsuran pembiayaan.
     *         Pembayaran dipisahkan menjadi pokok dan margin keuntungan.
     *         Margin dibagi 80% untuk investor pool dan 20% untuk platform.
     * @param _financingId ID pembiayaan yg akan dibayar.
     * @param _amount Jumlah yg dibayar.
     */
    function repay(uint256 _financingId, uint256 _amount) external {
        require(_amount > 0, "LoanPlatform: Amount must be greater than zero");
        
        Financing storage financing = financings[_financingId];
        require(financing.isActive, "LoanPlatform: Financing is not active");
        require(
            msg.sender == financing.student,
            "LoanPlatform: Only student can repay their financing"
        );
        
        // Validasi amount tidak melebihi sisa kewajiban
        uint256 remainingDebt = financing.sellingPrice - financing.amountRepaid;
        require(_amount <= remainingDebt, "LoanPlatform: Amount exceeds remaining debt");
        
        // Transfer stablecoin dari mahasiswa ke kontrak
        require(
            underlyingToken.transferFrom(msg.sender, address(this), _amount),
            "LoanPlatform: Transfer failed"
        );
        
        // Pisahkan pembayaran menjadi pokok dan margin
        // Proporsi pokok vs margin tetap konsisten: pokok = (purchasePrice / sellingPrice) dari setiap pembayaran
        // Margin = sellingPrice - purchasePrice (total margin dari awal)
        
        // Hitung proporsi pokok dan margin dari pembayaran saat ini
        // Proporsi pokok selalu = (amount * purchasePrice) / sellingPrice
        // Ini memastikan proporsi konsisten untuk semua pembayaran
        uint256 principalAmount = (_amount * financing.purchasePrice) / financing.sellingPrice;
        uint256 marginAmount = _amount - principalAmount;
        
        // Pastikan total principal yang dibayar tidak melebihi purchasePrice
        uint256 totalPrincipalPaid = (financing.amountRepaid * financing.purchasePrice) / financing.sellingPrice;
        uint256 remainingPrincipal = financing.purchasePrice - totalPrincipalPaid;
        
        // Jika principalAmount melebihi remainingPrincipal, sesuaikan
        if (principalAmount > remainingPrincipal) {
            principalAmount = remainingPrincipal;
            marginAmount = _amount - principalAmount;
        }
        
        // Distribusi margin (80% investor, 20% platform)
        uint256 platformShare = (marginAmount * platformShareRatio) / 10000;
        // Investor share = marginAmount - platformShare
        // Investor share tetap di pool (tidak perlu transfer eksplisit)
        
        // Transfer platform share ke platformTreasury
        if (platformShare > 0) {
            require(
                underlyingToken.transfer(platformTreasury, platformShare),
                "LoanPlatform: Transfer to treasury failed"
            );
        }
        
        // Investor share tetap di pool (meningkatkan nilai LP token)
        // Tidak perlu transfer, karena token sudah di kontrak
        
        // Update amountRepaid
        financing.amountRepaid += _amount;
        
        // Update totalFinancingActive (dikurangi porsi pokok yg dibayar)
        if (principalAmount > 0 && totalFinancingActive >= principalAmount) {
            totalFinancingActive -= principalAmount;
        }
        
        // Jika lunas, set isActive = false
        if (financing.amountRepaid >= financing.sellingPrice) {
            financing.isActive = false;
        }
        
        emit RepaymentMade(_financingId, msg.sender, _amount, principalAmount, marginAmount);
    }

    // =================================================================
    //                 Fungsi View & Helper (Read-Only)
    // =================================================================

    /**
     * @notice Menghitung total nilai aset di dalam pool.
     *         Pool value = tunai di kontrak + dana yg sedang dipinjamkan keluar.
     * @return Total nilai pool dalam stablecoin.
     */
    function getPoolValue() public view returns (uint256) {
        return underlyingToken.balanceOf(address(this)) + totalFinancingActive;
    }

    /**
     * @notice Menghitung nilai dari 1 token LP dalam stablecoin.
     *         Nilai LP token meningkat saat ada margin keuntungan dari pembiayaan.
     * @return Nilai 1 LP token dalam stablecoin (dengan 18 desimal).
     */
    function getLpTokenValue() public view returns (uint256) {
        uint256 totalSupply = eduLpToken.totalSupply();
        if (totalSupply == 0) {
            return 1e18; // Asumsi 1:1 jika supply masih 0, dengan 18 desimal
        }
        return (getPoolValue() * 1e18) / totalSupply;
    }

    /**
     * @notice Mendapatkan informasi pembiayaan berdasarkan ID.
     * @param _financingId ID pembiayaan.
     * @return Struct Financing dengan semua detail.
     */
    function getFinancing(uint256 _financingId) external view returns (Financing memory) {
        return financings[_financingId];
    }

    /**
     * @notice Menghitung sisa kewajiban mahasiswa untuk pembiayaan tertentu.
     * @param _financingId ID pembiayaan.
     * @return Sisa kewajiban yang harus dibayar.
     */
    function getRemainingDebt(uint256 _financingId) external view returns (uint256) {
        Financing memory financing = financings[_financingId];
        if (!financing.isActive) {
            return 0;
        }
        return financing.sellingPrice - financing.amountRepaid;
    }

    /**
     * @notice Menghitung tingkat utilisasi pool saat ini.
     * @return Utilisasi dalam basis points (contoh: 8000 = 80%).
     */
    function getUtilizationRate() external view returns (uint256) {
        uint256 poolValue = getPoolValue();
        if (poolValue == 0) {
            return 0;
        }
        return (totalFinancingActive * 10000) / poolValue;
    }
}
