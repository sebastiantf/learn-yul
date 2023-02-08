// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Masking.sol";

contract MaskingTest is Test {
    Masking public masking;

    function setUp() public {
        masking = new Masking();
    }

    function testGetSender() public {
        assertTrue(masking.getSender());
    }

    function testGetSenderYulWrong() public {
        vm.expectRevert();
        masking.getSenderYulWrong();
    }
}
