// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {
    uint public maxTxAmount = 10000000 * 10 ** 18;
    
    address public EducationWallet = 0x3fae7B414D00999f5e779B1e1B122BA74f8faBd9;
    address public MarketingWallet = 0xc2b093994e63dCF859af66CA3297856C7e4De0D9;
    address public BurnWallet = 0x000000000000000000000000000000000000dEaD;
    address public taxWallet = 0x6f7E4B19c64950751bec134bf3C0920655166b1b;
    
    uint public EducationFee = 2;
    uint public MarketingFee = 4;
    uint public BurnFee = 0;
    uint public taxFee = 6;

    //
   
//mapping(address => uint) public balances;
//mapping(address => mapping(address => uint)) public allowance; 
mapping (address => bool) private _isExcludedFromFee; 
mapping (address => bool) private _isExcluded;
 
address[] private _excluded;
    
    constructor() ERC20("pricetes", "pct") {
        _mint(msg.sender, 1000000000 * 10 ** 18);
        excludeFromFee(owner());
        excludeFromFee(address(this));
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        _tokenTransfer(sender, recipient, amount);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else {
            require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            _transferStandard(sender, recipient, amount.sub(amount.mul(totalFee).div(100)));
            
            uint256 EducationAmt = amount.mul(EducationFee).div(100);
            uint256 MarketingAmt = amount.mul(MarketingFee).div(100);
            uint256 BurnAmt = amount.mul(BurnFee).div(100);
            uint256 taxAmt = amount.mul(taxFee).div(100);
            
            _transferStandard(sender, EducationWallet, EducationAmt);
            _transferStandard(sender, MarketingWallet, MarketingAmt);
            _transferStandard(sender, BurnWallet, BurnAmt);
            _transferStandard(sender, taxWallet, taxAmt);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 amount) private {
        _transfer(sender, recipient, amount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMaxTxAmount(uint limit) external onlyOwner {
        maxTxAmount = limit;
    }

    function changeFees(uint Education, uint Marketing, uint newburn, uint tax) external onlyOwner {
        BurnFee = newburn;
        taxFee = tax;
        totalFee = Education + Marketing + newburn + tax;
    }
}
