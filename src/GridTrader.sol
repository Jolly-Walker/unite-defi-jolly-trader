// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract GridTrader is ERC4626, IERC1271, Ownable {

    IERC20 asset2;


    // ERC4626 constructor requires ERC20 asset
    constructor(IERC20 asset, IERC20 _asset2) Ownable(msg.sender) ERC20("Name", "Sym") ERC4626(asset) {
        asset2 = _asset2;
    }

    // ERC1271: validate signatures
    function isValidSignature(bytes32 hash, bytes memory signature) public view override returns (bytes4) {
        address signer = ECDSA.recover(hash, signature);
        if (signer == owner()) {
            return 0x1626ba7e; // ERC1271 magic value for valid signature
        }
        return 0xffffffff; // invalid
    }

    function totalAssets() public view override returns (uint256) {}
}
