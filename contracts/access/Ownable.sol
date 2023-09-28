// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PandaFixToken is ERC20Burnable, Ownable {
    using SafeMath for uint256;

    string private _name = "PandaFix"; // Customize: Token Name
    string private _symbol = "PFX"; // Customize: Token Symbol
    uint8 private _decimals = 18; // Customize: Number of Decimals
    uint256 private _totalSupply = 1000000000 * 10**uint256(_decimals); // Customize: Total Supply
    uint256 private _maxBuyAmount = _totalSupply.mul(5).div(1000); // 0.5% of total supply
    uint256 private _maxSellAmount = _totalSupply.mul(5).div(1000); // 0.5% of total supply
    uint256 private _developerFeePercent = 5; // 0.5% Customize: Developer Fee Percentage
    uint256 private _liquidityFeePercent = 5; // 0.5% Customize: Liquidity Fee Percentage
    uint256 private _investorFeePercent = 10; // 1% Customize: Investor Fee Percentage
    address private _developerWallet = address(0xYourDeveloperWallet); // Customize: Developer Wallet Address
    address private _liquidityWallet = address(0xYourLiquidityWallet); // Customize: Liquidity Wallet Address
    address private _investorWallet = address(0xYourInvestorWallet); // Customize: Investor Wallet Address
    bool private _developerWalletLocked = false;
    bool private _liquidityWalletLocked = false;
    bool private _investorWalletLocked = false;

    // Anti-whale policy
    modifier checkBuyAmount(uint256 amount) {
        require(amount <= _maxBuyAmount || msg.sender == owner(), "Buy amount exceeds the limit");
        _;
    }

    modifier checkSellAmount(uint256 amount) {
        require(amount <= _maxSellAmount || msg.sender == owner(), "Sell amount exceeds the limit");
        _;
    }

    constructor() ERC20(_name, _symbol) {
        _mint(msg.sender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        checkSellAmount(amount)
        returns (bool)
    {
        require(!_developerWalletLocked || msg.sender == owner(), "Developer wallet is locked");
        require(!_liquidityWalletLocked || msg.sender == owner(), "Liquidity wallet is locked");
        require(!_investorWalletLocked || msg.sender == owner(), "Investor wallet is locked");

        uint256 fee = calculateFee(amount);
        uint256 transferAmount = amount.sub(fee);

        super.transfer(_developerWallet, fee.mul(_developerFeePercent).div(100));
        super.transfer(_liquidityWallet, fee.mul(_liquidityFeePercent).div(100));
        super.transfer(_investorWallet, fee.mul(_investorFeePercent).div(100));
        super.transfer(recipient, transferAmount);

        return true;
    }

    function calculateFee(uint256 amount) private view returns (uint256) {
        return amount.mul(2).div(100); // 2% fee
    }

    function lockDeveloperWallet() external onlyOwner {
        _developerWalletLocked = true;
    }

    function unlockDeveloperWallet() external onlyOwner {
        _developerWalletLocked = false;
    }

    function lockLiquidityWallet() external onlyOwner {
        _liquidityWalletLocked = true;
    }

    function unlockLiquidityWallet() external onlyOwner {
        _liquidityWalletLocked = false;
    }

    function lockInvestorWallet() external onlyOwner {
        _investorWalletLocked = true;
    }

    function unlockInvestorWallet() external onlyOwner {
        _investorWalletLocked = false;
    }

    function isDeveloperWalletLocked() external view returns (bool) {
        return _developerWalletLocked;
    }

    function isLiquidityWalletLocked() external view returns (bool) {
        return _liquidityWalletLocked;
    }

    function isInvestorWalletLocked() external view returns (bool) {
        return _investorWalletLocked;
    }

    // Set maximum buy and sell amounts (onlyOwner)
    function setMaxBuyAmount(uint256 amount) external onlyOwner {
        _maxBuyAmount = amount;
    }

    function setMaxSellAmount(uint256 amount) external onlyOwner {
        _maxSellAmount = amount;
    }

    // Get maximum buy and sell amounts
    function getMaxBuyAmount() external view returns (uint256) {
        return _maxBuyAmount;
    }

    function getMaxSellAmount() external view returns (uint256) {
        return _maxSellAmount;
    }
}
