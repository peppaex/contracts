// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Permit.sol";
import "../../../utils/math/Math.sol";
import "../../../utils/math/SafeCast.sol";
import "../../../utils/cryptography/ECDSA.sol";

/**
 * @dev 扩展ERC20以支持类似Compound的投票和委托. 这个版本比Compound的更通用, 支持高达2^224^-1的令牌供应, 而COMP限制为2^96^-1.
 *
 * NOTE: 如果需要精确的COMP兼容性, 请使用此模块的{ERC20VotesComp}变体.
 *
 * 此扩展程序保留每个帐户投票权的历史记录(检查点).
 * 可以通过直接调用{delegate}函数或通过提供与{delegateBySig}一起使用的签名来委托投票权.
 * 可以通过公共访问器{getVotes}和{getPastVotes}查询投票权.
 *
 * 默认情况下, 令牌余额不考虑投票权. 这使得转移更容易. 缺点是它需要用户委托给自己, 以激活检查点并跟踪他们的投票权.
 * 可以通过覆盖{delegates}函数轻松启用自委托. 但是请记住, 这将显着增加转移的基础gas成本.
 */
abstract contract Votes is Permit {
    struct Checkpoint {
        uint32 fromBlock;
        uint224 votes;
    }

    bytes32 private constant _DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => address) private _delegates;
    mapping(address => Checkpoint[]) private _checkpoints;
    Checkpoint[] private _totalSupplyCheckpoints;

    /**
     * @dev 当帐户更改其委托时发出.
     */
    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    /**
     * @dev 当令牌转移或委托变更导致账户投票权发生变化时发出.
     */
    event DelegateVotesChanged(
        address indexed delegate,
        uint256 previousBalance,
        uint256 newBalance
    );

    /**
     * @dev 获取 `account` 的 `pos`-th 检查点.
     */
    function checkpoints(address account, uint32 pos)
        public
        view
        virtual
        returns (Checkpoint memory)
    {
        return _checkpoints[account][pos];
    }

    /**
     * @dev 获取`account`检查点的数量.
     */
    function numCheckpoints(address account)
        public
        view
        virtual
        returns (uint32)
    {
        return SafeCast.toUint32(_checkpoints[account].length);
    }

    /**
     * @dev 获取`account`当前委托给的地址.
     */
    function delegates(address account) public view virtual returns (address) {
        return _delegates[account];
    }

    /**
     * @dev 获取`account`当前票余额
     */
    function getVotes(address account) public view returns (uint256) {
        uint256 pos = _checkpoints[account].length;
        return pos == 0 ? 0 : _checkpoints[account][pos - 1].votes;
    }

    /**
     * @dev 在`blockNumber`末尾检索`account`的投票数.
     *
     * 要求:
     *
     * - `blockNumber` 必须是已经挖出的
     */
    function getPastVotes(address account, uint256 blockNumber)
        public
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "ERC20Votes: block not yet mined");
        return _checkpointsLookup(_checkpoints[account], blockNumber);
    }

    /**
     * @dev 检索`blockNumber`末尾的`totalSupply`. 注意, 这个值是所有余额的总和, 但不是所有委托投票的总和!
     *
     * 要求:
     *
     * - `blockNumber` 必须是已经挖出的
     */
    function getPastTotalSupply(uint256 blockNumber)
        public
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "ERC20Votes: block not yet mined");
        return _checkpointsLookup(_totalSupplyCheckpoints, blockNumber);
    }

    /**
     * @dev 在(排序的)检查点列表中查找值.
     */
    function _checkpointsLookup(Checkpoint[] storage ckpts, uint256 blockNumber)
        private
        view
        returns (uint256)
    {
        // 我们运行一个二分搜索来寻找在 `blockNumber` 之后采取的最早检查点.
        //
        // 在循环期间，想要的检查点的索引保持在 [low-1, high) 范围内.
        // 在每次迭代中，"low"或"high"移向范围的中间以保持不变.
        // - 如果中间检查点在`blockNumber`之后，我们在[low, mid)
        // - 如果中间检查点在或等于`blockNumber`之前，我们在[mid+1, high)
        // 一旦我们达到一个值(low == high), 我们就会在索引 high-1 处找到正确的检查点, 如果不是越界(在这种情况下，我们过去看得太远了，结果是 0).
        // Note 如果有最新的检查点正正是`blockNumber`, 我们最终是过去的数组的末尾的指数, 所以我们在技术上没有找到后`blockNumber`一个检查点, 但它的结果是一样的.
        uint256 high = ckpts.length;
        uint256 low = 0;
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (ckpts[mid].fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        return high == 0 ? 0 : ckpts[high - 1].votes;
    }

    /**
     * @dev 将调用者的投票委托给被委托人.
     */
    function delegate(address delegatee) public virtual {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @dev 通过签名将委托人的投票委托给被委托人
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(block.timestamp <= expiry, "ERC20Votes: signature expired");
        address signer = ECDSA.recover(
            _hashTypedDataV4(
                keccak256(
                    abi.encode(_DELEGATION_TYPEHASH, delegatee, nonce, expiry)
                )
            ),
            v,
            r,
            s
        );
        require(nonce == _useNonce(signer), "ERC20Votes: invalid nonce");
        return _delegate(signer, delegatee);
    }

    /**
     * @dev 最大的令牌供应. 默认为 `type(uint224).max` (2^224^ - 1).
     */
    function _maxSupply() internal view virtual returns (uint224) {
        return type(uint224).max;
    }

    /**
     * @dev 对铸造方法增加后的总供应量的快照.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        super._mint(account, amount);
        require(
            totalSupply <= _maxSupply(),
            "ERC20Votes: total supply risks overflowing votes"
        );

        _writeCheckpoint(_totalSupplyCheckpoints, _add, amount);
    }

    /**
     * @dev 对销毁方法增加减少后的总供应量的快照.
     */
    function _burn(address account, uint256 amount) internal virtual override {
        super._burn(account, amount);

        _writeCheckpoint(_totalSupplyCheckpoints, _subtract, amount);
    }

    /**
     * @dev 转移代币时移动投票权.
     *
     * Emits a {DelegateVotesChanged} event.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._afterTokenTransfer(from, to, amount);

        _moveVotingPower(delegates(from), delegates(to), amount);
    }

    /**
     * @dev 将`delegator`的委托更改为 `delegatee`.
     *
     * 触发事件 {DelegateChanged} 和 {DelegateVotesChanged}.
     */
    function _delegate(address delegator, address delegatee) internal virtual {
        address currentDelegate = delegates(delegator);
        uint256 delegatorBalance = balanceOf[delegator];
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveVotingPower(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveVotingPower(
        address src,
        address dst,
        uint256 amount
    ) private {
        if (src != dst && amount > 0) {
            if (src != address(0)) {
                (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(
                    _checkpoints[src],
                    _subtract,
                    amount
                );
                emit DelegateVotesChanged(src, oldWeight, newWeight);
            }

            if (dst != address(0)) {
                (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(
                    _checkpoints[dst],
                    _add,
                    amount
                );
                emit DelegateVotesChanged(dst, oldWeight, newWeight);
            }
        }
    }

    function _writeCheckpoint(
        Checkpoint[] storage ckpts,
        function(uint256, uint256) view returns (uint256) op,
        uint256 delta
    ) private returns (uint256 oldWeight, uint256 newWeight) {
        uint256 pos = ckpts.length;
        oldWeight = pos == 0 ? 0 : ckpts[pos - 1].votes;
        newWeight = op(oldWeight, delta);

        if (pos > 0 && ckpts[pos - 1].fromBlock == block.number) {
            ckpts[pos - 1].votes = SafeCast.toUint224(newWeight);
        } else {
            ckpts.push(
                Checkpoint({
                    fromBlock: SafeCast.toUint32(block.number),
                    votes: SafeCast.toUint224(newWeight)
                })
            );
        }
    }

    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }
}
