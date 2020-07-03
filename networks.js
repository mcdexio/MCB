var HDWalletProvider = require('truffle-hdwallet-provider');

module.exports = {
  networks: {
    development: {
      protocol: 'http',
      host: 'localhost',
      port: 8545,
      gas: 5000000,
      gasPrice: 5e9,
      networkId: '*',
    },
    man: {
        network_id: 1,
        gas: 1000000,
        gasPrice: 40*1000000000,
        provider: function () { return new HDWalletProvider('', 'http://server10.jy.mcarlo.com:8645'); },
        networkCheckTimeout: 30000,
    }
  },
};
