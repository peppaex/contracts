// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev 椭圆曲线数字签名算法 (ECDSA) 操作.
 *
 * 这些函数可用于验证消息是否由给定地址的私钥的持有者签名.
 */
library ECDSA {
    /**
     * @dev 返回使用"signature"对散列消息("hash")进行签名的地址。然后可以将此地址用于验证目的.
     *
     * `ecrecover` EVM操作码允许可塑性(非唯一)签名：
     *  此函数通过要求 `s` 值处于低半阶并且 `v` 值是 27 或 28 来拒绝它们.
     *
     * 重要提示：`hash`_必须_是验证安全的散列操作的结果：可以制作恢复到非散列数据的任意地址的签名.
     * 确保这一点的安全方法是接收原始消息的散列(否则可能太长), 然后对其调用 {toEthSignedMessageHash}.
     *
     * 签名生成文档:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // 检查签名长度
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover 获取签名参数，以及获取它们的唯一方法
            // 目前是使用汇编.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover 获取签名参数，以及获取它们的唯一方法
            // 目前是使用汇编.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    /**
     * @dev 分别接收 `r` 和 `vs` 短签名字段的 {ECDSA-recover} 的重载.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    /**
     * @dev {ECDSA-recover} 的重载，分别接收 `v`、`r` 和 `s` 签名字段.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        // EIP-2 仍然允许 ecrecover() 的签名延展性. 消除这种可能性并使签名唯一. 
        // 以太坊黄皮书 (https://ethereum.github.io/yellowpaper/paper.pdf) 中的附录 F,
        // 定义了 (301) 中 s 的有效范围：0 < s < secp256k1n ÷ 2 + 1，对于 v 在 (302): v ∈ {27, 28}.
        // 当前库中的大多数签名都会生成一个具有低半阶 s 值的唯一签名.
        //
        // 如果您的库生成可延展的签名，例如上限范围内的 s 值，
        // 请使用 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 计算新的 s 值，
        // 并将 v 从 27 翻转到 28，反之亦然。 如果您的库还为 v 生成了 0/1 而不是 27/28 的签名，请将 27 添加到 v 以接受这些可延展的签名.
        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev 返回从`hash`创建的以太坊签名消息. 
     * 这会生成对应于使用 https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC 方法签名的哈希，作为 EIP-191 的一部分.
     *
     * 参考 {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 是哈希的字节长度,
        // 由上面的类型签名强制执行
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev 返回从"domainSeparator"和"structHash"创建的以太坊签名类型数据.
     * 这会产生与使用 https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] 签名的哈希相对应的哈希
     * JSON-RPC method as part of EIP-712.
     *
     * 参考 {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}
