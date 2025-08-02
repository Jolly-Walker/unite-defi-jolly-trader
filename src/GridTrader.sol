// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import {ERC4626, IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ChainlinkOracleLib} from "./Library/ChainlinkOracleLib.sol";
import {IGridTrader} from "./Interfaces/IGridTrader.sol";

contract GridTrader is ERC4626, IERC1271, Ownable, IGridTrader {

    IERC20 asset2;
    address chainlinkAddress; // price feed address for asset/asset2 pair
    
    GridLine[] public buyTargets;
    GridLine[] public sellTargets;

    constructor(IERC20 asset, IERC20 _asset2, address _chainLinkAddress) Ownable(msg.sender) ERC20("Name", "Sym") ERC4626(asset) {
        asset2 = _asset2;
        chainlinkAddress = _chainLinkAddress;
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

}
