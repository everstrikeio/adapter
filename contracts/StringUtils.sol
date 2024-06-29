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

library StringUtils {

     struct slice {
         uint _len;
         uint _ptr;
     }

     struct StateReceipt {
         uint state_amount;
         uint state_time;
         string state_address;
         uint nonce;
     }

    struct TrustlessWithdrawal {
        bool valid;
        address initiator;
        uint time_initiated;
        uint challenge_expire;
        uint amount_requested;
        uint nonce;
        string state_receipt;
        bytes owner_signature;
        bytes operator_signature;
        uint stake_required;
    }

     function parse_state_receipt(string memory state_receipt) public pure returns (StateReceipt memory) {
         string memory state_amount_string = split_string_left(state_receipt, ":ADDRESS:");
         string memory state_address_time_string = split_string_right(state_receipt, ":ADDRESS:");
         string memory state_address_string = split_string_left(state_address_time_string, ":TIME:");
         string memory state_time_nonce_string = split_string_right(state_address_time_string, ":TIME:");
         string memory state_time_string = split_string_left(state_time_nonce_string, ":NONCE:");
         string memory state_nonce_string = split_string_right(state_time_nonce_string, ":NONCE:");
         (uint state_amount, bool state_amount_err) = str_to_uint(state_amount_string);
         (uint state_time, bool state_time_err) = str_to_uint(state_time_string);
         (uint nonce, bool nonce_err) = str_to_uint(state_nonce_string);
         require(state_amount_err, "Error parsing state receipt");
         require(state_time_err, "Error parsing state time");
         require(nonce_err, "Error parsing nonce");
         return StateReceipt({state_amount: state_amount, state_time: state_time, state_address: state_address_string, nonce: nonce});
    }

    function split_string_left(string memory self, string memory needle) public pure returns (string memory) {
        slice memory token = to_slice("");
        split(to_slice(self), to_slice(needle), token);
        return to_string(token);
    }

    function split_string_right(string memory self, string memory needle) public pure returns (string memory) {
        slice memory token = to_slice("");
        rsplit(to_slice(self), to_slice(needle), token);
        return to_string(token);
    }


    function split(slice memory self, slice memory needle, slice memory token) private pure returns (slice memory) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

    function rsplit(slice memory self, slice memory needle, slice memory token) private pure returns (slice memory) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }

    function to_slice(string memory self) private pure returns (slice memory) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    function to_string(slice memory self) private pure returns (string memory) {
        string memory ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr = selfptr;
        uint idx;
        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask;
                if (needlelen > 0) {
                    mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));
                }

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                uint end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr >= end)
                        return selfptr + selflen;
                    ptr++;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr;
            } else {
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }

                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

     function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr;
        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask;
                if (needlelen > 0) {
                    mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));
                }
                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                ptr = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr <= selfptr)
                        return selfptr;
                    ptr--;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr + needlelen;
            } else {
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }
        uint mask = type(uint).max;
        if (len > 0) {
            mask = 256 ** (32 - len) - 1;
        }
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function str_to_uint(string memory _str) public pure returns(uint256 res, bool err) {
        for (uint256 i = 0; i < bytes(_str).length; i++) {
            if ((uint8(bytes(_str)[i]) - 48) < 0 || (uint8(bytes(_str)[i]) - 48) > 9) {
                return (0, false);
            }
            res += (uint8(bytes(_str)[i]) - 48) * 10**(bytes(_str).length - i - 1);
        }
        return (res, true);
    }

    function string_to_address(string memory _address) public pure returns (address) {
        string memory cleanAddress = remove_0x_prefix(_address);
        bytes20 _addressBytes = parse_hex_string_to_bytes_20(cleanAddress);
        return address(_addressBytes);
    }

    function remove_0x_prefix(string memory _hexString) private pure returns (string memory) {
        if (bytes(_hexString).length >= 2 && bytes(_hexString)[0] == '0' && (bytes(_hexString)[1] == 'x' || bytes(_hexString)[1] == 'X')) {
            return substring(_hexString, 2, bytes(_hexString).length);
        }
        return _hexString;
    }

    function substring(string memory _str, uint256 _start, uint256 _end) private pure returns (string memory) {
        bytes memory _strBytes = bytes(_str);
        bytes memory _result = new bytes(_end - _start);
        for (uint256 i = _start; i < _end; i++) {
            _result[i - _start] = _strBytes[i];
        }
        return string(_result);
    }

    function parse_hex_string_to_bytes_20(string memory _hexString) private pure returns (bytes20) {
        bytes memory _bytesString = bytes(_hexString);
        uint160 _parsedBytes = 0;
        for (uint256 i = 0; i < _bytesString.length; i += 2) {
            _parsedBytes *= 256;
            uint8 _byteValue = parse_byte_to_uint_8(_bytesString[i]);
            _byteValue *= 16;
            _byteValue += parse_byte_to_uint_8(_bytesString[i + 1]);
            _parsedBytes += _byteValue;
        }
        return bytes20(_parsedBytes);
    }

    function parse_byte_to_uint_8(bytes1 _byte) private pure returns (uint8) {
        if (uint8(_byte) >= 48 && uint8(_byte) <= 57) {
            return uint8(_byte) - 48;
        } else if (uint8(_byte) >= 65 && uint8(_byte) <= 70) {
            return uint8(_byte) - 55;
        } else if (uint8(_byte) >= 97 && uint8(_byte) <= 102) {
            return uint8(_byte) - 87;
        } else {
            revert(string(abi.encodePacked("Invalid byte value: ", _byte)));
        }
    }

}
