# Tokenized Streamers

Welcome to Tokenized Streamers. This smart contract allows anyone to tokenize Twitch streamers on the Ethereum blockchain. A tokenized streamer is called a simp. Simps are needed to participate in the great upcoming [SimpWars](https://github.com/buhrmi/simpwars).

At the time of deployment, all streamers are unassigned and freely purchasable by whoever wants them. The price randomly fluctuates between 0 and 5 Eth and changes each block. You can use the `price` function to check the current price of a streamer. You have a three block window (around 30 seconds) to purchase a streamer after the price changes. To purchase a streamer, call the `purchase` function with the Twitch User ID and pay the required amount of Eth. Make sure to set a generous gas price to ensure that your transaction gets mined within the three block window. If you submit too much Eth, the contract will send the remaining Eth back to you.

### Simp Upgrade Tokens

Every 24 hours all simps you hold emit 10 Simp Upgrade Tokens (SUT). You can burn these tokens to upgrade your simps and make them more powerful.

To upgrade a simp, call the `upgrade` function with the simp ID and the amount of upgrade tokens you would like to burn. You can only upgrade simps that you own yourself and simps you do not own that have `upgradeAccepted` set to true.

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
