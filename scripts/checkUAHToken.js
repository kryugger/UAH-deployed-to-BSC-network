const { ethers } = require("ethers");
require("dotenv").config();

const tokenAddress = "0xA53DC48E46c86Cb67FaE00A6749fd1dFF5C09987";
const routerAddress = "0x10ED43C718714eb63d5aA57B78B54704E256024E";

// Вставь сюда ABI, который ты прислал
const tokenAbi = [ /* твой ABI сюда */ ];

async function main() {
  const provider = new ethers.JsonRpcProvider("https://bsc-dataseed.binance.org");
  const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const token = new ethers.Contract(tokenAddress, tokenAbi, signer);

  const paused = await token.paused();
  const feePercent = await token.feePercent();
  const burnPercent = await token.burnPercent();
  const licenseFee = await token.licenseFee();
  const allowance = await token.allowance(signer.address, routerAddress);
  const balance = await token.balanceOf(signer.address);
  const licensed = await token.licensedContracts(routerAddress);
  const adminRole = await token.DEFAULT_ADMIN_ROLE();
  const isAdmin = await token.hasRole(adminRole, signer.address);

  console.log("\n🔍 UAHTokenV2 Diagnostics:");
  console.log("🔹 paused:", paused);
  console.log("🔹 feePercent:", feePercent.toString());
  console.log("🔹 burnPercent:", burnPercent.toString());
  console.log("🔹 licenseFee (wei):", licenseFee.toString());
  console.log("🔹 allowance to router:", ethers.utils.formatUnits(allowance, 18));
  console.log("🔹 your balance:", ethers.utils.formatUnits(balance, 18));
  console.log("🔹 router licensed:", licensed);
  console.log("🔹 you are admin:", isAdmin);
}

main().catch((err) => {
  console.error("❌", err);
});