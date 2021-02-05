# Tokenized Streamers

This repo contains the smart contract that allows anyone to tokenize Twitch streamers on the Ethereum blockchain. A tokenized streamer is called a simp. Simps are needed to fight in the upcoming [SimpWars](https://github.com/buhrmi/simpwars).

Anyone can mint new simps for a small minting fee. This fee logarithmically decreases by 50% every 24 hours (down to a minimum of 0.1 ETH), but doubles every time a new simp is minted.

Only **one** simp can be minted per streamer. No simps are pre-minted. To mint a simp, call the `mint` function with the Twitch User ID and pay the required amount of Eth. If you submit too much Eth, the contract will send the remaining Eth back to you. You can check the `price` function to see the current minting fee.

## Simp Powerlevel

Every 24 hours, your simps emit 10 Moon Power Tokens (MPT). These Power Tokens can be burned to increase your simps' on-chain powerlevel. A higher powerlevel increases the chances of your simp to survive in combat during the upcoming Simp Wars.

To increase the powerlevel, call the `powerup` function with the simp ID and the amount of Powerup Tokens you would like to burn. You can powerup simps that you own yourself, and also your friend's simps that have `powerupAccepted` set to true.

### Contract Address

The contract is not yet deployed. This will happen live on stream at a future date. Please join the [Discord Server](https://discord.gg/VH2haTs) for announcements.

## How to deploy

This is a [Hardhat](https://hardhat.org) project. To deploy (for example on Rinkeby) run 

```
npx hardhat run --network rinkeby scripts/deploy.js
```

You should see something like

```
Deploying Powertoken...
Deploying SimpWars...
Linking Contracts...
Done.
--------------------------------------------------------------------
PowerToken deployed to: 0xB579DaBB15Db575aac99659aae36D8e8Dea0671B
SimpWars deployed to:   0xf4AEfC4ed943C23FECE3dE15c406Bc79c7d95710
--------------------------------------------------------------------
```

You can then verify the contracts on Etherscan with

```
npx hardhat verify --network rinkeby POWERTOKEN_ADDRERSS
npx hardhat verify --network rinkeby SIMPWARS_ADDRESS "POWERTOKEN_ADDRERSS"
```

## Running tests

The tests can be run with 

```
npx hardhat test
```
