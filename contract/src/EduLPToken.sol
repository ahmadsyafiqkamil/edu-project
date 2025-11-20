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
