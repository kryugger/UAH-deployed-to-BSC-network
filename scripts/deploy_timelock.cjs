const hre = require("hardhat");

async function main() {
  const minDelay = 3600; // задержка в секундах (1 час)
  const admin = "0x12A3dE2375C0330ef3aaDf6Bb6c02A7D9c8a319C"; // адрес администратора
  const proposers = [admin]; // кто может предлагать
  const executors = [admin]; // кто может исполнять

  console.log("⏳ Deploying TimelockController...");
  const Timelock = await hre.ethers.getContractFactory("TimelockController");
  const timelock = await Timelock.deploy(minDelay, proposers, executors, admin);

  await timelock.waitForDeployment();
  console.log("✅ TimelockController deployed to:", await timelock.getAddress());
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exitCode = 1;
});