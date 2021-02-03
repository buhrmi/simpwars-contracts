# Tokenized Streamers

> When simps go to the moon 🚀

Hello and welcome. This repo contains the smart contract that allows anyone to mint a simp on the Ethereum blockchain. A simp is a tokenized Twitch streamer. Simps are needed to participate in the great upcoming [SimpWars](https://github.com/buhrmi/simpwars).

The initial minting cost is 1 ETH and doubles every time a new simp is minted. To prevent the price from skyrocketing the price gradually decreases by 50% every 24 hours.

No simps are pre-minted and can be minted by whoever wants them. You can use the `price` function to check the current cost to mint a simp. To actually mint a simp, call the `mint` function with the Twitch User ID and pay the required amount of Eth. If you submit too much Eth, the contract will send the remaining Eth back to you.

## Simp Upgrade Tokens

Every 24 hours all simps you hold emit 10 Simp Upgrade Tokens (SUT). You can burn these tokens to upgrade your simps and make them more powerful.

To upgrade a simp, call the `upgrade` function with the simp ID and the amount of upgrade tokens you would like to burn. You can only upgrade simps that you own yourself and simps you do not own that have `upgradeAccepted` set to true.

### Contract Address

The contract is not yet deployed. This will happen live on stream at a future date. Please join the [Discord Server](https://discord.gg/VH2haTs) for announcements.

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
