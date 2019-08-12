const HDWallet = require('truffle-hdwallet-provider');
const infura = "https://rinkeby.infura.io/v3/bc814b727285469c91baa2fecc2dfc90";
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
    },
    // Set default mocha options here, use special reporters etc.
    mocha: {
        // timeout: 100000
    },

    // Configure your compilers
    compilers: {
        solc: {
            // version: "0.5.1",    // Fetch exact version from solc-bin (default: truffle's version)
            // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
            // settings: {          // See the solidity docs for advice about optimization and evmVersion
            //  optimizer: {
            //    enabled: false,
            //    runs: 200
            //  },
            //  evmVersion: "byzantium"
            // }
        }
    }
}