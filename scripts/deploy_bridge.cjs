const hre = require("hardhat");

async function main() {
  // 🔹 LayerZero endpoint для Polygon mainnet
  const endpoint = "0x1a44076050125825900e736c501f859c50fE728c";

  // 🔹 Адрес токена UAHToken
  const tokenAddress = "0xe8d15560f5ff9C0039283877c0809Aec4A5826aB";

  // 🔹 Адрес DAO-контракта
  const daoAddress = "0xc83722a728F0EA08D2Dc0e5aF243b49Cd0255cc0";

  // 🔍 Проверка на случай пропущенных адресов
  if (!endpoint || !tokenAddress || !daoAddress) {
    throw new Error("❌ One or more required addresses are missing.");
  }

  // 🚀 Деплой контракта CrossChainBridge
  const Bridge = await hre.ethers.getContractFactory("CrossChainBridge");
  const bridge = await Bridge.deploy(endpoint, tokenAddress, daoAddress);

  await bridge.waitForDeployment();
  console.log("🌉 CrossChainBridge deployed at:", await bridge.getAddress());
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exitCode = 1;
});