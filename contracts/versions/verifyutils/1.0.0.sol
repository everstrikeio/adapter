/*
    Copyright 2024 Everstrike.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity ^0.8.0;

library VerifyUtils {

    function verify_signature(string memory input, bytes memory signature, address signer) public pure returns (bool) {
        bytes32 input_hash = keccak256(abi.encodePacked(input));
        bytes32 signed_input_hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", input_hash));
        return recover_signer(signed_input_hash, signature) == signer;
    }

    function recover_signer(bytes32 signed_input_hash, bytes memory signature) private pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = split_signature(signature);
        return ecrecover(signed_input_hash, v, r, s);
    }

     function split_signature(bytes memory signature) private pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(signature.length == 65, "invalid signature length");
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }

}
