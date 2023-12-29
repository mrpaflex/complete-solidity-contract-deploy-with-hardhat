// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Additional imports for Uniswap interfaces
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract AQUAAI is ERC20, Ownable {
    uint8 private constant DECIMALS = 9;
    uint public buyTaxRate = 5;  // 5% buy tax
    uint public sellTaxRate = 5; // 5% sell tax
    address public taxWallet = 0x85B71cdA253f0D9448D72894d58749a6EF28F22E;

    // Uniswap Router address 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    address public uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;


       constructor() ERC20("AQUAAI", "AQI") Ownable(msg.sender) {
        _mint(msg.sender, 100000000 * 10**DECIMALS);
      
    }

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(to != address(0), "AQUAAI: transfer to the zero address");
        require(balanceOf(msg.sender) >= value, "AQUAAI: insufficient balance");

        uint256 taxAmount;
        if (to == uniswapRouter) {
            // Sell transaction - apply sell tax
            taxAmount = (value * sellTaxRate) / 100;
        } else {
            // Buy transaction - apply buy tax
            taxAmount = (value * buyTaxRate) / 100;
        }

        uint256 transferAmount = value - taxAmount;

        _transfer(msg.sender, taxWallet, taxAmount);
        _transfer(msg.sender, to, transferAmount);

        return true;
    }

    function swapTokensForEth(uint256 tokenAmount) external onlyOwner {
        // Interaction with Uniswap Router to swap tokens for ETH
        IUniswapV2Router02 router = IUniswapV2Router02(uniswapRouter);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETH(
            tokenAmount,
            0, // Accept any amount of ETH
            path,
            address(this),
            block.timestamp + 3600
        );
    }

       function feeTo() external view returns (address) {
        return taxWallet;
    }

    function setUniswapRouter(address _uniswapRouter) public onlyOwner(){
        uniswapRouter = _uniswapRouter;
    }

    function setBuyTaxRate(uint256 newBuyTaxRate) external onlyOwner {
        require(newBuyTaxRate <= 10, "AQUAAI: buy tax rate must be 10% or lower");
        buyTaxRate = newBuyTaxRate;
    }

    function setSellTaxRate(uint256 newSellTaxRate) external onlyOwner {
        require(newSellTaxRate <= 10, "AQUAAI: sell tax rate must be 10% or lower");
        sellTaxRate = newSellTaxRate;
    }
}
