// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev ERC20 许可证扩展的接口允许通过签名进行批准，如定义https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * 添加 {permit} 方法，该方法可用于通过呈现帐户签名的消息来更改帐户的 ERC20 限额（请参阅 {IERC20-allowance}）.
 * 由于不依赖于 {IERC20-approve}，代币持有者账户不需要发送交易，因此根本不需要持有以太币.
 */
interface IERC20Permit {
    /**
     * @dev 将`value`设置为`spender`对`owner`的令牌的授权，通过`owner`的签名批准.
     *
     * 重要提示：{IERC20-approve} 与交易顺序相关的相同问题也适用于此处.
     *
     * 触发 {Approval} 事件.
     *
     * 要求:
     *
     * - `spender` 不能是0地址.
     * - `deadline` 必须是未来的时间戳.
     * - `v`, `r` 和 `s` 必须是由`owner`发出的有效的 `secp256k1` 的签名
     * 通过 EIP712-formatted 函数参数.
     * - 签名必须使用 ``owner`` 的当前 nonce (参考 {nonces}).
     *
     * 有关签名格式的更多信息，请参阅
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev 返回`owner`的当前nonce. 每当为{permit}生成签名时，都必须包含此值.
     *
     * 每次成功调用 {permit} 都会将"owner"的随机数加一. 这可以防止签名被多次使用.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev 返回在 {permit} 的签名编码中使用的域分隔符，如 {EIP712} 所定义.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
