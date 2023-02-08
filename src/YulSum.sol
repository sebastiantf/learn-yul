// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract YulSum {
    function sum(uint256[] memory a) public pure returns (uint256 result) {
        assembly {
            let n := mload(a) // `a` will have the length of the array
            for {
                let i := 0 // for loop init var
                // condition
                // solidity compiler will add iszero in the bytecode if its not already there - causing increased usage - lt(i, n)
                // solidity compiler will remove iszero from the bytecode if its already there - causing reduced usage - iszero(eq(i, n))
            } iszero(eq(i, n)) {
                i := add(i, 1) // step
            } {
                result := add(result, mload(add(add(a, 0x20), mul(i, 0x20))))
            }
        }
    }
}

/* 
add(a, 0x20) - first element starts at [a + 1 slot] 
                = [a + 32 bytes] 
                = a + 0x20

mul(i, 0x20) - ith element starts at [first element start + (slot size * number of elements)] 
                = [(a + 0x20) + (i * 32 bytes)] 
                = [(a + 0x20) + mul(i, 0x20)]
                = add(a + 0x20, mul(i, 0x20))
                = add(add(a, 0x20), mul(i, 0x20))

mload from the calculated slot = mload(add(add(a, 0x20), mul(i, 0x20)))

result = result + ith element
       = add(result, ith element)
       = add(result, mload(add(add(a, 0x20), mul(i, 0x20))))
*/
