const hre = require("hardhat");
const { getAddress } = require("ethers"); // добавлено для корректной проверки адреса

async function main() {
  const tokenAddress = "0xA53DC48E46c86Cb67FaE00A6749fd1dFF5C09987"; // UAHTokenV2 на BSC
  const timelockAddress = "0x039cF31D760e7EE1641E2eF6B7a08b8c0a2d9c93"; // TimelockController на BSC
  const endpoint = getAddress("0x3c2269811836af69497e5f486a85d3a3ffffa7ba"); // LayerZero endpoint для BSC

  const deployer = (await hre.ethers.getSigners())[0].address;

  // 1. DonorBadge
  console.log("🎖 Deploying DonorBadge...");
  const Badge = await hre.ethers.getContractFactory("DonorBadge");
  const badge = await Badge.deploy();
  await badge.waitForDeployment();
  const badgeAddress = await badge.getAddress();
  console.log("✅ DonorBadge deployed at:", badgeAddress);

  // 2. DAO
  console.log("🏛 Deploying DAO...");
  const DAO = await hre.ethers.getContractFactory("DAO");
  const dao = await DAO.deploy(tokenAddress, timelockAddress, badgeAddress);
  await dao.waitForDeployment();
  const daoAddress = await dao.getAddress();
  console.log("✅ DAO deployed at:", daoAddress);

  // 3. Treasury
  console.log("💰 Deploying Treasury...");
  const Treasury = await hre.ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy(daoAddress, badgeAddress);
  await treasury.waitForDeployment();
  const treasuryAddress = await treasury.getAddress();
  console.log("✅ Treasury deployed at:", treasuryAddress);

  // 4. CampaignFactory
  console.log("🏗 Deploying CampaignFactory...");
  const Factory = await hre.ethers.getContractFactory("CampaignFactory");
  const factory = await Factory.deploy(daoAddress);
  await factory.waitForDeployment();
  const factoryAddress = await factory.getAddress();
  console.log("✅ CampaignFactory deployed at:", factoryAddress);

  // 5. CrossChainBridge
  console.log("🌉 Deploying CrossChainBridge...");
  const Bridge = await hre.ethers.getContractFactory("CrossChainBridge");
  const bridge = await Bridge.deploy(endpoint, tokenAddress, daoAddress);
  await bridge.waitForDeployment();
  const bridgeAddress = await bridge.getAddress();
  console.log("✅ CrossChainBridge deployed at:", bridgeAddress);
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exitCode = 1;
});