// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../access/Ownable.sol";

/**
 * @dev {ERC20} 可铸造新令牌.
 *
 */
abstract contract Mintable is ERC20, Ownable {
    /**
     * @dev 为 `to` 账户创建数量为 `amount` 的新令牌.
     *
     * 要求:
     *
     * - 调用者需要是合约的owner,参考{Ownable}.
     */
    function mint(address to, uint256 amount) public virtual onlyOwner {
        _mint(to, amount);
    }
}
