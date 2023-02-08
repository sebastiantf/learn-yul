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

    // msg.sender will be 0x7fa9385be102ac3eac297483dd6233d62b3e1496
    // block.timestamp will be 1

    function getSender() public view returns (bool result) {
        // trim and cast sender into an address
        address _sender = address(uint160(sender));
        // solidity cleans the upper 96 bits during this equality check by ANDing with a bit mask if you look in the bytecode
        // 00 00 00 00 00 00 00 00 00 00 00 01 7f a9 38 5b e1 02 ac 3e ac 29 74 83 dd 62 33 d6 2b 3e 14 96
        // 00 00 00 00 00 00 00 00 00 00 00 00 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
        // result = 00 00 00 00 00 00 00 00 00 00 00 00 7f a9 38 5b e1 02 ac 3e ac 29 74 83 dd 62 33 d6 2b 3e 14 96 = 0x7fa9385be102ac3eac297483dd6233d62b3e1496
        result = _sender == msg.sender;
        require(result);
    }

    function getSenderYulWrong() public view returns (bool result) {
        address _sender = address(uint160(sender));
        assembly {
            // when doing the equality check in Yul, the upper 96 bits are not cleaned
            // result = 00 00 00 00 00 00 00 00 00 00 00 01 7f a9 38 5b e1 02 ac 3e ac 29 74 83 dd 62 33 d6 2b 3e 14 96
            result := eq(_sender, caller())
        }
        require(result);
    }

    function getSenderYulCorrect() public view returns (bool result) {
        address _sender = address(uint160(sender));
        assembly {
            // hence we do the cleaning manually in Yul
            // shift left by 96 bits to get rid of the timestamp part
            // shift right back by 96 bits to make it a 20 byte address
            // but in reality it seems the optimizer replaces it with the bit mask
            // 00 00 00 00 00 00 00 00 00 00 00 01 7f a9 38 5b e1 02 ac 3e ac 29 74 83 dd 62 33 d6 2b 3e 14 96
            // 00 00 00 00 00 00 00 00 00 00 00 00 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
            // result = 00 00 00 00 00 00 00 00 00 00 00 00 7f a9 38 5b e1 02 ac 3e ac 29 74 83 dd 62 33 d6 2b 3e 14 96 = 0x7fa9385be102ac3eac297483dd6233d62b3e1496
            _sender := shr(96, shl(96, _sender))
            result := eq(_sender, caller())
        }
        require(result);
    }

    function getSenderYulCorrectMask() public view returns (bool result) {
        address _sender = address(uint160(sender));
        assembly {
            // so we could replace this with the bit mask
            _sender := and(0xffffffffffffffffffffffffffffffffffffffff, _sender)
            result := eq(_sender, caller())
        }
        require(result);
    }

    function getSenderYulCorrectMaskCaller() public view returns (bool result) {
        address _sender = address(uint160(sender));
        assembly {
            _sender := and(0xffffffffffffffffffffffffffffffffffffffff, _sender)
            result := eq(
                _sender,
                // we could also mask the caller here which results in saving some gas too
                and(0xffffffffffffffffffffffffffffffffffffffff, caller())
            )
        }
        require(result);
    }
}
