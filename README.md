# Tokenized Streamers

Welcome to Tokenized Streamers. This Tokenized Streamers smart contract allows anyone to tokenize Twitch streamers on the Ethereum blockchain and play with them in the great upcoming [SimpWars](https://github.com/buhrmi/simpwars).

At the time of deployment, all streamers are unassigned and freely purchasable by whoever wants them. Just pass the Twitch User ID to the `purchase` function of the contract and pay the required amount of Eth. You can use the `price` function to check the current price of a streamer (the price randomly fluctuates between 0 and 5 Eth and changes each block). If you submit too much Eth, the contract will send the remaining Eth back to you. No worries.

Once a streamer is tokenized, he will be your personal simp. You can do many things with your simps. For example, you can use them to play [SimpWars](https://github.com/buhrmi/simpwars), a game which is currently in development. Of course you can also just keep them as trophies and speculate on their value.

The contract is not yet deployed. This will be done [live on Twitch](https://twitch.tv/buhrmi_tv) some time in the future.

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
