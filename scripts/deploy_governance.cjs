require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("🚀 Deploying governance with:", deployer.address);

  // 1. Загружаем уже задеплоенный токен на BSC
  const tokenAddress = "0xA53DC48E46c86Cb67FaE00A6749fd1dFF5C09987"; // UAHTokenV2 on BSC
  const Token = await ethers.getContractAt("UAHToken", tokenAddress);

  // 2. Деплой TimelockController
  const minDelay = 3600; // 1 час
  const proposers = [];
  const executors = [];
  const Timelock = await ethers.getContractFactory("TimelockController");
  const timelock = await Timelock.deploy(minDelay, proposers, executors, deployer.address);
  await timelock.waitForDeployment();
  const timelockAddress = await timelock.getAddress();
  console.log("⏳ Timelock deployed to:", timelockAddress);

  // 3. Деплой Governance
  const Governance = await ethers.getContractFactory("Governance");
  const governance = await Governance.deploy(tokenAddress, timelockAddress);
  await governance.waitForDeployment();
  const governanceAddress = await governance.getAddress();
  console.log("🏛 Governance deployed to:", governanceAddress);

  // 4. Передача MINTER_ROLE Governance
  const MINTER_ROLE = await Token.MINTER_ROLE();
  const tx = await Token.grantRole(MINTER_ROLE, governanceAddress);
  await tx.wait();
  console.log("✅ MINTER_ROLE передан Governance:", governanceAddress);
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exitCode = 1;
});