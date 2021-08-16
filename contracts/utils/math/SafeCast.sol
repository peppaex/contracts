// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev 封装了 Solidity 的 uintXX/intXX 转换运算符，并添加了溢出检查.
 *
 * 在 Solidity 中从 uint256/int256 向下转换不会在溢出时报错.
 * 这很容易导致漏洞利用或错误, 因为开发人员通常认为溢出会引发错误.
 * "SafeCast"会在此类操作溢出时恢复事务.
 *
 * 使用这个库而不是未经检查的操作可以消除一整类错误, 因此建议始终使用它.
 *
 * 可以与 {SafeMath} 和 {SignedSafeMath} 结合使用,
 * 通过对 `uint256` 和 `int256` 执行所有数学运算然后向下转换，将其扩展到更小的类型.
 */
library SafeCast {
    /**
     * @dev 从uint256返回向下转换的uint224,在溢出时恢复(当输入大于最大 uint224 时).
     *
     * 对应Solidity的`uint224`操作符.
     *
     * 要求:
     *
     * - 输入值必须为224位
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(
            value <= type(uint224).max,
            "SafeCast: value doesn't fit in 224 bits"
        );
        return uint224(value);
    }

    /**
     * @dev 从 uint128 返回向下转换的 uint256, 在溢出时恢复(当输入大于最大 uint128 时).
     *
     * 对应Solidity的`uint128`操作符.
     *
     * 要求:
     *
     * - 输入值必须为128位
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(
            value <= type(uint128).max,
            "SafeCast: value doesn't fit in 128 bits"
        );
        return uint128(value);
    }

    /**
     * @dev 从 uint96 返回向下转换的 uint256, 在溢出时恢复(当输入大于最大 uint96 时).
     *
     * 对应Solidity的`uint96`操作符.
     *
     * 要求:
     *
     * - 输入值必须为96位
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(
            value <= type(uint96).max,
            "SafeCast: value doesn't fit in 96 bits"
        );
        return uint96(value);
    }

    /**
     * @dev 从 uint64 返回向下转换的 uint256, 在溢出时恢复(当输入大于最大 uint64 时).
     *
     * 对应Solidity的`uint64`操作符.
     *
     * 要求:
     *
     * - 输入值必须为64位
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(
            value <= type(uint64).max,
            "SafeCast: value doesn't fit in 64 bits"
        );
        return uint64(value);
    }

    /**
     * @dev 从 uint32 返回向下转换的 uint256, 在溢出时恢复(当输入大于最大 uint32 时).
     *
     * 对应Solidity的`uint32`操作符.
     *
     * 要求:
     *
     * - 输入值必须为32位
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(
            value <= type(uint32).max,
            "SafeCast: value doesn't fit in 32 bits"
        );
        return uint32(value);
    }

    /**
     * @dev 从 uint16 返回向下转换的 uint256, 在溢出时恢复(当输入大于最大 uint16 时).
     *
     * 对应Solidity的`uint16`操作符.
     *
     * 要求:
     *
     * - 输入值必须为16位
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(
            value <= type(uint16).max,
            "SafeCast: value doesn't fit in 16 bits"
        );
        return uint16(value);
    }

    /**
     * @dev 从 uint8 返回向下转换的 uint256, 在溢出时恢复(当输入大于最大 uint8 时).
     *
     * 对应Solidity的`uint8`操作符.
     *
     * 要求:
     *
     * - 输入值必须为8位.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(
            value <= type(uint8).max,
            "SafeCast: value doesn't fit in 8 bits"
        );
        return uint8(value);
    }

    /**
     * @dev 将有符号 int256 转换为无符号 uint256.
     *
     * 要求:
     *
     * - 输入必须大于或等于0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev 从 int256 返回向下转换的 int128, 在溢出时恢复(当输入小于最小int128或大于最大int128时).
     *
     * 对应Solidity的`int128`操作符.
     *
     * 要求:
     *
     * - 输入值必须为128位
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(
            value >= type(int128).min && value <= type(int128).max,
            "SafeCast: value doesn't fit in 128 bits"
        );
        return int128(value);
    }

    /**
     * @dev 从 int256 返回向下转换的 int64, 在溢出时恢复(当输入小于最小int64或大于最大int64时).
     *
     * 对应Solidity的`int64`操作符.
     *
     * 要求:
     *
     * - 输入值必须为64位
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(
            value >= type(int64).min && value <= type(int64).max,
            "SafeCast: value doesn't fit in 64 bits"
        );
        return int64(value);
    }

    /**
     * @dev 从 int256 返回向下转换的 int32, 在溢出时恢复(当输入小于最小int32或大于最大int32时).
     *
     * 对应Solidity的`int32`操作符.
     *
     * 要求:
     *
     * - 输入值必须为32位
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(
            value >= type(int32).min && value <= type(int32).max,
            "SafeCast: value doesn't fit in 32 bits"
        );
        return int32(value);
    }

    /**
     * @dev 从 int256 返回向下转换的 int16, 在溢出时恢复(当输入小于最小int16或大于最大int16时).
     *
     * 对应Solidity的`int16`操作符.
     *
     * 要求:
     *
     * - 输入值必须为16位
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(
            value >= type(int16).min && value <= type(int16).max,
            "SafeCast: value doesn't fit in 16 bits"
        );
        return int16(value);
    }

    /**
     * @dev 从 int256 返回向下转换的 int8, 在溢出时恢复(当输入小于最小int8或大于最大int8时).
     *
     * 对应Solidity的`int8`操作符.
     *
     * 要求:
     *
     * - 输入值必须为8位.
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(
            value >= type(int8).min && value <= type(int8).max,
            "SafeCast: value doesn't fit in 8 bits"
        );
        return int8(value);
    }

    /**
     * @dev 将无符号 uint256 转换为有符号 int256.
     *
     * 要求:
     *
     * - 输入必须小于或等于maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: 下面的不安全转换是可以的, 因为`type(int256).max`保证是正的
        require(
            value <= uint256(type(int256).max),
            "SafeCast: value doesn't fit in an int256"
        );
        return int256(value);
    }
}
