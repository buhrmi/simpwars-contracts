async function main() {
  // We get the contract to deploy
  const SimpWars = await ethers.getContractFactory("SimpWars");
  const simpwars = await SimpWars.deploy();

  console.log("SimpWars deployed to:", simpwars.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });