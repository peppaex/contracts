// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";

/**
 * @dev ERC20标准接口的可选元数据函数
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev 返回令牌名称.
     */
    function name() external view returns (string memory);

    /**
     * @dev 返回令牌符号.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev 返回令牌的精度.
     */
    function decimals() external view returns (uint8);
}