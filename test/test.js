const { expect } = require("chai");
const Web3 = require("web3")
var abi = require('ethereumjs-abi');

describe("SimpWars", function() {
  it("should send excess ether back", async function() {
    const address = (await ethers.getSigners())[0].address;

    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpwars = await SimpWars.deploy("0x0000000000000000000000000000000000000000");
    
    const contract = await simpwars.deployed();

    
    await contract.mint(2387476, {value: Web3.utils.toWei('5', 'ether')})
  
    const owner = await contract.ownerOf(2387476);

    expect(owner).to.equal(address);
    expect(await ethers.provider.getBalance(contract.address)).to.equal(0)

  });

  it("should not be possible to mint simps at a too low price", async function() {
    const address = (await ethers.getSigners())[0].address;

    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpwars = await SimpWars.deploy("0x0000000000000000000000000000000000000000");
    
    await simpwars.deployed();
    const price = await simpwars.price();
  
    await simpwars.mint(2387476, {value: 0})
      .then(function(m) {
        throw new Error('was not supposed to succeed');
      })
      .catch(function(m) {
        expect(m.message).to.equal('Transaction reverted: function call failed to execute')
      })
  });

  it("should return the correct metadata URL", async function() {
    const address = (await ethers.getSigners())[0].address;
    
    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpwars = await SimpWars.deploy("0x0000000000000000000000000000000000000000");
    
    await simpwars.deployed();

    const price = await simpwars.price();
    const priceAsHex = price.toHexString();
    await simpwars.mint(2387476, {value: priceAsHex})

    const url = await simpwars.tokenURI(2387476);

    expect(url).to.equal('https://simpwars.loca.lt/metadata/twitch/2387476')
  });

  it("price increases and falls off", async function() {
    const address = (await ethers.getSigners())[0].address;
    
    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpwars = await SimpWars.deploy("0x0000000000000000000000000000000000000000");
    await simpwars.deployed();
    
    // Check initial price and make a mint
    const initialPrice = await simpwars.price();
    expect(initialPrice).to.equal(Web3.utils.toWei('1', 'ether'));
    await simpwars.mint(2387476, {value: initialPrice})
    const owner = await simpwars.ownerOf(2387476);
    expect(owner).to.equal(address);

    // Check next price to have increased by 1 eth
    const nextPrice = await simpwars.price();
    expect(nextPrice).to.be.below(Web3.utils.toWei('2', 'ether'));
    expect(nextPrice).to.be.above(Web3.utils.toWei('1.999', 'ether'));
   
    // Check for price to be less than 2 eth after a few blocks
    await simpwars.setPowerupAccepted(2387476, true); // make a tx to advance time
    let finalPrice = await simpwars.price();
    expect(finalPrice).to.be.below(nextPrice);

  });

  it("emits 10 power tokens per day that can be claimed", async function() {
    const address = (await ethers.getSigners())[0].address;

      const PowerToken = await ethers.getContractFactory("PowerToken");
      const powerToken = await PowerToken.deploy();
      const powerTokenContract = await powerToken.deployed();

      const SimpWars = await ethers.getContractFactory("SimpWars");
      const simpWars = await SimpWars.deploy(powerTokenContract.address);
      const simpWarsContract = await simpWars.deployed();

      await powerTokenContract.setSimpsAddress(simpWarsContract.address);

      await simpWarsContract.mint(2387476, {value: Web3.utils.toWei('5', 'ether')})
   
      await simpWars.setPowerupAccepted(2387476, true); // make a tx to advance time by 1s
      
      const timestamp1 = (await simpWars.mintedTimestamp(2387476))      
      let timestamp2 = (await ethers.provider.getBlock()).timestamp
      let elapsed = timestamp2 - timestamp1
      let claimable = await powerToken.accumulated(2387476);
      const claimedPerSecond = 115740740740740.74
 
      expect(claimable).to.equal(Math.floor(claimedPerSecond * elapsed));

      await powerToken.claimAll();
      claimable = await powerToken.accumulated(2387476);
      expect(claimable).to.equal(0);
      
      timestamp2 = (await ethers.provider.getBlock()).timestamp
      elapsed = timestamp2 - timestamp1
      const balance = await powerToken.balanceOf(address)
      
      expect(balance).to.equal(Math.floor(claimedPerSecond * elapsed));

  });

  it("accepts Power Tokens for powerups", async function() {
    const [owner, account2] = (await ethers.getSigners())
    const PowerToken = await ethers.getContractFactory("PowerToken");
    const powerToken = await PowerToken.deploy();
    const powerTokenContract = await powerToken.deployed();
    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpWars = await SimpWars.deploy(powerTokenContract.address);
    const simpWarsContract = await simpWars.deployed();
    await powerTokenContract.setSimpsAddress(simpWarsContract.address);
    await simpWarsContract.mint(2387476, {value: Web3.utils.toWei('5', 'ether')})
    await simpWars.setPowerupAccepted(2387476, true); // make a tx to advance time by 1s
    await powerToken.claimAll();

    const useBalance = 10000
    const balance = await powerToken.balanceOf(owner.address)
    await simpWars.powerup(2387476, useBalance)

    const remainingBalance = await powerToken.balanceOf(owner.address);
    expect(remainingBalance).to.equal(balance - useBalance);

    const powerup = await simpWars.getPowerlevel(2387476)
    expect(powerup).to.equal(useBalance);

    await simpWars.powerup(2387476, balance)
      .then(function(m) {
        throw new Error('was not supposed to succeed');
      })
      .catch(function(m) {
        expect(m.message).to.equal('VM Exception while processing transaction: revert ERC20: transfer amount exceeds balance')
      })
    
  });

});