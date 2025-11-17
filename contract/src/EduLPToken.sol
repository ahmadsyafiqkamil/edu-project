// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract EduLPToken is ERC20, Ownable {
    address public loanPlatform;

    event EduLPTokenMinted(address indexed to, uint256 amount);
    event EduLPTokenBurned(address indexed from, uint256 amount);

    modifier onlyLoanPlatform() {
         _onlyLoanPlatform();
         _;
     }

     function _onlyLoanPlatform() internal view {
         require(msg.sender == loanPlatform, "EduLPToken: Only loan platform can call");
     }

    constructor (address initialOwner) ERC20("Education LP Token", "eduLP") Ownable(initialOwner){}
    
    function setLoanPlatform(address _loanPlatform) external onlyOwner(){
        require(_loanPlatform != address(0),"Invalid address");
        require(loanPlatform == address(0),"already set");
        loanPlatform = _loanPlatform;
    }

    function mint(address to, uint256 amount) external onlyLoanPlatform{
        _mint(to, amount);
        emit EduLPTokenMinted(to, amount);
    }

    function burn(address from, uint256 amount) external onlyLoanPlatform{
        _burn(from, amount);
        emit EduLPTokenBurned(from, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function remainingSupply() external view returns (uint256) {
        return type(uint256).max - totalSupply();
    }
}






// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

// /**
//  * @title EduLPToken
//  * @notice Token LP (Liquidity Provider) untuk Education Liquidity Pool.
//  *         Token ini mewakili kepemilikan saham investor di dalam pool.
//  *         Hanya kontrak LoanPlatform yang dapat mencetak (mint) dan membakar (burn) token ini.
//  */
// contract EduLPToken is ERC20, Ownable {
    
//     // =================================================================
//     //                           State Variables
//     // =================================================================
    
//     address public loanPlatform; // Alamat kontrak LoanPlatform yang berhak mint/burn
    
//     event EduLPTokenMinted(address indexed to, uint256 amount);
//     event EduLPTokenBurned(address indexed from, uint256 amount);


//     // =================================================================
//     //                           Modifiers
//     // =================================================================
    
//     /**
//      * @notice Memastikan hanya kontrak LoanPlatform yang dapat memanggil fungsi tertentu.
//      */
//     modifier onlyLoanPlatform() {
//         require(msg.sender == loanPlatform, "EduLPToken: Only LoanPlatform can call this function");
//         _;
//     }
    
//     // =================================================================
//     //                           Constructor
//     // =================================================================
    
//     /**
//      * @notice Membuat token LP baru dengan nama "Education LP Token" dan simbol "eduLP".
//      * @param _initialOwner Alamat yang akan menjadi owner (biasanya deployer).
//      */
//     constructor(address _initialOwner) ERC20("Education LP Token", "eduLP") Ownable(_initialOwner) {
//         // Token dimulai dengan supply 0
//         // Supply akan bertambah saat investor melakukan deposit
//     }
    
//     // =================================================================
//     //                      Fungsi untuk LoanPlatform
//     // =================================================================
    
//     /**
//      * @notice Menetapkan alamat kontrak LoanPlatform.
//      *         Hanya bisa dipanggil sekali oleh owner.
//      * @param _loanPlatform Alamat kontrak LoanPlatform.
//      */
//     function setLoanPlatform(address _loanPlatform) external onlyOwner {
//         require(_loanPlatform != address(0), "EduLPToken: Invalid address");
//         require(loanPlatform == address(0), "EduLPToken: LoanPlatform already set");
//         loanPlatform = _loanPlatform;
//     }
    
//     /**
//      * @notice Mencetak token LP baru untuk investor yang melakukan deposit.
//      *         Hanya bisa dipanggil oleh kontrak LoanPlatform.
//      * @param _to Alamat investor yang akan menerima token.
//      * @param _amount Jumlah token yang akan dicetak.
//      */
//     function mint(address _to, uint256 _amount) external onlyLoanPlatform {
//         require(_to != address(0), "EduLPToken: Cannot mint to zero address");
//         require(_amount > 0, "EduLPToken: Amount must be greater than zero");
        
//         _mint(_to, _amount);
//         emit EduLPTokenMinted(_to, _amount);
//     }
    
//     /**
//      * @notice Membakar token LP saat investor melakukan withdraw.
//      *         Hanya bisa dipanggil oleh kontrak LoanPlatform.
//      * @param _from Alamat investor yang tokennya akan dibakar.
//      * @param _amount Jumlah token yang akan dibakar.
//      */
//     function burn(address _from, uint256 _amount) external onlyLoanPlatform {
//         require(_from != address(0), "EduLPToken: Cannot burn from zero address");
//         require(_amount > 0, "EduLPToken: Amount must be greater than zero");
//         require(balanceOf(_from) >= _amount, "EduLPToken: Insufficient balance to burn");
        
//         _burn(_from, _amount);
//         emit EduLPTokenBurned(_from, _amount);
//     }
    
//     // =================================================================
//     //                      Fungsi View (Read-Only)
//     // =================================================================
    
//     /**
//      * @notice Mengembalikan jumlah desimal token (default ERC20 adalah 18).
//      * @return Jumlah desimal.
//      */
//     function decimals() public pure override returns (uint8) {
//         return 18;
//     }

//     /**
//      * @dev Cek sisa supply yang bisa dimint
//      */
//     function remainingSupply() external view returns (uint256) {
//         return type(uint256).max - totalSupply();
//     }
// }