const { expect } = require("chai");

describe("SimpWars", function() {
  it("should be possible to purchase simps for correct price", async function() {
    const address = (await ethers.getSigners())[0].address;

    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpwars = await SimpWars.deploy();
    
    await simpwars.deployed();
    const price = await simpwars.price(2387476);
    const priceAsHex = price.toHexString();

    await simpwars.purchase(2387476, {value: priceAsHex})
  
    const owner = await simpwars.ownerOf(2387476);

    expect(owner).to.equal(address);
  });

  it("should not be possible to purchase simps at a too low price", async function() {
    const address = (await ethers.getSigners())[0].address;

    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpwars = await SimpWars.deploy();
    
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

  // it("should return be possible to purchase simps at a too low price", async function() {
  //   const address = (await ethers.getSigners())[0].address;

  //   const SimpWars = await ethers.getContractFactory("SimpWars");
  //   const simpwars = await SimpWars.deploy();
    
  //   await simpwars.deployed();
    
  //   await simpwars.purchase(2387476, {value: 0})
  //   .then(function(m) {
  //     throw new Error('was not supposed to succeed');
  //   })
  //   .catch(function(m) {
  //     expect(m.message).to.equal('Transaction reverted: function call failed to execute')
  //   })
  // });
  
  
  it("should return the correct metadata URL", async function() {
    const address = (await ethers.getSigners())[0].address;
    
    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpwars = await SimpWars.deploy();
    
    await simpwars.deployed();

    const price = await simpwars.price(2387476);
    const priceAsHex = price.toHexString();
    await simpwars.purchase(2387476, {value: priceAsHex})

    const url = await simpwars.tokenURI(2387476);

    expect(url).to.equal('https://simpwars.loca.lt/metadata/twitch/2387476')
  });


});