const { ethers } = require("hardhat");

async function main() {
  const DonorBadge = await ethers.deployContract("DonorBadge", []);
  await DonorBadge.waitForDeployment();

  console.log("✅ DonorBadge deployed to:", DonorBadge.target);
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exitCode = 1;
});