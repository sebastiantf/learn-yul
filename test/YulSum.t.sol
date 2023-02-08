// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/YulSum.sol";

contract YulSumTest is Test {
    YulSum public yulSum;

    function setUp() public {
        yulSum = new YulSum();
    }

    function testSum() public {
        uint256[] memory a = new uint256[](3);
        a[0] = 1;
        a[1] = 2;
        a[2] = 3;

        assertEq(yulSum.sum(a), 6);
    }
}
