// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../extensions/Snapshotable.sol";
import "../../../access/Ownable.sol";

/**
 * @dev {ERC20} 具有快照功能.
 *
 */
contract ERC20Snapshot is Snapshotable, Ownable {
    /**
     * @dev 设置 {name} 和 {symbol} 的值. 同时为 `owner` 账户铸造数量为 `initialSupply` 的令牌
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 initialSupply,
        address owner
    ) ERC20(_name, _symbol, initialSupply, owner) {}

    /// @dev 快照方法
    function snapshot() public virtual onlyOwner returns (uint256) {
        return _snapshot();
    }

    /// @dev 获取当前快照id
    function getCurrentSnapshotId() internal view virtual returns (uint256) {
        return _getCurrentSnapshotId();
    }
}
