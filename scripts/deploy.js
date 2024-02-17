const hre = require("hardhat");

async function main() {
  const VotingSystem = await hre.ethers.getContractFactory('VotingSystem');
  const votingSystem = await VotingSystem.deploy();

  const address = await votingSystem.waitForDeployment();
  console.log("Voting system deployed: ", address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
