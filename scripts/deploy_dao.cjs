const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("🚀 Deploying DAO contracts with:", deployer.address);

  // 1. Подключаем уже задеплоенный UAHToken
  const tokenAddress = "0xe8d15560f5ff9C0039283877c0809Aec4A5826aB";
  const Token = await hre.ethers.getContractAt("UAHToken", tokenAddress);
  console.log("✅ UAHToken loaded at:", tokenAddress);

  // 2. Подключаем уже задеплоенный TimelockController
  const timelockAddress = "0xA53DC48E46c86Cb67FaE00A6749fd1dFF5C09987";
  const Timelock = await hre.ethers.getContractAt("TimelockController", timelockAddress);
  console.log("⏳ TimelockController loaded at:", timelockAddress);

  // 3. Подключаем уже задеплоенный DonorBadge
  const badgeAddress = "0x14BaE893904Ce74C43f979546E0254bB5A4a0c93";
  console.log("🎖 DonorBadge loaded at:", badgeAddress);

  // 4. Деплой DAO
  const DAO = await hre.ethers.getContractFactory("DAO");
  const dao = await DAO.deploy(tokenAddress, timelockAddress, badgeAddress);
  await dao.waitForDeployment();
  const daoAddress = await dao.getAddress();
  console.log("🏛 DAO deployed at:", daoAddress);

  // 5. Передаём роли DAO-контракту
  const PROPOSER_ROLE = await Timelock.PROPOSER_ROLE();
  const EXECUTOR_ROLE = await Timelock.EXECUTOR_ROLE();
  const MINTER_ROLE = await Token.MINTER_ROLE();

  console.log("🔐 Granting roles to DAO...");

  await Timelock.grantRole(PROPOSER_ROLE, daoAddress);
  await Timelock.grantRole(EXECUTOR_ROLE, daoAddress);
  await Token.grantRole(MINTER_ROLE, daoAddress);

  console.log("✅ Roles granted to DAO");

  // 6. Отзываем роли у deployer'а (по желанию)
  await Timelock.revokeRole(PROPOSER_ROLE, deployer.address);
  await Timelock.revokeRole(EXECUTOR_ROLE, deployer.address);
  await Token.revokeRole(MINTER_ROLE, deployer.address);
  console.log("🚫 Roles revoked from deployer");

  // 7. Передаём Treasury DAO-контракту
  const treasuryAddress = "0xCdfbf5483eeA774dC27a8567644826c6C3397083";
  const Treasury = await hre.ethers.getContractAt("TreasuryV2", treasuryAddress);
  await Treasury.transferOwnership(daoAddress);
  console.log("💼 DAO set as owner of Treasury");

  // 8. Проверка
  const treasuryOwner = await Treasury.owner();
  const hasMinter = await Token.hasRole(MINTER_ROLE, daoAddress);
  console.log("🔍 Treasury owner:", treasuryOwner);
  console.log("🔍 DAO has MINTER_ROLE:", hasMinter);
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exitCode = 1;
});