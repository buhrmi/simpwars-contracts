const { expect } = require("chai");
const Web3 = require("web3")
var abi = require('ethereumjs-abi');
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
    const price = await simpwars.price(2387476);
  
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

    const price = await simpwars.price(2387476);
    const priceAsHex = price.toHexString();
    await simpwars.purchase(2387476, {value: priceAsHex})

    const url = await simpwars.tokenURI(2387476);

    expect(url).to.equal('https://simpwars.loca.lt/metadata/twitch/2387476')
  });

  it("price should be calculated the same with javascript", async function() {
    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpwars = await SimpWars.deploy("0x0000000000000000000000000000000000000000");
    const provider = ethers.provider
    await simpwars.deployed();

    const streamerID =2387476
    const price = await simpwars.price(streamerID);
  
    const maxPrice = new Web3.utils.BN(Web3.utils.toWei('5', 'ether'))
    
    const blockNumber = await provider.getBlockNumber()

    let shouldPrice = Web3.utils.toBN(abi.soliditySHA3(["int", "int"],[streamerID, blockNumber]).toString('hex')).mod(maxPrice)
    let prevPrice = Web3.utils.toBN(abi.soliditySHA3(["int", "int"],[streamerID, blockNumber-1]).toString('hex')).mod(maxPrice)
    
    if (shouldPrice.cmp(prevPrice) == 1) shouldPrice = prevPrice;

    expect(price.toHexString()).to.equal('0x' + shouldPrice.toString(16).padStart(16,'0'))
  })

  it("pricing function can be swapped", async function() {
    const address = (await ethers.getSigners())[0].address;
    
    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpwars = await SimpWars.deploy("0x0000000000000000000000000000000000000000");
    await simpwars.deployed();

    const AltPricing = await ethers.getContractFactory("AltPricing");
    const altPricer = await AltPricing.deploy();
    await altPricer.deployed();
    
    await simpwars.setPricer(altPricer.address);

    await simpwars.purchase(2387476, {value: 12344})
    .then(function(m) {
      throw new Error('was not supposed to succeed');
    })
    .catch(function(m) {
      expect(m.message).to.equal('Transaction reverted: function call failed to execute')
    })

    await simpwars.purchase(2387476, {value: 12345});

    const owner = await simpwars.ownerOf(2387476);

    expect(owner).to.equal(address);
  });


  it("emits 10 upgrade tokens per day that can be claimed", async function() {
    throw new Error("not implemented")
  });

  it("allows upgrades from owner", async function() {
    throw new Error("not implemented")
  });

  it("allows upgrades from anyone", async function() {
    throw new Error("not implemented")
  });
});