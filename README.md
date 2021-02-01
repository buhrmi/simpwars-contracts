# Tokenized Streamers

This smart contract tokenizes streamers on the Ethereum blockchain.

A tokenized streamer is called a Simp (I have invented this, please don't steal this OK thanks)

You can do many things with Simps. For example, you can use them to play [SimpWars](https://github.com/buhrmi/simpwars), a game which is currently in development.

## How to deploy

This is a [Hardhat](https://hardhat.org) project. To deploy (for example on Rinkeby) run 

```
npx hardhat run --network Rinkeby scripts/deploy.js
```

you can then verify the contract on Etherscan with

```
npx hardhat verify --network rinkeby DEPLOYED_CONTRACT_ADDRESS
```
