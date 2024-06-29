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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Adapter {
    using SafeERC20 for IERC20;
    mapping (address => uint) balance_m;
    mapping (address => uint) approved_m;
    mapping (address => uint) deposited_m;
    mapping (address => uint) staked_m;
    mapping (address => int) stake_m;

    address public owner;
    bool internal locked = false;
    uint public total_deposited = 0;
    IERC20 public constant usdt_token = IERC20(0x238b6327adaadfce9a75eb1f264d631780d6c715);

    modifier is_owner(){
        require(msg.sender == owner, "Insufficient user permissions");
        _;
    }

    modifier no_reentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        owner = msg.sender;
    }

    function set_owner(address new_owner) external is_owner {
        owner = new_owner;
    }

    function get_owner() external view returns(address) {
        return owner;
    }

    function get_balance() external view returns(uint256) {
        return balance_m[msg.sender];
    }

    function get_balance_by_address(address target) external view returns(uint256) {
        return balance_m[target];
    }

    function get_deposited() external view returns(uint256) {
        return deposited_m[msg.sender];
    }

    function get_deposited_by_address(address target) external view returns(uint256) {
        return deposited_m[target];
    }

    function get_approved() external view returns(uint256) {
        return approved_m[msg.sender];
    }

    function get_approved_by_address(address target) external view returns(uint256) {
        return approved_m[target];
    }

    function get_stake() external view returns(int256) {
        return stake_m[msg.sender];
    }

    function get_stake_by_address(address target) external view returns(int256) {
        return stake_m[target];
    }

    function get_staked() external view returns(uint256) {
        return staked_m[msg.sender];
    }

    function get_staked_by_address(address target) external view returns(uint256) {
        return staked_m[target];
    }

    function deposit(uint256 amount) external no_reentrancy() {
        usdt_token.safeTransferFrom(msg.sender, address(this), amount);
        usdt_token.safeIncreaseAllowance(address(this), amount);
        total_deposited += amount;
        deposited_m[msg.sender] += amount;
        balance_m[msg.sender] += amount;
    }

    function stake(uint256 amount) external {
        require(balance_m[msg.sender] >= amount, "Insufficient user balance");
        balance_m[msg.sender] -= amount;
        staked_m[msg.sender] += amount;
        stake_m[msg.sender] += int256(amount);
    }

    function unstake(uint256 amount, address target) external is_owner {
        balance_m[target] += amount;
        stake_m[target] -= int256(amount);
    }

    function withdraw(uint256 amount) external no_reentrancy() {
        require(balance_m[msg.sender] >= amount, "Insufficient user balance");
        balance_m[msg.sender] -= amount;
        usdt_token.safeTransferFrom(address(this), msg.sender, amount);
    }

    function withdraw_eth(uint256 amount) external is_owner {
        payable(owner).transfer(amount);
    }

    function supply() public payable {}

}
