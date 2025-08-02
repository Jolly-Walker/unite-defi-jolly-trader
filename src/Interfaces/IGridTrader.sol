// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import {MakerTraitsLib, MakerTraits} from "../Library/MakerTraitsLib.sol";

interface IGridTrader {
    struct GridLine {
        uint256 price;
        uint24 portion;
    }

    struct Order {
        uint256 salt;
        address maker;
        address receiver;
        address makerAsset;
        address takerAsset;
        uint256 makingAmount;
        uint256 takingAmount;
        MakerTraits makerTraits;
    }
}
