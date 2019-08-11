# Architect a Supply Chain: Part B - 
This repository holds all the files that consitute our blockchain-based supply chain solution for online shopping. We will build an application using the Ethereum blockchain for storage of data and smart contract functionality .

# Libraries
truffle-hdwallet-provider is used to deploy the contract to Rinkeby network

# Transaction ID and contract address
Address: bc814b727285469c91baa2fecc2dfc90


# Versions
Solidity: v0.5.1 Truffle: v5 Web3.js: v1.0

# To run the application: 
#First install all requisite npm packages :
npm install

#Launch Ganache:
ganache-cli -m

#In a separate terminal window, Compile smart contracts:

truffle compile

#Test smart contracts:

truffle test

#In a separate terminal window, launch the DApp:

npm run dev
