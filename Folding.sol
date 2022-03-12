pragma solidity ^0.8.10;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface auTOKEN {
    function transfer(address dst, uint amount) external returns (bool);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
    function borrowRatePerBlock() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
    function totalBorrowsCurrent() external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);
    function borrowBalanceStored(address account) public view returns (uint);
    function exchangeRateCurrent() public returns (uint);
    function exchangeRateStored() public view returns (uint);
    function getCash() external view returns (uint);
    function accrueInterest() public returns (uint);
    function seize(address liquidator, address borrower, uint seizeTokens) external returns (uint);
}

interface Comptroller {
     /// @notice Indicator that this is a Comptroller contract (for inspection)
    bool public constant isComptroller = true;

    /*** Assets You Are In ***/

    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
    function exitMarket(address cToken) external returns (uint);

    /*** Policy Hooks ***/

    function mintAllowed(address cToken, address minter, uint mintAmount) external returns (uint);
    function mintVerify(address cToken, address minter, uint mintAmount, uint mintTokens) external;

    function redeemAllowed(address cToken, address redeemer, uint redeemTokens) external returns (uint);
    function redeemVerify(address cToken, address redeemer, uint redeemAmount, uint redeemTokens) external;

    function borrowAllowed(address cToken, address borrower, uint borrowAmount) external returns (uint);
    function borrowVerify(address cToken, address borrower, uint borrowAmount) external;

    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint repayAmount) external returns (uint);
    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) external;

    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external returns (uint);
    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external;

    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external returns (uint);
    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external;

    function transferAllowed(address cToken, address src, address dst, uint transferTokens) external returns (uint);
    function transferVerify(address cToken, address src, address dst, uint transferTokens) external;

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint repayAmount) external view returns (uint, uint);
}

contract AurigamiFolding is Ownable {

    Comptroller comptroller = Comptroller(0xdF9361edfde4ebb90e32fDb4671AA221eaf24F46);
    
    // Sets the address of the owner
    constructor(address _owner)  {
        owner = _owner;

        // enable all assets to be used as collateral
        address[] markets = comptroller.getAllMarkets()
        comptroller.enterMarkets(markets);

        // approve all assets to be accessed by the corresponding auToken
        // create a map of the underlying token to its corresponding auToken
        for(uint i; i < markets.length; i++) {
            IERC20(markets[i].underlying()).approve(address(markets[i]), 2**256 - 1);
        }
    }

    // Allows user to deposit assets into the contract
    function depositAsset(address asset, uint256 amount) public {
        require(tokenToAuToken[asset] != address(0), "Asset not available")
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
    }

    // Function that will fold an asset to collateral factor 5% less than the max
    function foldSafeMax(address asset, uint256 initialAmount) public onlyOwner {
        //Fetch corresponding auToken
        auToken token = auToken(getAuToken(asset));
        // Fetches the max collateralFactor for the specific asset (must divide by 10**18)
        (, maxCollateralFactor,) = comptroller.markets(address(token));
        // The minus 5 ensures that the likelihood of liquidation is very low 
        fold(asset, initialAmount, (maxCollateralFactor/10**18) - 0.05);
    }

    // Main function in charge of folding
    function fold(address asset, uint256 initialAmount, uint256 collateralFactorDesired) public {
        // Checks that caller is owner or contract itself
        require(msg.sender == owner || msg.sender == address(this), "Can only be accessed by owner");

        //Fetch corresponding auToken
        auToken token = auToken(getAuToken(asset));
        // Fetches the max collateralFactor for the specific asset
        (, maxCollateralFactor,) = comptroller.markets(address(token));
        
        // Mints the initialAmount deposited by the user
        auToken.mint(initialAmount);

        // Supply amount equals the amount to be deposited
        // Borrow amount equals the amount to be borrowed
        uint256 supplyAmount = initialAmount;
        uint256 borrowAmount = supplyAmount*(maxCollateralFactor/10**18);

        uint256 currentCollateralFactor = 0;

        while currentCollateralFactor < collateralFactorDesired {
            borrow(auToken, IERC20(asset), borrowAmount);
            supplyAmount = borrowAmount;
            supply(auToken, IERC20(asset), supplyAmount);
            currentCollateralFactor = calculateCollateralFactor(token);
        }
    }

    function unWind(address asset) public onlyOwner {
        
        //Fetch corresponding auToken
        auToken token = auToken(getAuToken(asset));

        uint256 maxWithdrawable = getWithdrawableAmount();

        while token.balanceOf(address(this)) > 0 {
            redeemUnderlying(token, maxWithdrawable);
            repayBorrow(token, maxWithdrawable);
            maxWithdrawable = getWithdrawableAmount();
        }
    }

    // Allows user to deposit collateral without borrowing
    function addCollateral(address asset, uint amount) public onlyOwner {
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        //Fetch corresponding auToken
        auToken token = auToken(getAuToken(asset));
        auToken.mint(amount);
    }




    // ======== BASIC FUNCTIONs TO INTERACT WITH AURIGAMI ======== // 

    function supply(auTOKEN token, uint256 amount) internal {
        token.mint(amount);
    }

    function borrow(auTOKEN token, uint256 amount) internal {
        token.borrow(amount);
    }

    function redeemUnderlying(auTOKEN token, uint256 amount) internal {
        token.redeem(amount);
    }

    function repay(auTOKEN token, uint256 amount) internal {
        token.repayBorrow();
    } 



    // =========== GETTER FUNCTION =============== //

    function getAuToken(address asset) public view returns (address) {
        address[] markets = comptroller.getAllMarkets()
        for(uint256 i; i < markets.length; i++) {
            if(markets[i].underlying() == asset) {
                return markets[i];
            }
        }
    }

    function getWithdrawableAmount() public view returns (uint256) {
        return comptroller.getAccountLiquidity();
    }

    function calculateCollateralFactor(auToken token) private view returns (uint256) {
        uint256 totalDeposited = token.balanceOf(address(this)) * token.exchangeRateStored();
        uint256 totalBorrowed = token.borrowBalanceStored(address(this));
        return totalBorrowed / totalDeposited;
    }     
}
