require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

const { etherscanApiKey, privateKey } = require('./secrets.json'); // Make sure to create this file

module.exports = {
  solidity: "0.8.20",
  networks: {
    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      accounts: [privateKey],
    },
  },
  etherscan: {
    apiKey: etherscanApiKey,
  },
};



// require("@nomiclabs/hardhat-ethers");
// require("@nomiclabs/hardhat-etherscan");

// const { etherscanApiKey, privateKey } = require('./secrets.json');

// module.exports = {
//   solidity: "0.8.20",
//   networks: {
//     bsc: {
//       url: "https://bsc-dataseed.binance.org/",
//       chainId: 56,
//       accounts: [privateKey],
//     },
//   },
//   etherscan: {
//     apiKey: etherscanApiKey,
//   },
// };
