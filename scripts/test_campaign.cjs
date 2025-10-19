const hre = require("hardhat");

async function main() {
  // Адрес CampaignFactory с правильной контрольной суммой
  const factoryAddress = "0xb9cC2C40dCc25bC63c35788D5218578b759d3456";

  // Параметры кампании
  const tokenAddress = "0xe8d15560f5ff9C0039283877c0809Aec4A5826aB"; // UAHToken
  const beneficiary = "0xF899d1C160c822d59558640739003Bb44c2C2cB3"; // DAO
  const target = hre.ethers.parseUnits("1000", 18); // 1000 UAH
  const deadline = Math.floor(Date.now() / 1000) + 7 * 24 * 60 * 60; // 7 дней от текущего времени
  const name = "UAH for Schools";
  const description = "Сбор средств на школьные инициативы в Украине";

  // Подключение к фабрике
  const factory = await hre.ethers.getContractAt("CampaignFactory", factoryAddress);
  console.log("📦 Connected to CampaignFactory at:", factoryAddress);

  // Вызов функции создания кампании
  const tx = await factory.createCampaign(tokenAddress, beneficiary, target, deadline, name, description);
  console.log("⏳ Transaction sent. Waiting for confirmation...");

  // Ожидание подтверждения
  const receipt = await tx.wait();
  console.log("✅ Campaign created. TX hash:", receipt.hash);

  // Попытка извлечь адрес новой кампании из события (если оно есть)
  const logs = receipt.logs;
  const iface = new hre.ethers.Interface([
    "event CampaignCreated(address indexed creator, address campaignAddress)"
  ]);

  const event = logs.map(log => {
    try {
      return iface.parseLog(log);
    } catch {
      return null;
    }
  }).find(e => e && e.name === "CampaignCreated");

  if (event) {
    console.log("🆕 New campaign deployed at:", event.args.campaignAddress);
  } else {
    console.log("⚠️ No CampaignCreated event found. Проверь контракт на наличие события.");
  }
}

main().catch((error) => {
  console.error("❌ Error:", error);
  process.exitCode = 1;
});