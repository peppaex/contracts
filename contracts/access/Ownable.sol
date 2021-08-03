// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev 提供基本访问控制机制的合约模块，其中有一个帐户`owner`可以被授予对特定功能的独占访问权限
 *
 * 默认情况下，所有者帐户将是部署合约的帐户。 这可以稍后通过 {transferOwnership} 更改.
 *
 * 该模块通过继承使用。 它将提供修饰符`onlyOwner`，它可以应用于您的函数以限制它们对所有者的使用.
 */
abstract contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev 初始化合约，将部署者设置为初始所有者.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev 如果由所有者以外的任何帐户调用，则抛出异常.
     *
     * 通过此修改器限制函数的使用权限
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev 撤销合约的所有者, 此后将无法再调用 `onlyOwner` 函数. 此方法只能由当前所有者调用.
     *
     * NOTE: 放弃所有权将使合约没有所有者，任何仅对所有者可用的功能都将永远无法使用.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev 将合约的所有权转移到新帐户(`newOwner`). 只能由当前所有者调用.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}