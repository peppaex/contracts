= ERC 20


This set of interfaces, contracts, and utilities are all related to the https://eips.ethereum.org/EIPS/eip-20[ERC20 Token Standard].

TIP: For an overview of ERC20 tokens and a walk through on how to create a token contract read our xref:ROOT:erc20.adoc[ERC20 guide].

There a few core contracts that implement the behavior specified in the EIP:

* {IERC20}: the interface all ERC20 implementations should conform to.
* {IERC20Metadata}: the extended ERC20 interface including the <<ERC20-name,`name`>>, <<ERC20-symbol,`symbol`>> and <<ERC20-decimals,`decimals`>> functions.
* {ERC20}: the implementation of the ERC20 interface, including the <<ERC20-name,`name`>>, <<ERC20-symbol,`symbol`>> and <<ERC20-decimals,`decimals`>> optional standard extension to the base interface.

Additionally there are multiple custom extensions, including:

* {ERC20FixedSupply}: 固定总量的令牌
* {ERC20Mintable}: 可以增发的令牌
* {ERC20Burnable}: 可以销毁自己的令牌.
* {ERC20Snapshot}: 有效存储过去的令牌余额，以便以后随时查询.
* {ERC20Permit}: 节省gas的授权方法 (ERC2612标准).
* {ERC20FlashMint}: 支持闪电贷 (ERC3156标准).
* {ERC20Votes}: 支持投票和投票委托.
* {ERC20VotesComp}: 支持投票和投票委托（兼容 Compound 的 token，有 uint96 限制）.
* {ERC20Wrapper}: 包装器创建一个由另一个 ERC20 支持的 ERC20，具有存款和取款方法。 与 {ERC20Votes} 结合使用很有用.
* {ERC20SaveToken} 拯救令牌的方法

Finally, there are some utilities to interact with ERC20 contracts in various ways.

* {SafeERC20}: 对接口进行包装,无需处理返回的布尔值.
* {TokenTimelock}: 为受益人持有代币直到指定时间.

The following related EIPs are in draft status.

- {ERC20Permit}

NOTE: This core set of contracts is designed to be unopinionated, allowing developers to access the internal functions in ERC20 (such as <<ERC20-_mint-address-uint256-,`_mint`>>) and expose them as external functions in the way they prefer. On the other hand, xref:ROOT:erc20.adoc#Presets[ERC20 Presets] (such as {ERC20PresetMinterPauser}) are designed using opinionated patterns to provide developers with ready to use, deployable contracts.

== Core

{{IERC20}}

{{IERC20Metadata}}

{{ERC20}}

== Extensions

{{ERC20Burnable}}

{{ERC20Capped}}

{{ERC20Pausable}}

{{ERC20Snapshot}}

{{ERC20Votes}}

{{ERC20VotesComp}}

{{ERC20Wrapper}}

{{ERC20FlashMint}}

== Draft EIPs

The following EIPs are still in Draft status. Due to their nature as drafts, the details of these contracts may change and we cannot guarantee their xref:ROOT:releases-stability.adoc[stability]. Minor releases of OpenZeppelin Contracts may contain breaking changes for the contracts in this directory, which will be duly announced in the https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/CHANGELOG.md[changelog]. The EIPs included here are used by projects in production and this may make them less likely to change significantly.

{{ERC20Permit}}

== Presets

These contracts are preconfigured combinations of the above features. They can be used through inheritance or as models to copy and paste their source code.

{{ERC20PresetMinterPauser}}

{{ERC20PresetFixedSupply}}

== Utilities

{{SafeERC20}}

{{TokenTimelock}}