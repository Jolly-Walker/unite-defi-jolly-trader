// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "../Interfaces/AggregatorV3Interface.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

library ChainlinkOracleLib {
    using SafeCast for int256;

    function getPrice(address chainLinkFeed) public view returns (uint256 rate) {
        uint256 chainlinkDecimals = 10 ** AggregatorV3Interface(chainLinkFeed).decimals();
        (
            ,
            int256 price,
            ,
            ,
        ) = AggregatorV3Interface(chainLinkFeed).latestRoundData();
        rate = price.toUint256() / chainlinkDecimals;

        return rate;
    }

    function sqrtPriceX96ToUint(uint160 sqrtPriceX96, uint8 decimalsToken0) internal pure returns (uint256) {
        uint256 numerator1 = uint256(sqrtPriceX96) * uint256(sqrtPriceX96);
        uint256 numerator2 = 10 ** decimalsToken0;
        return Math.mulDiv(numerator1, numerator2, 1 << 192);
    }
 
}
