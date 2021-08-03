// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev ERC3156 闪电贷借款人接口, 请参考https://eips.ethereum.org/EIPS/eip-3156[ERC-3156].
 */
interface IERC3156FlashBorrower {
    /**
     * @dev 收到一个闪电贷.
     * @param initiator 贷款发起人.
     * @param token 贷款的令牌地址.
     * @param amount 借出的令牌数量.
     * @param fee 要偿还的额外令牌数量.
     * @param data 任意数据结构，旨在包含用户定义的参数.
     * @return "ERC3156FlashBorrower.onFlashLoan"的keccak256哈希
     */
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

/**
 * @dev ERC3156 闪电贷贷款方接口, 请参阅 https://eips.ethereum.org/EIPS/eip-3156[ERC-3156].
 */
interface IERC3156FlashLender {
    /**
     * @dev 可借出的货币数量.
     * @param token 贷款的令牌地址.
     * @return `token`可以被借出的数量.
     */
    function maxFlashLoan(address token) external view returns (uint256);

    /**
     * @dev 为特定贷款收取的费用.
     * @param token 贷款的令牌地址.
     * @param amount 借出的令牌数量.
     * @return 在返还的本金之上，为贷款收取的`token`金额.
     */
    function flashFee(address token, uint256 amount) external view returns (uint256);

    /**
     * @dev 启动一个闪电贷.
     * @param receiver 借贷中代币的接收者，以及回调的接收者.
     * @param token 的.
     * @param amount 借出的令牌数量.
     * @param data 任意数据结构，旨在包含用户定义的参数.
     */
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}
