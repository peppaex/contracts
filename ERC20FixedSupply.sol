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


// File contracts/token/ERC20/interface/IERC20Metadata.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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


// File contracts/token/ERC20/ERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev {IERC20} 接口的实现.
 *
 * 我们的合约函数在失败时会 `revert` 而不是返回 `false`.这种行为是传统的,并且
 * 与ERC20应用程序的期望没有冲突.
 *
 * 此外，在调用 {transferFrom} 时会发出 {Approval} 事件.这允许应用程序仅通过
 * 监听这个事件来重建所有帐户的限额。 EIP的其他实现可能不会发出这些事件，因为规范
 * 中并没有要求必须这样做
 */
contract ERC20 is IERC20Metadata {
    /// @dev 余额映射(地址=>数额)
    mapping(address => uint256) public override balanceOf;
    /// @dev 授权映射(授权地址=>被授权地址=>数额)
    mapping(address => mapping(address => uint256)) public override allowance;
    /// @dev 总量
    uint256 public override totalSupply;
    /// @dev 名称
    string public override name;
    /// @dev 符号
    string public override symbol;
    /// @dev 精度 {decimals} 精度的默认值为18,如果需要设置为不同的值,请在这里重写.
    uint8 public constant override decimals = 18;

    /**
     * @dev 设置 {name} 和 {symbol} 的值. 同时为 `owner` 账户铸造数量为 `initialSupply` 的令牌
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 initialSupply,
        address owner
    ) {
        name = _name;
        symbol = _symbol;
        if (initialSupply > 0) _mint(owner, initialSupply);
    }

    /**
     * @dev 参考 {IERC20-transfer}.
     *
     * 要求:
     *
     * - `recipient` 不能为0地址.
     * - 调用者的账户余额需要大于等于`amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * 要求:
     *
     * - `spender` 不能为0地址.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev 参考 {IERC20-transferFrom}.
     *
     * 触发一个 {Approval} 事件,是因为授权数额更新. 这并不是EIP所必须的. 参考{ERC20}前面的注释.
     *
     * 要求:
     *
     * - `sender` 和 `recipient`不能为0地址.
     * - `sender` 账户的余额需要大于等于 `amount`.
     * - 调用者需要拥有 `sender` 授权的大于等于 `amount` 的令牌数量.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = allowance[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev 从调用者账户转移`amount`数量的令牌到`recipient`账户.
     *
     * 此内部函数等效于 {transfer}，可用于例如:转移收税，通缩机制等。
     *
     * 触发一个 {Transfer} 事件
     *
     * 要求:
     *
     * - `sender`不能为0地址.
     * - `recipient`不能为0地址.
     * - `sender` 账户的余额需要大于等于 `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = balanceOf[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            balanceOf[sender] = senderBalance - amount;
        }
        balanceOf[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev 创建 `amount` 数量的令牌并把他们分配到 `account` 账户中, 同时增加总供应量.
     *
     * 触发一个 {Transfer} 事件, `from` 设置为0地址.
     *
     * 要求:
     *
     * - `account`不能为0地址.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev 从 `account`账户中销毁 `amount` 数量的令牌, 同时减少总供应量.
     *
     * 触发一个 {Transfer} 事件, `to` 设置为0地址.
     *
     * 要求:
     *
     * - `account`不能为0地址.
     * - `account` 账户的余额需要大于等于 `amount`.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = balanceOf[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            balanceOf[account] = accountBalance - amount;
        }
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev `owner`将数额为`amount`的令牌授权给`spender`.
     *
     * 此内部函数等效于`approve`，可用于例如: 为某些子系统自动设置授权额度。
     *
     * 触发一个 {Approval} 事件.
     *
     * 要求:
     *
     * - `owner`不能为0地址.
     * - `spender`不能为0地址.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev 在任何令牌转移之前调用的钩子,包括铸造和销毁.
     *
     * 调用条件:
     *
     * - 如果`from`和`to`都不是0地址, 调用发生在`from`即将转移数量为`amount`的令牌到`to`账户之前
     * - 如果`from`是0地址, 调用发生在`amount`数量的令牌即将铸造给`to`账户之前.
     * - 如果`to`是0地址, 调用发生在`amount`数量的令牌即将从`from`的账户销毁之前.
     * - `from`和`to`永远不能都是0地址.
     *
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * 调用条件:
     *
     * - 如果`from`和`to`都不是0地址, 调用发生在`from`已经转移数量为`amount`的令牌到`to`账户之后
     * - 如果`from`是0地址, 调用发生在`amount`数量的令牌已经铸造给`to`账户之后.
     * - 如果`to`是0地址, 调用发生在`amount`数量的令牌已经从`from`的账户销毁之后.
     * - `from`和`to`永远不能都是0地址.
     *
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// File contracts/token/ERC20/presets/ERC20FixedSupply.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev {ERC20} 固定总量的令牌.
 *
 */
contract ERC20FixedSupply is ERC20 {
    /**
     * @dev 设置 {name} 和 {symbol} 的值. 同时为 `owner` 账户铸造数量为 `initialSupply` 的令牌
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 initialSupply,
        address owner
    ) ERC20(_name, _symbol, initialSupply, owner) {}
}
