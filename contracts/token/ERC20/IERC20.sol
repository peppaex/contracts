// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev 在以太坊改进建议EIP中定义的ERC20接口.
 */
interface IERC20 {
    /**
     * @dev 返回现有的令牌总量.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev 返回`account`账户拥有的令牌总量.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev 从调用者账户转移`amount`数量的令牌到`recipient`账户.
     *
     * 返回一个布尔值表示操作是否成功.
     *
     * 触发一个 {Transfer} 事件.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev 返回`owner`允许`spender`代表其在{transferFrom}中可花费的剩余令牌数量,
     *
     * 当{approve} 或 {transferFrom} 被调用后可以修改这个数量.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev 调用者将数额为`amount`的令牌授权给`spender`
     *
     * 返回一个布尔值表示操作是否成功.
     *
     * 触发一个 {Approval} 事件.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev 使用授权机制从`sender`转移数量为`amount`的令牌到`recipient`账户,
     * `amount`数量从调用者的授权数额中扣除
     *
     * 返回一个布尔值表示操作是否成功.
     *
     * 触发一个 {Transfer} 事件.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev 当`value`数量的令牌从`from`转移到`to`账户时触发
     * Note `value`不能为0.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev 当`owner`通过调用{approve}给予`spender`一个授权时触发,`value`是一个新的授权数额
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
