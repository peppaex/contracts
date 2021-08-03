// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev 与数组类型相关的函数集合.
 */
library Arrays {
    /**
     * @dev 搜索已排序的 `array` 并返回包含大于或等于 `element` 的值的第一个索引.
     * 如果不存在这样的索引(即数组中的所有值都严格小于`element`)，则返回数组长度.
     * 时间复杂度 O(log n).
     *
     * `array` 应按升序排序，并且不包含重复元素.
     */
    function findUpperBound(uint256[] storage array, uint256 element)
        internal
        view
        returns (uint256)
    {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note mid 总是严格小于 high (即它将是一个有效的数组索引)
            // 因为 Math.average 向下舍入 (它使用截断进行整数除法).
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // 此时`low`是唯一的上限.我们将返回包含上限.
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}
