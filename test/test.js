const { expect } = require("chai");
const Web3 = require("web3")
var abi = require('ethereumjs-abi');
// const { ethers } = require("ethers");
// const { ethers } = require("ethers");

describe("SimpWars", function() {
  it("should send excess ether back", async function() {
    const address = (await ethers.getSigners())[0].address;

    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpwars = await SimpWars.deploy("0x0000000000000000000000000000000000000000");
    
    const contract = await simpwars.deployed();

    
    await contract.purchase(2387476, {value: Web3.utils.toWei('5', 'ether')})
  
    const owner = await contract.ownerOf(2387476);

    expect(owner).to.equal(address);
    expect(await ethers.provider.getBalance(contract.address)).to.equal(0)

  });

  it("should not be possible to purchase simps at a too low price", async function() {
    const address = (await ethers.getSigners())[0].address;

    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpwars = await SimpWars.deploy("0x0000000000000000000000000000000000000000");
    
    await simpwars.deployed();
    const price = await simpwars.price();
  
    await simpwars.purchase(2387476, {value: 0})
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
    await simpwars.purchase(2387476, {value: priceAsHex})

    const url = await simpwars.tokenURI(2387476);

    expect(url).to.equal('https://simpwars.loca.lt/metadata/twitch/2387476')
  });

  it("price increases and falls off", async function() {
    const address = (await ethers.getSigners())[0].address;
    
    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpwars = await SimpWars.deploy("0x0000000000000000000000000000000000000000");
    await simpwars.deployed();
    
    // Check initial price and make a purchase
    const initialPrice = await simpwars.price();
    expect(initialPrice).to.equal(Web3.utils.toWei('1', 'ether'));
    await simpwars.purchase(2387476, {value: initialPrice})
    const owner = await simpwars.ownerOf(2387476);
    expect(owner).to.equal(address);

    // Check next price to have increased by 1 eth
    const nextPrice = await simpwars.price();
    expect(nextPrice).to.be.below(Web3.utils.toWei('2', 'ether'));
    expect(nextPrice).to.be.above(Web3.utils.toWei('1.999', 'ether'));
   
    // Check for price to be less than 2 eth after a few blocks
    await simpwars.setUpgradeAccepted(2387476, {value: initialPrice}); // make a tx to advance time
    let finalPrice = await simpwars.price();
    console.log(finalPrice.toString());
    expect(finalPrice).to.be.below(nextPrice);

  });

  // it("emits 10 upgrade tokens per day that can be claimed", async function() {
  //   throw new Error("not implemented")
  // });

  // it("allows upgrades from owner", async function() {
  //   throw new Error("not implemented")
  // });

  // it("allows upgrades from anyone", async function() {
  //   throw new Error("not implemented")
  // });
});