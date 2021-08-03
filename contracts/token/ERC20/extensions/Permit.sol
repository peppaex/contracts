// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interface/IERC20Permit.sol";
import "../ERC20.sol";
import "../../../utils/cryptography/EIP712.sol";
import "../../../utils/cryptography/ECDSA.sol";
import "../../../utils/Counters.sol";

/**
 * @dev 实现 ERC20 许可的扩展,允许通过签名进行授权, 请参阅https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * 添加 {permit} 方法，该方法可用于通过呈现帐户签名的消息来更改帐户的 ERC20 授权限额(请参阅 {IERC20-allowance}).
 * 可以不依赖"{IERC20-approve}"进行授权，令牌持有者账户不需要发送交易，因此根本不需要持有以太币.
 *
 */
abstract contract Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    /**
     * @dev 使用`name`参数初始化 {EIP712} 域分隔符，并将`version`设置为`"1"`.
     *
     * 使用与 ERC20 代币名称相同的"名称"是个好主意.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev 参考 {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _useNonce(owner),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev 参考 {IERC20Permit-nonces}.
     */
    function nonces(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _nonces[owner].current();
    }

    /**
     * @dev 参考 {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "消耗一个nonce": 返回当前值并递增.
     *
     */
    function _useNonce(address owner)
        internal
        virtual
        returns (uint256 current)
    {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}
