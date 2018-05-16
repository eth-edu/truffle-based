var HDWalletProvider = require("truffle-hdwallet-provider");
var config = require('./config.json');

module.exports = {

  // networks: {
  //   ropsten: {
  //     provider: new HDWalletProvider(config.mnemonic, config.providerUrl),
  //     network_id: '3',
  //     gas: 4512388
  //     //gasPrice: 50000000000
  //     //from:
  //   },
  //   development: {
  //     host: "127.0.0.1",
  //     port: 8080,
  //     network_id: "*"
  //   }
  // }



networks: {
  ropsten: {
    provider: function() {
      return new HDWalletProvider(config.mnemonic, config.providerUrl);
    },
    network_id: '3',
    gas: 4412388
  },
  development: {
    provider: function() {
      return new HDWalletProvider(config.mnemonic, "http://127.0.0.1:8545/");
    },
    network_id: '*'
  }
}

};
