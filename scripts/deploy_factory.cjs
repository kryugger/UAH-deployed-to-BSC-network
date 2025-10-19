const hre = require("hardhat");
require("dotenv").config();

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const network = hre.network.name;

  console.log(`🚀 Deploying CampaignFactory to ${network}...`);
  console.log(`👤 Deployer address: ${deployer.address}`);

  const balance = await deployer.provider.getBalance(deployer.address);
  console.log(`💰 Deployer balance: ${hre.ethers.formatEther(balance)} ETH`);

  const CampaignFactory = await hre.ethers.getContractFactory("CampaignFactory");
  const factory = await CampaignFactory.deploy();

  const tx = await factory.deploymentTransaction();
  const receipt = await tx.wait();

  console.log(`✅ CampaignFactory deployed at: ${factory.target}`);
  console.log(`⛽ Gas used: ${receipt.gasUsed.toString()}`);
  console.log(`🔗 Explorer: https://polygonscan.com/address/${factory.target}`);
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exit(1);
});