// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Solidity 语言中缺少标准数学实用程序.
 */
library Math {
    /**
     * @dev 返回两个数字中的最大值.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev 返回两个数字中的最小值.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev 返回两个数字的平均值, 结果向下取整.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev 返回两个数字相除的结果,并向上取整
     *
     * 与 `/` 的不同之处在于它是向下取整的
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b + (a % b == 0 ? 0 : 1);
    }
}
