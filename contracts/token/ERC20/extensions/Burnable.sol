// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC20.sol";

/**
 * @dev {ERC20} 可销毁令牌.
 *
 */
abstract contract Burnable is ERC20 {
    /**
     * @dev 从调用者账户中销毁数量为 `amount` 的令牌.
     *
     * 参考 {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }

    /**
     * @dev 从 `account`账户中销毁数量为 `amount` 的令牌, 并且扣除调用者的授权额度
     *
     * 参考 {ERC20-_burn} 和 {ERC20-allowance}.
     *
     * 要求:
     *
     * - 调用者需要拥有 `accounts` 授权的大于等于 `amount` 的令牌数量.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance[account][msg.sender];
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, msg.sender, currentAllowance - amount);
        }
        _burn(account, amount);
    }
}
