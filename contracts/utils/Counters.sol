// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title 计数器
 * @author Matt Condon (@shrugs)
 * @dev 提供只能递增、递减或重置的计数器. 这可以用于例如跟踪映射中的元素数量、创建ERC721的id或计算请求id.
 *
 * 在实现的合约中声明: `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // 库的用户永远不应直接访问此变量：交互必须限于库的功能.
        // 从 Solidity v0.5.2 开始，虽然有人提议添加此功能，但无法强制执行此操作
        // 请参阅 https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    /// @dev 获取当前值
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    /// @dev 加一操作
    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    /// @dev 减一操作
    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    /// @dev 重置
    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}