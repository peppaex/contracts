pragma solidity ^0.8.0;

import "./interface/ISwapFactory.sol";
import "./SwapPair.sol";

contract Pair is SwapPair {
    string private constant _name = "swap pair";
    string private constant _symbol = "LP";

    constructor() SwapPair(_name, _symbol) {
        (token0, token1, swapFee) = ISwapFactory(msg.sender).parameters();
        _initialize(token0, token1, swapFee);
    }
}

contract SwapFactory is ISwapFactory {
    address public override feeTo;
    address public override feeToSetter;

    bytes32 public constant override INIT_PAIR_CODE_HASH =
        keccak256(abi.encodePacked(type(Pair).creationCode));
    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;

    struct Parameters {
        address token0;
        address token1;
        uint8 swapFee;
    }
    Parameters public override parameters;

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view override returns (uint256) {
        return allPairs.length;
    }

    function createPair(
        address tokenA,
        address tokenB,
        uint8 swapFee
    ) external override returns (address pair) {
        require(tokenA != tokenB, "SwapFactory: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "SwapFactory: ZERO_ADDRESS");
        require(
            getPair[token0][token1] == address(0),
            "SwapFactory: PAIR_EXISTS"
        );

        parameters = Parameters({
            token0: token0,
            token1: token1,
            swapFee: swapFee
        });

        pair = address(new Pair{salt: keccak256(abi.encode(token0, token1))}());
        delete parameters;

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external override {
        require(msg.sender == feeToSetter, "SwapFactory: FORBIDDEN");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external override {
        require(msg.sender == feeToSetter, "SwapFactory: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }
}
