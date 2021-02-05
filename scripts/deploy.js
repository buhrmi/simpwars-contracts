async function main() {
  // We get the contract to deploy
  console.log("Deploying Powertoken...")
  const PowerToken = await ethers.getContractFactory("MoonPowerToken");
  const powerToken = await PowerToken.deploy();
  const powerTokenContract = await powerToken.deployed();
  console.log("PowerToken deployed to:", powerToken.address);
  console.log("Deploying SimpWars...")
  const SimpWars = await ethers.getContractFactory("SimpWars");
  const simpWars = await SimpWars.deploy(powerTokenContract.address);
  const simpWarsContract = await simpWars.deployed();
  console.log("SimpWars deployed to:  ", simpWars.address);
  console.log("Linking Contracts...")
  await powerTokenContract.setSimpsAddress(simpWarsContract.address);
  console.log("Done.")

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });