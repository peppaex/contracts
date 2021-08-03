// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] 是对类型化结构化数据进行散列和签名的标准.
 *
 * Solidity中不能实现EIP中规定的通用编码，因此这个合约没有实现编码本身. 协议需要实现特定于类型的编码
 * 他们需要在他们的合约中使用 `abi.encode` 和 `keccak256` 的组合.
 *
 * 该合约实现了EIP712域分隔符({_domainSeparatorV4})，用作编码的一部分方案，
 * 以及编码的最后一步以获得消息摘要，然后通过 ECDSA 签名({_hashTypedDataV4}) 
 *
 * 域分隔符的实现旨在尽可能高效，同时仍能正确更新用于防止对链的最终分叉进行重放攻击的链ID。
 *
 * NOTE: 该合约实现了称为"v4"的编码版本，由 JSON RPC 方法实现
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // 将域分隔符缓存为不可变值，但也存储其对应的链id，以便在链id更改时使缓存的域分隔符无效.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev 初始化域分隔符和参数缓存.
     *
     * `name` 和 `version` 的含义在
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: 签名域的用户可读名称，即 DApp 或协议的名称.
     * - `version`: 签名域的当前主要版本.
     *
     * NOTE: 这些参数不能更改，除非通过可升级合约.
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev 返回当前链的域分隔符.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev 返回 https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], 该函数返回该域的完全编码的 EIP712 消息的哈希值
     *
     * 该散列可以与 {ECDSA-recover} 一起使用以获取消息的签名者。例如:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}
