require('dotenv').config()
const HDWalletProvider = require('@truffle/hdwallet-provider');

const fs = require('fs');

module.exports = {
  networks: {
    // development: {
    //   host: "127.0.0.1",
    //   port: 7545,
    //   network_id: "5777",
    // },
    rinkeby: {
      provider: function () {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.RINKEBY_RPC_URL);
      },
      network_id: 4,
      skipDryRun: true,
    },
    polygon: {
      provider: function () {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.RINKEBY_RPC_URL);
      },
      network_id: 137,
      skipDryRun: true,
    },
    mumbai: {
      provider: function () {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.RINKEBY_RPC_URL);
      },
      network_id: 80001,
      skipDryRun: true,
    },
    mainnet: {
      provider: function () {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.MAINNET_RPC_URL);
      },
      network_id: 1,
      skipDryRun: true,
    }
  },
  mocha: {
  },
  compilers: {
    solc: {
      version: "0.8.9",
    }
  },
  db: {
    enabled: false
  }
}
