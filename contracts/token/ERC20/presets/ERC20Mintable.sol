// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../extensions/Mintable.sol";

/**
 * @dev {ERC20} 可铸造新令牌.
 *
 */
contract ERC20Mintable is Mintable {
    /**
     * @dev 设置 {name} 和 {symbol} 的值. 同时为 `owner` 账户铸造数量为 `initialSupply` 的令牌
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 initialSupply,
        address owner
    ) ERC20(_name, _symbol, initialSupply, owner) {}
}
