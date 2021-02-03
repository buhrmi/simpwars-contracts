async function main() {
  // We get the contract to deploy
  const PowerToken = await ethers.getContractFactory("PowerToken");
  const powerToken = await PowerToken.deploy();
  const powerTokenContract = await powerToken.deployed();
  const SimpWars = await ethers.getContractFactory("SimpWars");
  const simpWars = await SimpWars.deploy(powerTokenContract.address);
  const simpWarsContract = await simpWars.deployed();
  await powerTokenContract.setSimpsAddress(simpWarsContract.address);

  console.log("SimpWars deployed to:", simpwars.address);
  console.log("PowerToken deployed to:", powerToken.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });