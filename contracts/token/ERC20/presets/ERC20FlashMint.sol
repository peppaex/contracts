// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../extensions/FlashMint.sol";

/**
 * @dev {ERC20} 固定总量的令牌包含闪电贷功能.
 *
 */
contract ERC20FlashMint is FlashMint {
    uint256 private _fee = 0;
    uint256 private constant _feeMax = 10000;

    /**
     * @dev 设置 {name} 和 {symbol} 的值. 同时为 `owner` 账户铸造数量为 `initialSupply` 的令牌
     * @notice 如果将fee的值大于0,将会在闪电贷完成后使令牌总量通缩,因为费用和借出的资产在归还后都将被销毁掉.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 initialSupply,
        address owner,
        uint256 fee
    ) ERC20(_name, _symbol, initialSupply, owner) {
        require(fee >= 0 && fee < _feeMax, "flash fee overflow");
        _fee = fee;
    }

    /**
     * @dev 重写闪电贷费用方法
     * @param token 贷款的令牌地址.
     * @param amount 借出的令牌数量.
     * @return 适用于相应闪电贷的费用.
     */
    function flashFee(address token, uint256 amount)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(token == address(this), "ERC20FlashMint: wrong token");
        unchecked {
            return (amount * _fee) / _feeMax;
        }
    }
}
