const hre = require("hardhat");

async function main() {
  // ✅ Адрес кошелька с правильной контрольной суммой
  const owner = "0x12A3dE2375C0330ef3aaDf6Bb6c02A7D9c8a319C"; // ← твой MetaMask-адрес
  const badgeAddress = "0x14BaE893904Ce74C43f979546E0254bB5A4a0c93"; // ← адрес DonorBadge

  const TreasuryV2 = await hre.ethers.deployContract("TreasuryV2", [owner, badgeAddress]);
  await TreasuryV2.waitForDeployment();

  console.log("✅ TreasuryV2 deployed to:", TreasuryV2.target);
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exitCode = 1;
});