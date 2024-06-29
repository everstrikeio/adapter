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
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./StringUtils.sol";
import "./VerifyUtils.sol";

contract Adapter {
    using SafeERC20 for IERC20;
    mapping (address => uint) balance_m;
    mapping (address => uint) deposited_m;
    mapping (address => uint) staked_m;
    mapping (address => int) stake_m;
    mapping (address => bool) trustless_withdrawal_initiated;
    mapping (address => StringUtils.TrustlessWithdrawal) public trustless_withdrawals;
    mapping (address => uint) trust_invalidated;
    mapping (address => uint) trust_invalidation_requested;
    mapping (address => address) signers;
    mapping (address => int) unstake_allowance;

    address public owner;
    address public operator;
    bool internal locked = false;
    uint public total_deposited = 0;
    uint public constant TRUSTLESS_WITHDRAWAL_FEE = 20;
    uint public constant TRUSTLESS_WITHDRAWAL_STAKE = 100;
    uint public constant TRUSTLESS_WITHDRAWAL_MIN_TIME_TO_COMPLETION = 5 minutes;
    uint public constant TRUST_INVALIDATION_THRESHOLD = 5 minutes;

    IERC20 public constant usdt_token = IERC20(0x238b6327adaadfce9a75eb1f264d631780d6c715);

    modifier is_owner() {
        require(msg.sender == owner, "Insufficient user permissions");
        _;
    }

    modifier is_operator() {
        require(msg.sender == operator, "Insufficient user permissions");
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

    function set_operator(address new_operator) external is_owner {
        operator = new_operator;
    }

    function set_signer(address signer) external is_operator {
        require(signers[msg.sender] == address(0), "Signer already set");
        signers[msg.sender] = signer;
    }

    function get_signer() external view returns(address) {
        return signers[msg.sender];
    }

    function request_trust_invalidation() external {
        require(trust_invalidation_requested[msg.sender] == 0, "Trust already invalidated");
        trust_invalidation_requested[msg.sender] = block.timestamp;
    }

    function invalidate_trust() external {
        require(trust_invalidation_requested[msg.sender] != 0, "Trust invalidation not requested");
        require(trust_invalidated[msg.sender] == 0, "Trust already invalidated");
        require((block.timestamp - trust_invalidation_requested[msg.sender]) > TRUST_INVALIDATION_THRESHOLD, "Trust cannot be invalidated yet");
        trust_invalidated[msg.sender] = block.timestamp;
    }

    function validate_trust() external {
        require(trust_invalidated[msg.sender] != 0, "Trust not invalidated");
        trust_invalidated[msg.sender] = 0;
    }

    function get_trust_invalidated() external view returns(uint256) {
        return trust_invalidated[msg.sender];
    }

    function get_trust_invalidated_by_address(address target) external view returns(uint256) {
        return trust_invalidated[target];
    }

    function get_trust_invalidation_requested() external view returns(uint256) {
        return trust_invalidation_requested[msg.sender];
    }

    function get_trust_invalidation_requested_by_address(address target) external view returns(uint256) {
        return trust_invalidation_requested[target];
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

    function set_unstake_allowance(address target, int amount) external is_owner {
        unstake_allowance[target] = amount;
    }

    function get_unstake_allowance() external view returns(int256) {
        return unstake_allowance[msg.sender];
    }

    function get_unstake_allowance_by_address(address target) external view returns(int256) {
        return unstake_allowance[target];
    }

    function deposit(uint256 amount) external no_reentrancy {
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
        require((msg.sender == owner || (unstake_allowance[msg.sender] >= int(amount))), "Insufficient permissions");
        balance_m[target] += amount;
        stake_m[target] -= int256(amount);
        unstake_allowance[msg.sender] -= int(amount);
    }

    function withdraw(uint256 amount) external no_reentrancy {
        require(balance_m[msg.sender] >= amount, "Insufficient user balance");
        balance_m[msg.sender] -= amount;
        usdt_token.safeTransferFrom(address(this), msg.sender, amount);
    }

    function withdraw_trustless(uint256 amount, string memory state_receipt, bytes memory owner_signature, bytes memory operator_signature) external no_reentrancy {
        require(signers[msg.sender] != address(0), "Signer not set");
        require(VerifyUtils.verify_signature(state_receipt, owner_signature, signers[msg.sender]), "Invalid owner signature");
        require(VerifyUtils.verify_signature(state_receipt, operator_signature, owner), "Invalid operator signature");
        require(balance_m[msg.sender] >= TRUSTLESS_WITHDRAWAL_FEE, "Insufficient balance to cover fee");
        uint stake_required = Math.max(TRUSTLESS_WITHDRAWAL_STAKE, amount / 10);
        StringUtils.StateReceipt memory parsed_state_receipt = StringUtils.parse_state_receipt(state_receipt);
        require(parsed_state_receipt.nonce >= 0, "Invalid nonce");
        require((trust_invalidated[msg.sender] == 0 || parsed_state_receipt.state_time <= trust_invalidated[msg.sender]), "Trust invalidated");
        require(StringUtils.string_to_address(parsed_state_receipt.state_address) == msg.sender, "Address in state receipt does not match sender");
        require(parsed_state_receipt.state_amount >= amount, "Insufficient balance to withdraw");
        require(balance_m[msg.sender] >= stake_required, "Insufficient balance to cover stake");
        require(!trustless_withdrawal_initiated[msg.sender], "Trustless withdrawal already in progress");
        balance_m[msg.sender] -= TRUSTLESS_WITHDRAWAL_FEE;
        balance_m[owner] += TRUSTLESS_WITHDRAWAL_FEE;
        balance_m[msg.sender] -= stake_required;
        trustless_withdrawal_initiated[msg.sender] = true;
        trustless_withdrawals[msg.sender] = StringUtils.TrustlessWithdrawal({valid: true, initiator: msg.sender, time_initiated: block.timestamp, challenge_expire: block.timestamp + TRUSTLESS_WITHDRAWAL_MIN_TIME_TO_COMPLETION, amount_requested: amount, nonce: parsed_state_receipt.nonce, state_receipt: state_receipt, owner_signature: owner_signature, operator_signature: operator_signature, stake_required: stake_required});
    }

    function get_withdrawal_trustless(address target) external view returns(StringUtils.TrustlessWithdrawal memory) {
        return trustless_withdrawals[target];
    }

    function complete_withdrawal_trustless() external no_reentrancy {
        require(signers[msg.sender] != address(0), "Signer not set");
        require(trustless_withdrawal_initiated[msg.sender], "Trustless withdrawal not initialized");
        StringUtils.TrustlessWithdrawal memory user_withdrawal = trustless_withdrawals[msg.sender];
        require(user_withdrawal.valid, "Trustless withdrawal not initialized");
        require(block.timestamp - user_withdrawal.time_initiated > TRUSTLESS_WITHDRAWAL_MIN_TIME_TO_COMPLETION, "Trustless withdrawal challenge period not exceeded");
        uint amount = user_withdrawal.amount_requested;
        uint stake_required = user_withdrawal.stake_required;
        trustless_withdrawal_initiated[msg.sender] = false;
        delete trustless_withdrawals[msg.sender];
        balance_m[msg.sender] += amount;
        stake_m[msg.sender] -= int256(amount);
        balance_m[msg.sender] += stake_required;
    }

    function force_complete_withdrawal_trustless(address target) external no_reentrancy is_owner {
        require(signers[target] != address(0), "Signer not set");
        require(trustless_withdrawal_initiated[target], "Trustless withdrawal not initialized");
        StringUtils.TrustlessWithdrawal memory user_withdrawal = trustless_withdrawals[target];
        require(user_withdrawal.valid, "Trustless withdrawal not initialized");
        uint amount = user_withdrawal.amount_requested;
        uint stake_required = user_withdrawal.stake_required;
        trustless_withdrawal_initiated[target] = false;
        delete trustless_withdrawals[target];
        balance_m[target] += amount;
        stake_m[target] -= int256(amount);
        balance_m[target] += stake_required;
    }

    function reject_withdrawal_trustless(address target, string memory state_receipt, bytes memory owner_signature, bytes memory operator_signature) external no_reentrancy is_owner {
        require(signers[target] != address(0), "Signer not set");
        require(trustless_withdrawal_initiated[target], "Trustless withdrawal not initialized");
        StringUtils.TrustlessWithdrawal memory user_withdrawal = trustless_withdrawals[target];
        require(user_withdrawal.valid, "Trustless withdrawal not initialized");
        require(((block.timestamp - user_withdrawal.time_initiated <= TRUSTLESS_WITHDRAWAL_MIN_TIME_TO_COMPLETION) && user_withdrawal.time_initiated != 0), "Trustless withdrawal challenge period exceeded");
        require(VerifyUtils.verify_signature(state_receipt, owner_signature, signers[target]), "Invalid owner signature");
        require(VerifyUtils.verify_signature(state_receipt, operator_signature, owner), "Invalid operator signature");
        StringUtils.StateReceipt memory parsed_state_receipt = StringUtils.parse_state_receipt(state_receipt);
        require(parsed_state_receipt.nonce > user_withdrawal.nonce, "Nonce not high enough");
        require((trust_invalidated[target] == 0 || parsed_state_receipt.state_time <= trust_invalidated[target]), "Trust invalidated");
        require(StringUtils.string_to_address(parsed_state_receipt.state_address) == target, "Address in state receipt does not match target");
        trustless_withdrawal_initiated[target] = false;
        delete trustless_withdrawals[target];
        balance_m[owner] += user_withdrawal.stake_required;
    }

}
