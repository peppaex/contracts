// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Arrays.sol";
import "../../../utils/Counters.sol";

/**
 * @dev 该合约使用快照机制扩展了ERC20令牌. 创建快照时,会记录当时的余额和总供应量以供以后访问.
 *
 * 可用于安全地创建基于令牌余额的机制，例如去信任的股息或加权投票.
 * 在简单的实现中，可以通过重复使用来自不同账户的相同余额来执行“双花”攻击.
 * 通过使用快照来计算股息或投票权，这些攻击不再适用.
 * 也可用于创建高效的 ERC20 分叉机制.
 *
 * 快照由内部 {_snapshot} 函数创建，该函数将发出 {Snapshot} 事件并返回快照 ID.
 * 要获取快照时的总供应量，请使用快照 ID 调用函数 {totalSupplyAt}.
 * 要在快照时获取帐户余额，请使用快照 ID 和帐户地址调用 {balanceOfAt} 函数.
 *
 * NOTE: 可以通过覆盖 {_getCurrentSnapshotId} 方法来自定义快照策略.
 * 例如，让它返回`block.number` 将在每个新块开始时触发快照的创建.
 * 覆盖此函数时，请注意其结果的单调性. 非单调快照 ID 将破坏合约。
 *
 * 使用这种方法为每个块实现快照将产生巨大的gas成本. 对于节约gas的替代方案，请考虑 {ERC20Votes}.
 *
 * ==== Gas Costs
 *
 * 快照是有效的. 快照创建是_O(1)_. 从快照中检索余额或总供应量是已创建快照数量的 _O(log n)_，
 * 尽管特定帐户的 _n_ 通常会小得多，因为后续快照中的相同余额存储为单个条目.
 *
 * 由于额外的快照记录，正常的ERC20 transfer() 将增加一个恒定的gas开销.
 * 此开销仅会在紧跟在特定帐户快照之后的第一次 transfer()中产生.
 * 后续传输将具有正常成本，直到下一个快照，依此类推.
 */

abstract contract Snapshotable is ERC20 {
    // 受 Jordi Baylina 的 MiniMeToken 启发，用于记录历史余额:
    // https://github.com/Giveth/minimd/blob/ea04d950eea153a04c51fa510b068b9dded390cb/contracts/MiniMeToken.sol

    using Arrays for uint256[];
    using Counters for Counters.Counter;

    // 快照值具有id数组和与该id对应的值.
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    // 快照id单调递增，第一个值为1. id为0无效.
    Counters.Counter private _currentSnapshotId;

    /**
     * @dev 当创建由`id`标识的快照时由 {_snapshot} 发出.
     */
    event Snapshot(uint256 id);

    /**
     * @dev 创建一个新快照并返回其快照 ID.
     *
     * 触发{Snapshot}事件,并包含快照id.
     *
     * {_snapshot}函数是内部函数，您必须决定如何在外部公开它.
     * 它的使用可能仅限于一组帐户，例如使用 {AccessControl}，或者它也可能对公众开放.
     *
     * [WARNING]
     * ====
     * 虽然某些信任最小化机制（例如分叉）需要调用 {_snapshot} 的开放方式，但您必须考虑到它可能被攻击者以两种方式使用.
     *
     * 首先，它可以用来增加从快照中检索值的成本，尽管它会呈对数增长，从而使这种攻击长期无效.
     * 其次，它可以用于针对特定账户并以上面gas成本部分中指定的方式为他们增加ERC20转账的成本.
     *
     * 我们还没有测量实际数字, 如果您对此感兴趣，请与我们联系.
     * ====
     */
    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }

    /**
     * @dev 获取当前快照id
     */
    function _getCurrentSnapshotId() internal view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }

    /**
     * @dev 根据`snapshotId`检索`account`的余额.
     */
    function balanceOfAt(address account, uint256 snapshotId)
        public
        view
        virtual
        returns (uint256)
    {
        (bool snapshotted, uint256 value) = _valueAt(
            snapshotId,
            _accountBalanceSnapshots[account]
        );

        return snapshotted ? value : balanceOf[account];
    }

    /**
     * @dev 根据 `snapshotId` 检索总供应量.
     */
    function totalSupplyAt(uint256 snapshotId)
        public
        view
        virtual
        returns (uint256)
    {
        (bool snapshotted, uint256 value) = _valueAt(
            snapshotId,
            _totalSupplySnapshots
        );

        return snapshotted ? value : totalSupply;
    }

    // 在修改值之前更新余额和/或总供应快照.
    // 这是在 _beforeTokenTransfer 钩子中实现的，该钩子为 _mint、_burn 和 _transfer 操作执行.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            // 铸造
            _updateAccountSnapshot(to);
            _updateTotalSupplySnapshot();
        } else if (to == address(0)) {
            // 销毁
            _updateAccountSnapshot(from);
            _updateTotalSupplySnapshot();
        } else {
            // 转移
            _updateAccountSnapshot(from);
            _updateAccountSnapshot(to);
        }
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private
        view
        returns (bool, uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(
            snapshotId <= _getCurrentSnapshotId(),
            "ERC20Snapshot: nonexistent id"
        );

        // 当查询到一个有效的快照时，有三种可能:
        //  a) 拍摄快照后未修改查询的值. 因此，合约从未为此id创建快照条目，
        //  并且所有存储的快照id都小于请求的. 这个id对应的值是当前的.
        //  b) 获取快照后修改了查询的值. 因此，将会有一个带有请求id的条目，它的值就是要返回的值.
        //  c) 在请求的快照之后创建了更多快照，并且稍后修改了查询的值.
        //  请求的id将没有条目：与其对应的值是大于请求的最小快照id的值.
        //
        // 总之，我们需要在数组中找到一个元素，如果没有找到则返回较大的最小值的索引，
        // 除非该值不存在(例如，当所有值都较小时)Arrays.findUpperBound 正是这样做的.

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf[account]);
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply);
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue)
        private
    {
        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids)
        private
        view
        returns (uint256)
    {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}
