// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


interface IGridTrader {
    struct GridLine {
        uint256 price;
        uint24 portion;
        bool triggered;
    }
}
