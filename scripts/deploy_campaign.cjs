const hre = require("hardhat");

async function main() {
  const tokenAddress = "0xe8d15560f5ff9C0039283877c0809Aec4A5826aB"; // UAHToken on Polygon
  const beneficiary = "0xCdfbf5483eeA774dC27a8567644826c6C3397083"; // TreasuryV2 on Polygon
  const target = hre.ethers.parseUnits("24081991", 18);
  const deadline = Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60;
  const name = "Support Ukraine";
  const description = "Humanitarian aid for displaced families and medical support";

  const Campaign = await hre.ethers.deployContract("Campaign", [
    tokenAddress,
    beneficiary,
    target,
    deadline,
    name,
    description,
  ]);

  await Campaign.waitForDeployment();

  console.log("✅ Campaign deployed to:", await Campaign.getAddress());
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exitCode = 1;
});