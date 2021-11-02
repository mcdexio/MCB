require("@openzeppelin/hardhat-upgrades");
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-etherscan";

const pk = process.env["PK"];
const infuraId = process.env["INFURA_ID"];
const etherscanApiKey = process.env["ETHERSCAN_API_KEY"];

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      // loggingEnabled: true
    },
    arbrinkeby: {
      url: `https://rinkeby.arbitrum.io/rpc`,
      gasPrice: 6e8,
      blockGasLimit: "80000000",
      accounts: [pk],
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${infuraId}`,
      gasPrice: 1e9,
      accounts: [pk],
      timeout: 300000,
      confirmations: 1,
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.7.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.10",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  etherscan: {
    apiKey: etherscanApiKey
  },
  mocha: {
    timeout: 60000,
  },
};
