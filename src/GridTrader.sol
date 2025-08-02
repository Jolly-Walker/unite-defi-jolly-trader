// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import {ERC4626, IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {ChainlinkOracleLib} from "./Library/ChainlinkOracleLib.sol";
import {IGridTrader} from "./Interfaces/IGridTrader.sol";

contract GridTrader is ERC4626, IERC1271, Ownable, IGridTrader {

    using SafeERC20 for IERC20;
    using Math for uint256;

    IERC20 public asset2;
    address public chainlinkAddress; // price feed address for asset/asset2 pair
    address public oneInchLOP;
    
    GridLine[] public buyTargets;
    GridLine[] public sellTargets;

    // index of grid to trade
    uint256 public buyGrid;

    // index of grid to trade
    uint256 public sellGrid;

    constructor(IERC20 asset, IERC20 _asset2, address _chainLinkAddress, address _oneInchLOP) Ownable(msg.sender) ERC20("Name", "Sym") ERC4626(asset) {
        asset2 = _asset2;
        chainlinkAddress = _chainLinkAddress;
        oneInchLOP = _oneInchLOP;
    }

    // ERC1271: validate signatures
    function isValidSignature(bytes32 hash, bytes memory signature) public view override returns (bytes4) {
        address signer = ECDSA.recover(hash, signature);
        if (signer == owner()) {
            return 0x1626ba7e; // ERC1271 magic value for valid signature
        }
        return 0xffffffff; // invalid
    }

    function totalAssets() public view override returns (uint256) {
        uint256 asset2Price = ChainlinkOracleLib.getPrice(chainlinkAddress);
        uint256 asset2Value = asset2.balanceOf(address(this)) * asset2Price;
        return IERC20(asset()).balanceOf(address(this)) + asset2Value;
    }

    function approveOneInchLOP() external onlyOwner {
        IERC20(asset()).safeIncreaseAllowance(oneInchLOP, 100_000000); // 100 USDT
        asset2.safeIncreaseAllowance(oneInchLOP, 1000000); // 0.01 WBTC
    }

    // if its a buy order, increment buy grid, reset sell grid
    // if its a sell order, increment sell grid, reset buy grid
    function postInteraction(Order memory order, bytes memory extension, bytes32 orderHash, address taker, uint256 makingAmount, uint256 takingAmount, uint256 remainingMakingAmount, bytes memory extraData) external {
    
    }

    function setUpGrids(GridLine[] memory _buys, GridLine[] memory _sells) external onlyOwner {
        // Clean up existing grids
        delete buyTargets;
        delete sellTargets;
        buyGrid = 0;
        sellGrid = 0;

        // Set new grids
        for (uint256 i = 0; i < _buys.length; i++) {
            buyTargets.push(_buys[i]);
        }

        for (uint256 i = 0; i < _sells.length; i++) {
            sellTargets.push(_sells[i]);
        }

    }

    function getBuyAmount() public view returns (uint256) {
        if (buyGrid >= buyTargets.length) {
            return 0;
        }
        return IERC20(asset()).balanceOf(address(this)).mulDiv(buyTargets[buyGrid].portion, 10000);
    }

    function getBuyReceiveAmount() public view returns (uint256) {
        uint256 buyAmount = getBuyAmount();

        if (buyAmount == 0) return 0;
        return buyAmount * buyTargets[buyGrid].price;
    }

    function getSellAmount() public view returns (uint256) {
        if (sellGrid >= sellTargets.length) {
            return 0;
        }
        return asset2.balanceOf(address(this)).mulDiv(sellTargets[sellGrid].portion, 10000);
    }

function getSellReceiveAmount() public view returns (uint256) {
        uint256 sellAmount = getSellAmount();

        if (sellAmount == 0) return 0;
        return sellAmount * sellTargets[sellGrid].price;
    }


}
