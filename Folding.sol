pragma solidity ^0.8.10;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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


    /*** User Interface ***/

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
    function borrowBalanceStored(address account) external view returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function exchangeRateStored() external view returns (uint);
    function getCash() external view returns (uint);
    function accrueInterest() external returns (uint);
    function seize(address liquidator, address borrower, uint seizeTokens) external returns (uint);
    function underlying() external view returns (address);

    function mint(uint256 amount) external;
    function borrow(uint256 amount) external;
    function redeem(uint256 amount) external;
    function repayBorrow(uint256 amount) external;


}

interface Comptroller {

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

    // View function
    function getAllMarkets() external view returns (address[] memory);
    function markets(address token) external view returns (bool, uint256, bool);
    function getAccountLiquidity(address user) external view returns (uint256);
}

/*
A small bug is the owner of this contract will be the factory and not the user. I think the final owner
of this contract can be passed in the constructor, and transferOwnership to the final owner to be done
at the end of the constructor
*/
contract AurigamiFolding is Ownable {

    Comptroller public comptroller = Comptroller(0xdF9361edfde4ebb90e32fDb4671AA221eaf24F46);

    constructor()  {

        // enable all assets to be used as collateral
        address[] memory markets = comptroller.getAllMarkets();
        comptroller.enterMarkets(markets);
        /*
        So in Aurigami, there are certain assets that can't be used as collateral (yet).
        As such, simply entering all markets will cause auto revert.
        */

        /*
        Let's only enter markets when the user does deposit assets, because the only reason
        they do deposit here is to do folding, and to do folding, the assets must be allowed to
        use as collateral

        Plus, it supports new assets if Aurigami adds it as well

        */

        // approve all assets to be accessed by the corresponding auToken
        for(uint i; i < markets.length; i++) {
            IERC20(auTOKEN(markets[i]).underlying()).approve(address(markets[i]), 2**256 - 1);
        }
    }

    // Allows user to deposit assets into the contract
    function depositAsset(address asset, uint256 amount) public {
        require(getAuToken(asset) != address(0), "Asset not available");

        /*
        the logic of transferFrom you are doing here is correct. However, it's strictly better
        to do safeTransferFrom (do using SafeERC20 for IERC20 after importing SafeERC20 from OpenZeppelin)

        The rationale is that some ERC20 tokens, instead of revert on failure, simply return false,
        and the caller needs to check the return result to be non-false before proceeding.
        You can read more here: https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
        Pretty informative read!
        */
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
    }

    // Function that will fold an asset to collateral factor 5% less than the max
    function foldSafeMax(address asset, uint256 initialAmount) public onlyOwner {
        //Fetch corresponding auToken
        auTOKEN token = auTOKEN(getAuToken(asset));

        uint256 maxCollateralFactor;
        // Fetches the max collateralFactor for the specific asset (must divide by 10**18)
        (, maxCollateralFactor,) = comptroller.markets(address(token));
        // The minus 5 ensures that the likelihood of liquidation is very low
        fold(asset, initialAmount, (maxCollateralFactor/10**18) * 5/100);

        /*
        So here, a bit about the norm of integer behaviors in most programming language:
        In normal math: 1 / 2 = 0.5
        In most PL: 1 / 2 = floor(1/2) = 0, (2e18-1) / 1e18 = 1

        As such, the vanila division doesn't work well, and it requires the use of Fixed Point arithmetic

        For this `(maxCollateralFactor/10**18) * 5/100` expression, the correct expression is:
        rdiv(maxCollateralFactor*5,10**18 * 100)

        Also, I think it should be * 95/100 instead (aka the collateral factor is 95% the maxCollateralFactor)
        */
    }

    // Main function in charge of folding
    function fold(address asset, uint256 initialAmount, uint256 collateralFactorDesired) public {
        // Checks that caller is owner or contract itself
        require(msg.sender == owner() || msg.sender == address(this), "Can only be accessed by owner");

        /*
        Just FYI here: if the contract calls one of its functions, the msg.sender will still be the
        original msg.sender. Only when the contracts calls another contract that the msg.sender will be
        changed to the caller's address
        */

        //Fetch corresponding auToken
        auTOKEN token = auTOKEN(getAuToken(asset));
        uint256 maxCollateralFactor;
        // Fetches the max collateralFactor for the specific asset
        (, maxCollateralFactor,) = comptroller.markets(address(token));

        // Mints the initialAmount deposited by the user
        supply(token, initialAmount);

        // Supply amount equals the amount to be deposited
        // Borrow amount equals the amount to be borrowed
        uint256 supplyAmount = initialAmount;
        uint256 borrowAmount = supplyAmount*(maxCollateralFactor/10**18);

        uint256 currentCollateralFactor = 0;

        while (currentCollateralFactor < collateralFactorDesired) {
            /*
            I think everytime borrow the same borrowAmount may not be correct
            Because it's not possible to borrow the same amount every time. After you have resupply
            the borrowAmount, you can borrow at most maxCollateralFactor * borrowAmount

            So for example, on the 2nd borrow, you can borrow at most maxCollateralFactor^2 * original
            supplyAmount

            Also, I think we need to check to make sure that post-borrow, the currentCollateralFactor
            is strictly smaller than the collateralFactorDesired. With the current while condition,
            the folding will only stop when the condition is wrong, aka currentCollateralFactor >= collateralFactorDesired
            */
            borrow(token, borrowAmount);
            supplyAmount = borrowAmount;
            supply(token, supplyAmount);
            currentCollateralFactor = calculateCollateralFactor(token);
        }
    }

    function unWind(address asset) public onlyOwner {

        //Fetch corresponding auToken
        auTOKEN token = auTOKEN(getAuToken(asset));

        uint256 maxWithdrawable = getWithdrawableAmount();

        while (token.balanceOf(address(this)) > 0) {
            redeemUnderlying(token, maxWithdrawable);
            // nice here, but you can check to repay only when the amount owed is > 0
            repay(token, maxWithdrawable);
            maxWithdrawable = getWithdrawableAmount();
        }
    }

    // Allows user to deposit collateral without borrowing
    function addCollateral(address asset, uint amount) public onlyOwner {
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        //Fetch corresponding auToken
        auTOKEN token = auTOKEN(getAuToken(asset));
        supply(token, amount);
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
        token.repayBorrow(amount);
    }



    // =========== GETTER FUNCTION =============== //

    function getAuToken(address asset) public view returns (address) {
        address[] memory markets = comptroller.getAllMarkets();
        for(uint256 i; i < markets.length; i++) {
            if(auTOKEN(markets[i]).underlying() == asset) {
                return markets[i];
            }
        }
    }

    function getWithdrawableAmount() public view returns (uint256) {
        return comptroller.getAccountLiquidity(address(this));
    }

    function calculateCollateralFactor(auTOKEN token) public view returns (uint256) {
        /*
        This is also quite similar to the Fixed Point issue above
        the exchangeRateStored is in Fixed Point, so vaniala multiplication won't work,
        but it has to be rmul(token.balanceOf(address(this)),token.exchangeRateStored())

        same for totalBorrowed / Deposited, has to be rdiv(totalBorrowed,totalDeposited)
        */
        uint256 totalDeposited = token.balanceOf(address(this)) * token.exchangeRateStored();
        uint256 totalBorrowed = token.borrowBalanceStored(address(this));
        return (totalBorrowed / totalDeposited);
    }

    /*
    For all Fixed Point math, please use this simple library https://gist.github.com/UncleGrandpa925/3d0d253c4d12b5105e7ab36189d8f06a
    Using Foundry, you can play with the library to get the gist of it
    For example, to get 3.14 in Fixed Point, you can just do 314 / 100 (in Normal Math), or rdiv(314,100)
    Just play with the library and you will understand it intuitively!
    */
}