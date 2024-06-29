const ethers = require('ethers');
const revert_reason = require('./revert_reason');
const abi = require('../artifacts/contracts/Adapter.sol/Adapter.json').abi;
const config = require('dotenv').config;

const PRIVATE_KEY = "";

const USDT_ABI = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"}]";
const USDT_CONTRACT_ADDRESS = "0x238b6327adaadfce9a75eb1f264d631780d6c715";
const RPC_URL = "https://rpc-amoy.polygon.technology"
const GAS_LIMIT = 300000;
const GAS_PRICE = 90000000000;

config();
const provider = new ethers.ethers.providers.JsonRpcProvider(RPC_URL);
const signer = provider.getSigner(process.env.WALLET_ADDRESS || 'UNKNOWN_WALLET_ADDRESS')
const contract = new ethers.ethers.Contract(process.env.CONTRACT_ADDRESS || 'UNKNOWN_CONTRACT_ADDRESS', abi, signer);
const usdt = new ethers.ethers.Contract(USDT_CONTRACT_ADDRESS, USDT_ABI, signer);
const wallet = new ethers.ethers.Wallet(PRIVATE_KEY);
const wallet_signer = wallet.connect(provider);

const deposit = async (amount) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.deposit(amount, {gasLimit: GAS_LIMIT, gasPrice: GAS_PRICE});
    result.wait();
    console.info({ result });
  } catch (error) {
    console.info({ error });
  }
}

const withdraw = async (amount) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.withdraw(amount, {gasLimit: GAS_LIMIT, gasPrice: 120000000000 });
    result.wait();
    console.info({ result });
  } catch (error) {
    console.info({ error });
  }
}

const stake = async (amount) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.stake(amount, {gasLimit: GAS_LIMIT, gasPrice: GAS_PRICE });
    result.wait();
    console.info({ result });
  } catch (error) {
    console.info({ error });
  }
}

const unstake = async (amount, target) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.unstake(amount, target, {gasLimit: GAS_LIMIT, gasPrice: GAS_PRICE });
    result.wait();
    console.info({ result });
  } catch (error) {
    console.info({ error });
  }
}

const balance = async () => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.get_balance();
    console.info({ result });
  } catch (error) {
    console.info({ error });
  }
}

const unstake_allowance = async () => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.get_unstake_allowance();
    console.info({ result });
  } catch (error) {
    console.info({ error });
  }
}

const staked = async () => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.get_staked();
    console.info({ result });
  } catch (error) {
    console.info({ error });
  }
}

const approve = async (amount) => {
  try {
    const tx_signer = usdt.connect(wallet_signer);
    const result = await tx_signer.approve(process.env.CONTRACT_ADDRESS, amount, { gasLimit: GAS_LIMIT, gasPrice: GAS_PRICE });
    result.wait();
    console.info({ result });
  } catch (error) {
    console.info({ error });
  }
}

const set_unstake_allowance = async (address, amount) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.set_unstake_allowance(address, amount, { gasPrice: GAS_PRICE });
    result.wait();
    console.info({ result });
  } catch (error) {
    console.info({ error });
  }
}

const set_owner = async (address) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.set_owner(address, { gasPrice: GAS_PRICE });
    result.wait();
    console.info({ result });
  } catch (error) {
    console.info({ error });
  }
}

const get_owner = async () => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.get_owner({ });
    console.info({ result });
  } catch (error) {
    console.info({ error });
  }
}

const supply = async (amount) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.supply({value: ethers.utils.parseUnits(amount, "ether"), gasLimit: GAS_LIMIT});
    result.wait();
    console.info({ result });
  } catch (error) {
    console.info({ error });
  }
}

const sign = async (address) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const input = 5;
    const nonce = 0;
    var message = ethers.utils.solidityPack(["uint256","uint256"], [input,nonce]);
    message = ethers.utils.solidityKeccak256(["bytes"], [message]);
    const signed = await wallet.signMessage(ethers.utils.arrayify(message));
    console.info(signed);
    const result = await tx_signer.verify_signature(input, nonce, signed, address);
    console.info(result);
  } catch (error) {
    console.info({ error });
  }
}

const str_to_uint = async (string, delimiter) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const signed = await tx_signer.split_string(string, delimiter);
    console.info(signed);
  } catch (error) {
    console.info({ error });
  }
}

const withdraw_trustless = async (amount, address, time, nonce) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const amount = parseFloat(amount);
    const state_receipt = amount + ":ADDRESS:" + address + ":TIME:" + time + ":NONCE:" + nonce;
    var message = ethers.utils.solidityPack(["string"], [state_receipt]);
    message = ethers.utils.solidityKeccak256(["bytes"], [message]);
    const signed = await wallet.signMessage(ethers.utils.arrayify(message));
    console.info(signed);
    const result = await tx_signer.withdraw_trustless(amount, state_receipt, signed, signed, {gasLimit: GAS_LIMIT});
    console.info({result});
    result.wait();
    console.info({result});
  } catch (error) {
    console.info({ error });
  }
}

const complete_withdrawal_trustless = async () => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.complete_withdrawal_trustless({gasLimit: GAS_LIMIT});
    result.wait();
    console.info({result});
  } catch (error) {
    console.info({ error });
  }
}

const reject_withdrawal_trustless = async (amount, address, time, nonce) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const state_receipt = amount + ":ADDRESS:" + address + ":TIME:" + time + ":NONCE:" + nonce;
    var message = ethers.utils.solidityPack(["string"], [state_receipt]);
    message = ethers.utils.solidityKeccak256(["bytes"], [message]);
    const signed = await wallet.signMessage(ethers.utils.arrayify(message));
    console.info(signed);
    const result = await tx_signer.reject_withdrawal_trustless(address, state_receipt, signed, signed, {gasLimit: GAS_LIMIT});
    result.wait();
    console.info({result});
  } catch (error) {
    console.info({ error });
  }
}

const get_withdrawal_trustless = async (address) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.get_withdrawal_trustless(address);
    console.info(result);
  } catch (error) {
    console.info({ error });
  }
}

const get_trust_invalidation_requested = async () => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.get_trust_invalidation_requested();
    console.info(result);
  } catch (error) {
    console.info({ error });
  }
}

const get_trust_invalidated = async () => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.get_trust_invalidated();
    console.info(result);
  } catch (error) {
    console.info({ error });
  }
}

const request_trust_invalidation = async () => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.request_trust_invalidation({gasLimit: GAS_LIMIT});
    result.wait();
    console.info(result);
  } catch (error) {
    console.info({ error });
  }
}

const invalidate_trust = async () => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.invalidate_trust({gasLimit: GAS_LIMIT});
    result.wait();
    console.info(result);
  } catch (error) {
    console.info({ error });
  }
}

const set_signer = async (address, signer) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.set_signer(address, signer, {gasLimit: GAS_LIMIT});
    result.wait();
    console.info(result);
  } catch (error) {
    console.info({ error });
  }
}

const get_signer = async () => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const result = await tx_signer.get_signer();
    console.info(result);
  } catch (error) {
    console.info({ error });
  }
}

const split_string = async (string, delimiter) => {
  try {
    const tx_signer = contract.connect(wallet_signer);
    const split = await tx_signer.split_string_right(string, delimiter);
    console.info(split);
  } catch (error) {
    console.info({ error });
  }
}

const get_revert_reason_string = async (hash, network) => {
  console.info(await revert_reason(hash, network, undefined, provider));
}

(async function() {
    await get_approved_by_address("0x0000000000000000000000000000000000000000");
})();
