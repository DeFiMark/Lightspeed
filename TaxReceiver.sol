//SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IRouter {
    error EXPIRED();
    error IDENTICAL();
    error ZERO_ADDRESS();
    error INSUFFICIENT_AMOUNT();
    error INSUFFICIENT_LIQUIDITY();
    error INSUFFICIENT_OUTPUT_AMOUNT();
    error INVALID_PATH();
    error INSUFFICIENT_B_AMOUNT();
    error INSUFFICIENT_A_AMOUNT();
    error EXCESSIVE_INPUT_AMOUNT();
    error ETH_TRANSFER_FAILED();
    error INVALID_RESERVES();

    struct route {
        /// @dev token from
        address from;
        /// @dev token to
        address to;
        /// @dev is stable route
        bool stable;
    }

    /// @notice sorts the tokens to see what the expected LP output would be for token0 and token1 (A/B)
    /// @param tokenA the address of tokenA
    /// @param tokenB the address of tokenB
    /// @return token0 address of which becomes token0
    /// @return token1 address of which becomes token1
    function sortTokens(
        address tokenA,
        address tokenB
    ) external pure returns (address token0, address token1);

    /// @notice calculates the CREATE2 address for a pair without making any external calls
    /// @param tokenA the address of tokenA
    /// @param tokenB the address of tokenB
    /// @param stable if the pair is using the stable curve
    /// @return pair address of the pair
    function pairFor(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (address pair);

    /// @notice fetches and sorts the reserves for a pair
    /// @param tokenA the address of tokenA
    /// @param tokenB the address of tokenB
    /// @param stable if the pair is using the stable curve
    /// @return reserveA get the reserves for tokenA
    /// @return reserveB get the reserves for tokenB
    function getReserves(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (uint256 reserveA, uint256 reserveB);

    /// @notice performs chained getAmountOut calculations on any number of pairs
    /// @param amountIn the amount of tokens of routes[0] to swap
    /// @param routes the struct of the hops the swap should take
    /// @return amounts uint array of the amounts out
    function getAmountsOut(
        uint256 amountIn,
        route[] memory routes
    ) external view returns (uint256[] memory amounts);

    /// @notice performs chained getAmountOut calculations on any number of pairs
    /// @param amountIn amount of tokenIn
    /// @param tokenIn address of the token going in
    /// @param tokenOut address of the token coming out
    /// @return amount uint amount out
    /// @return stable if the curve used is stable or not
    function getAmountOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint256 amount, bool stable);

    /// @notice performs calculations to determine the expected state when adding liquidity
    /// @param tokenA the address of tokenA
    /// @param tokenB the address of tokenB
    /// @param stable if the pair is using the stable curve
    /// @param amountADesired amount of tokenA desired to be added
    /// @param amountBDesired amount of tokenB desired to be added
    /// @return amountA amount of tokenA added
    /// @return amountB amount of tokenB added
    /// @return liquidity liquidity value added
    function quoteAddLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 amountADesired,
        uint256 amountBDesired
    )
        external
        view
        returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    /// @param tokenA the address of tokenA
    /// @param tokenB the address of tokenB
    /// @param stable if the pair is using the stable curve
    /// @param liquidity liquidity value to remove
    /// @return amountA amount of tokenA removed
    /// @return amountB amount of tokenB removed
    function quoteRemoveLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 liquidity
    ) external view returns (uint256 amountA, uint256 amountB);

    /// @param tokenA the address of tokenA
    /// @param tokenB the address of tokenB
    /// @param stable if the pair is using the stable curve
    /// @param amountADesired amount of tokenA desired to be added
    /// @param amountBDesired amount of tokenB desired to be added
    /// @param amountAMin slippage for tokenA calculated from this param
    /// @param amountBMin slippage for tokenB calculated from this param
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    /// @return amountA amount of tokenA used
    /// @return amountB amount of tokenB used
    /// @return liquidity amount of liquidity minted
    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    /// @param token the address of token
    /// @param stable if the pair is using the stable curve
    /// @param amountTokenDesired desired amount for token
    /// @param amountTokenMin slippage for token
    /// @param amountETHMin minimum amount of ETH added (slippage)
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    /// @return amountToken amount of the token used
    /// @return amountETH amount of ETH used
    /// @return liquidity amount of liquidity minted
    function addLiquidityETH(
        address token,
        bool stable,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    /// @param tokenA the address of tokenA
    /// @param tokenB the address of tokenB
    /// @param stable if the pair is using the stable curve
    /// @param amountADesired amount of tokenA desired to be added
    /// @param amountBDesired amount of tokenB desired to be added
    /// @param amountAMin slippage for tokenA calculated from this param
    /// @param amountBMin slippage for tokenB calculated from this param
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    /// @return amountA amount of tokenA used
    /// @return amountB amount of tokenB used
    /// @return liquidity amount of liquidity minted
    function addLiquidityAndStake(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    /// @notice adds liquidity to a legacy pair using ETH, and stakes it into a gauge on "to's" behalf
    /// @param token the address of token
    /// @param stable if the pair is using the stable curve
    /// @param amountTokenDesired amount of token to be used
    /// @param amountTokenMin slippage of token
    /// @param amountETHMin slippage of ETH
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    /// @return amountA amount of tokenA used
    /// @return amountB amount of tokenB used
    /// @return liquidity amount of liquidity minted
    function addLiquidityETHAndStake(
        address token,
        bool stable,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    /// @param tokenA the address of tokenA
    /// @param tokenB the address of tokenB
    /// @param stable if the pair is using the stable curve
    /// @param liquidity amount of LP tokens to remove
    /// @param amountAMin slippage of tokenA
    /// @param amountBMin slippage of tokenB
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    /// @return amountA amount of tokenA used
    /// @return amountB amount of tokenB used
    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    /// @param token address of the token
    /// @param stable if the pair is using the stable curve
    /// @param liquidity liquidity tokens to remove
    /// @param amountTokenMin slippage of token
    /// @param amountETHMin slippage of ETH
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    /// @return amountToken amount of token used
    /// @return amountETH amount of ETH used
    function removeLiquidityETH(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
    /// @param amountIn amount to send ideally
    /// @param amountOutMin slippage of amount out
    /// @param routes the hops the swap should take
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    /// @return amounts amounts returned
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        route[] calldata routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    /// @param routes the hops the swap should take
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    /// @return amounts amounts returned
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        route[] memory routes,
        address to,
        uint deadline
    ) external returns (uint256[] memory amounts);
    /// @param amountOutMin slippage of token
    /// @param routes the hops the swap should take
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    /// @return amounts amounts returned
    function swapExactETHForTokens(
        uint256 amountOutMin,
        route[] calldata routes,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    /// @param amountOut amount of tokens to get out
    /// @param amountInMax max amount of tokens to put in to achieve amountOut (slippage)
    /// @param routes the hops the swap should take
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    /// @return amounts amounts returned
    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        route[] calldata routes,
        address to,
        uint deadline
    ) external returns (uint256[] memory amounts);
    /// @param amountIn amount of tokens to swap
    /// @param amountOutMin slippage of token
    /// @param routes the hops the swap should take
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    /// @return amounts amounts returned
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        route[] calldata routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    /// @param amountOut exact amount out or revert
    /// @param routes the hops the swap should take
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    /// @return amounts amounts returned
    function swapETHForExactTokens(
        uint amountOut,
        route[] calldata routes,
        address to,
        uint deadline
    ) external payable returns (uint256[] memory amounts);

    /// @param amountIn token amount to swap
    /// @param amountOutMin slippage of token
    /// @param routes the hops the swap should take
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        route[] calldata routes,
        address to,
        uint256 deadline
    ) external;

    /// @param amountOutMin slippage of token
    /// @param routes the hops the swap should take
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        route[] calldata routes,
        address to,
        uint256 deadline
    ) external payable;

    /// @param amountIn token amount to swap
    /// @param amountOutMin slippage of token
    /// @param routes the hops the swap should take
    /// @param to the address the liquidity tokens should be minted to
    /// @param deadline timestamp deadline
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        route[] calldata routes,
        address to,
        uint256 deadline
    ) external;

    /// @notice **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens)****
    /// @param token address of the token
    /// @param stable if the swap curve is stable
    /// @param liquidity liquidity value (lp tokens)
    /// @param amountTokenMin slippage of token
    /// @param amountETHMin slippage of ETH
    /// @param to address to send to
    /// @param deadline timestamp deadline
    /// @return amountToken amount of token received
    /// @return amountETH amount of ETH received
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

