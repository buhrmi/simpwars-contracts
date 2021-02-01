# Streamer Tokens

This smart contract allows you to tokenize streamers on the Ethereum blockchain.

A tokenized streamer is called a Simp.

You can use Simps to play [SimpWars](https://github.com/buhrmi/simpwars)

## How to deploy

This is a [Hardhat](https://hardhat.org) project. To deploy (for example on Rinkeby) run 

```
npx hardhat run --network Rinkeby scripts/deploy.js
```

you can then verify the contract on Etherscan with

```
npx hardhat verify --network rinkeby DEPLOYED_CONTRACT_ADDRESS
```
