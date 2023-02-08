// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract YulSum {
    function sum(uint256[] memory a) public pure returns (uint256 result) {
        assembly {
            let n := mload(a) // `a` will have the length of the array
            // calculate slot of the last element already
            let end := add(add(a, 0x20), mul(n, 0x20))
            for {
                // i should now be slot of the first element: add(a, 0x20)
                let i := add(a, 0x20) // for loop init var
                // condition
                // solidity compiler will add iszero in the bytecode if its not already there - causing increased usage - lt(i, n)
                // solidity compiler will remove iszero from the bytecode if its already there - causing reduced usage - iszero(eq(i, n))
                // i should be checked against end now
            } iszero(eq(i, end)) {
                // i should be incremented by 32 bytes : one slot now
                i := add(i, 0x20) // step
            } {
                result := add(result, mload(i)) // i is the slot of each element. so mload directly from i
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