interface IOwnedContract {
    function getOwner() external view returns (address);
}

contract TaxReceiver {

    // Token
    address public immutable token;

    // Addresses
    address public treasury;

    // Reward distributor
    address public rewardDistributor;

    // Token -> BNB
    route public route;

    // router
    IRouter public router = IRouter(0x1D368773735ee1E678950B7A97bcA2CafB330CDc);

    // pause public triggering
    bool public paused;

    modifier onlyOwner(){
        require(
            msg.sender == IOwnedContract(token).getOwner(),
            'Only Token Owner'
        );
        _;
    }

    constructor(address _token, address _treasury, address _rewardDistributor) {

        // set token
        token = _token;
        treasury = _treasury;
        rewardDistributor = _rewardDistributor;

        // initialize swap path
        path = route({
            from: _token,
            to: router.WETH(), // WETH
            stable: false
        })
    }

    function setTreasury(address treasury_) external onlyOwner {
        require(treasury_ != address(0));
        treasury = treasury_;
    }

    function setPath(address[] memory path_) external onlyOwner {
        path = path_;
    }

    function setRewardDistributor(address rewardDistributor_) external onlyOwner {
        require(rewardDistributor_ != address(0));
        rewardDistributor = rewardDistributor_;
    }

    function setRouter(address router_) external onlyOwner {
        require(
            router_ != address(0),
            'Zero Address'
        );
        router = IUniswapV2Router02(router_);
    }

    function withdrawETH(address to) external onlyOwner {
        (bool s,) = payable(to).call{value: address(this).balance}("");
        require(s);
    }
    
    function withdrawToken(address _token, address to) external onlyOwner {
        IERC20(_token).transfer(to, IERC20(_token).balanceOf(address(this)));
    }

    function trigger() external {
        if (paused) {
            return;
        }

        // Token Balance In Contract
        uint balance = IERC20(token).balanceOf(address(this));
        
        // sell Token in contract for ETH
        if (balance > 0) {
            IERC20(token).approve(address(router), balance);
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(balance, 1, path, address(this), block.timestamp + 300);
        }

        if (address(this).balance > 0) {

            uint256 treasuryBalance = address(this).balance / 2;
            uint256 rewardBalance = address(this).balance - treasuryBalance;

            // Send ETH to treasury
            (bool success, ) = payable(treasury).call{value: treasuryBalance}("");
            require(success, "Transfer failed");

            // Send ETH to reward distributor
            (bool successReward, ) = payable(rewardDistributor).call{value: rewardBalance}("");
            require(successReward, "Transfer to reward distributor failed");
        }
    }

    receive() external payable {}
}