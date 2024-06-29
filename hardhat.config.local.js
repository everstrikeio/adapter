require("@nomiclabs/hardhat-waffle");
require("@nomicfoundation/hardhat-verify");
const fs = require("fs");

const PRIVATE_KEY = "";
const GAS_LIMIT = 1000000;
const GAS_PRICE = 100000000000;

const STRINGUTILS_CONTRACT_ADDRESS = "";
const VERIFYUTILS_CONTRACT_ADDRESS = "";

task("deploy_libraries", "Deploys libraries", async (taskArgs, hre) => {
  const StringUtils = await hre.ethers.getContractFactory("StringUtils");
  const stringutils = await StringUtils.deploy({gasLimit: GAS_LIMIT});
  console.info("StringUtils", stringutils)
  await stringutils.deployed();

  const VerifyUtils = await hre.ethers.getContractFactory("VerifyUtils");
  const verifyutils = await VerifyUtils.deploy({gasLimit: GAS_LIMIT});
  console.info("VerifyUtils", verifyutils)
  await verifyutils.deployed();
});

task("deploy_token", "Deploys token", async (taskArgs, hre) => {
  const Main = await hre.ethers.getContractFactory("USDT", {});
  const main = await Main.deploy({gasLimit: GAS_LIMIT, gasPrice: GAS_PRICE});
  console.info(main)
  await main.deployed();
});

task("deploy_contracts", "Deploys contract, get wallets, and outputs files", async (taskArgs, hre) => {
  const Main = await hre.ethers.getContractFactory("Adapter", {
    librariess: {
      StringUtils: STRINGUTILS_CONTRACT_ADDRESS,
      VerifyUtils: VERIFYUTILS_CONTRACT_ADDRESS,
    }
  });
  const main = await Main.deploy({gasLimit: GAS_LIMIT, gasPrice: GAS_PRICE});
  console.info(main)
  await main.deployed();

  const contractAddress = main.address;

  fs.writeFileSync('./.contract', contractAddress);

  const accounts = await hre.ethers.getSigners();

  const walletAddress = accounts[0].address;

  fs.writeFileSync('./.wallet', walletAddress);
});

task("deploy", "Deploys contract, get wallets, and outputs files", async (taskArgs, hre) => {
  const Main = await hre.ethers.getContractFactory("Adapter", {});
  const main = await Main.deploy({gasLimit: GAS_LIMIT, gasPrice: GAS_PRICE});
  console.info(main)
  await main.deployed();

  const contractAddress = main.address;

  fs.writeFileSync('./.contract', contractAddress);

  const accounts = await hre.ethers.getSigners();

  const walletAddress = accounts[0].address;

  fs.writeFileSync('./.wallet', walletAddress);
});

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.10",
    settings: {
      optimizer: {
        enabled: true,
        runs: 999
      }
    }
  },
  sourcify: {
    enabled: false,
  },
  networks: {
    mainnet: {
      url: "https://mainnet.infura.io/v3/",
      accounts: [PRIVATE_KEY]
    },
    goerli: {
      url: "https://goerli.infura.io/v3/",
      accounts: [PRIVATE_KEY]
    },
    sepolia: {
      url: "https://sepolia.infura.io/v3/",
      accounts: [PRIVATE_KEY]
    },
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
      chainId: 97,
      accounts: [PRIVATE_KEY]
    },
    bsc: {
      url: "https://bsc-dataseed.bnbchain.org/",
      chainId: 56,
      accounts: [PRIVATE_KEY]
    },
    polygon: {
      url: 'https://polygon-rpc.com',
      accounts: [PRIVATE_KEY]
    },
    polygonAmoy: {
      url: "https://rpc-amoy.polygon.technology",
      accounts: [PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      mainnet: "",
      goerli: "",
      sepolia: "",
      polygonAmoy: "",
      polygon: "",
      bsc: "",
      bscTestnet: ""
    },
    customChains: [
    {
      network: "polygonAmoy",
      chainId: 80002,
      urls: {
        apiURL: "https://www.oklink.com/api/explorer/v1/contract/verify/async/api/polygonAmoy",
        browserURL: "https://www.oklink.com/polygonAmoy"
      }
    }
    ]
  }
};
