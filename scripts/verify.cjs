// scripts/verify.cjs
const { run } = require("hardhat");

async function main() {
  const contractAddress = "0x14BaE893904Ce74C43f979546E0254bB5A4a0c93";
  const constructorArgs = [
    "24081991000000000000000000", // initialSupply
    "0x12A3dE2375C0330ef3aaDf6Bb6c02A7D9c8a319C" // owner
  ];

  console.log("🔍 Verifying contract on Polygon...");
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: constructorArgs,
      network: "polygon"
    });
    console.log("✅ Verification complete");
  } catch (err) {
    console.error("❌ Verification failed:", err.message);
  }
}

main();