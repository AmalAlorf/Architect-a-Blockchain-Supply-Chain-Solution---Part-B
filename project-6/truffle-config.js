const HDWallet = require('truffle-hdwallet-provider');
const infura = "rinkeby.infura.io/v3/bc814b727285469c91baa2fecc2dfc90";
const mnemonic = "often cover notable easily purity antique exhibit couch cram staff unusual age";


module.exports = {
    networks: {
        development: {
            host: "127.0.0.1",
            port: 8545,
            network_id: "*" // Match any network id
        },
        rinkeby: {
            provider: function() {
                return new HDWallet(mnemonic, infura)
            },
            network_id: 4,
            gas: 4500000,
            gasPrice: 10000000000
        }
    }
};