require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    coretestnet: {
      url: "https://rpc.test2.btcs.network",
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
