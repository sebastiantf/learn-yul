// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Masking {
    // Packing block.timestamp and caller address
    // address is 20 bytes = 160 bits
    // timestamps can arguably be represented in uint16
    // packing and address in a uint256 leaves 256 - 160 = 96 bits for storing a number where we'll store block.timestamp
    // block.timestamp is uint256
    // left shift block.timestamp by 160 bits to free up the lower order bits
    // and we OR the uint256 casted address into these freed bits
    uint256 sender = (block.timestamp << 160) | uint256(uint160(msg.sender));

    function getSender() public view returns (bool result) {
        // trim and cast sender into an address
        address _sender = address(uint160(sender));
        return _sender == msg.sender;
    }
}
