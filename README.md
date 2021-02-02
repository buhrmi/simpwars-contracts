# Tokenized Streamers

Welcome to Tokenized Streamers. This smart contract allows anyone to tokenize Twitch streamers on the Ethereum blockchain. A tokenized streamer is called a simp. Simps are needed to participate in the great upcoming [SimpWars](https://github.com/buhrmi/simpwars).

At the time of deployment, all streamers are unassigned and freely purchasable by whoever wants them. Just pass the Twitch User ID to the `purchase` function of the contract and pay the required amount of Eth. You can use the `price` function to check the current price of a streamer. The price randomly fluctuates between 0 and 5 Eth and changes each block. You have a three block window (around 30 seconds) to purchase a streamer after the price changes. Make sure to set a generous gas price to ensure that your transaction gets mined within this window. If you submit too much Eth, the contract will send the remaining Eth back to you.

When you tokenize a streamer he will be your personal simp. You can do many things with your simps. For example, you can participate in the upcoming [SimpWars](https://github.com/buhrmi/simpwars), a game which is currently in development. You can also just keep them as trophies and speculate on their value.

## How to deploy

This is a [Hardhat](https://hardhat.org) project. To deploy (for example on Rinkeby) run 

```
npx hardhat run --network Rinkeby scripts/deploy.js
```

you can then verify the contract on Etherscan with

```
npx hardhat verify --network rinkeby DEPLOYED_CONTRACT_ADDRESS
```

## Running tests

The tests can be run with 

```
npx hardhat test
```
