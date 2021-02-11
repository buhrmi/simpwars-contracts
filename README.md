# Tokenized Streamers

This repo contains the smart contract that allows anyone to tokenize Twitch streamers on the Ethereum blockchain. A tokenized streamer is called a simp. Simps are needed to fight against the forces of the FUD in the upcoming [SimpWars](https://github.com/buhrmi/simpwars).

Anyone can mint new simps for a small minting fee. This fee starts at 0.1 ETH and logarithmically decreases by 50% every 24 hours (but never below 0.1 ETH), and doubles every time a new simp is minted.

To mint a simp, call the `mint` function with the Twitch User ID and pay the required amount of ETH. If you submit too much Eth, the contract will send the remaining ETH back to you. You can check the `price` function to see the current minting fee. Each simp is unique and can exist only **once**. No simps are pre-minted. 

All your simps mine 10 Moon Tokens per day.

## Moon Tokens

Moon Tokens are ERC20 tokens that can be burned to increase your simps' on-chain powerlevel. A higher powerlevel increases the chances of your simps to survive in combat against the forces of the FUD. Simps mine Moon Tokens for you on a daily basis. You can check how many Moon Tokens they have mined with the `accumulated(simpID)` function. You can claim all mined tokens at once by calling the `claimAll()` function.

To increase a simp's powerlevel, call the `powerup(simpID, amount)` function with the amount of tokens you would like to burn. You can powerup not only your own simps, but also your friend's simps if they have `powerupAccepted` set to true.


### The Calamity

At one point in the future, a calamity will be triggered and the moon will explode. When that happens, no new Moon Tokens can be mined anymore. This is a random event that can occur at any point in time which can not be predicted. After the calamity occured, Moon Tokens can only be burned, but not mined. The amount of Moon Tokens will slowly decrease, until one day the last Moon Token has been used up.

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
