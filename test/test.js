const { expect } = require("chai");

describe("SimpWars", function() {
  it("Should give us a price for a Simp", async function() {
    const SimpWars = await ethers.getContractFactory("SimpWars");
    const simpwars = await SimpWars.deploy();
    
    await simpwars.deployed();
    const price = await simpwars.price(2387476);

    expect(ethers.BigNumber.isBigNumber(price)).to.be.true;
  });
});