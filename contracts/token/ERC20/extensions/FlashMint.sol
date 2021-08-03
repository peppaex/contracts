// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interface/IERC3156.sol";
import "../ERC20.sol";

/**
 * @dev 执行了ERC3156闪电贷扩展, 请参阅 https://eips.ethereum.org/EIPS/eip-3156[ERC-3156].
 *
 * 添加 {flashLoan} 方法，该方法在令牌级别提供闪电贷款支持. 默认情况下没有费用，但可以通过覆盖 {flashFee} 来更改.
 */
abstract contract FlashMint is ERC20, IERC3156FlashLender {
    bytes32 private constant _RETURN_VALUE = keccak256("ERC3156FlashBorrower.onFlashLoan");

    /**
     * @dev 返回可借用的最大令牌数量.
     * @param token 请求的令牌地址.
     * @return 可借出的令牌数量.
     */
    function maxFlashLoan(address token) public view override returns (uint256) {
        return token == address(this) ? type(uint256).max - ERC20.totalSupply : 0;
    }

    /**
     * @dev 返回进行闪电贷款时应付的费用. 默认情况下，此实现的费用为0. 
     * 可以重载此功能以使闪电贷机制通货紧缩.
     * @param token 贷款的令牌地址.
     * @param amount 借出的令牌数量.
     * @return 适用于相应闪电贷的费用.
     */
    function flashFee(address token, uint256 amount) public view virtual override returns (uint256) {
        require(token == address(this), "ERC20FlashMint: wrong token");
        // 在不添加字节码的情况下对未使用变量的警告静音.
        amount;
        return 0;
    }

    /**
     * @dev 执行闪电贷. 新令牌被铸造并发送到"接收者"，后者需要实现 {IERC3156FlashBorrower} 接口.
     * 到闪电贷结束时，接收者预计将拥有金额 + 费用代币，并将它们批准回代币合约本身，以便它们可以被销毁.
     * @param receiver 闪电贷的接收者。 应该实现 {IERC3156FlashBorrower.onFlashLoan} 接口.
     * @param token 要闪借的代币。 仅支持`address(this)`.
     * @param amount 借出的令牌数量.
     * @param data 传递给接收器的任意数据字段.
     * @return `true` 表示闪电贷已经成功.
     */
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) public virtual override returns (bool) {
        uint256 fee = flashFee(token, amount);
        _mint(address(receiver), amount);
        require(
            receiver.onFlashLoan(msg.sender, token, amount, fee, data) == _RETURN_VALUE,
            "ERC20FlashMint: invalid return value"
        );
        uint256 currentAllowance = allowance[address(receiver)][address(this)];
        require(currentAllowance >= amount + fee, "ERC20FlashMint: allowance does not allow refund");
        _approve(address(receiver), address(this), currentAllowance - amount - fee);
        _burn(address(receiver), amount + fee);
        return true;
    }
}
