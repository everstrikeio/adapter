const Web3 = require('web3');
const abi = require('../artifacts/contracts/Adapter.sol/Adapter.json').abi;

const RPC_URL = "https://rpc-amoy.polygon.technologym";
const CONTRACT_ADDRESS = "0x0000000000000000000000000000000000000000";
const PRIVATE_KEY = "0x0000000000000000000000000000000000000000";
const SENDER = "0x0000000000000000000000000000000000000000";
const TO = "0x0000000000000000000000000000000000000000";
const GAS_LIMIT = 300000;
const AMOUNT = 100;

const web3 = new Web3(RPC_URL);
const contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS, {});
const query = contract.methods.unstake(AMOUNT.toString(), SENDER);
const encoded_abi = query.encodeABI();

(async function() {
  const signedTx = await web3.eth.accounts.signTransaction(
    {
      data: encoded_abi,
      from: SENDER,
      gasLimit: GAS_LIMIT,
      to: TO,
    },
    PRIVATE_KEY
  );
  return web3.eth.sendSignedTransaction(signedTx.rawTransaction);
})();
