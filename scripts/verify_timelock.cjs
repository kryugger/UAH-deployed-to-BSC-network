const hre = require("hardhat");

async function main() {
  await hre.run("verify:verify", {
    address: "0x20267D620bA911C4D553d5a139787dD333E0aD7C",
    constructorArguments: [
      3600,
      ["0x12A3dE2375C0330ef3aaDf6Bb6c02A7D9c8a319C"],
      ["0x12A3dE2375C0330ef3aaDf6Bb6c02A7D9c8a319C"],
      "0x12A3dE2375C0330ef3aaDf6Bb6c02A7D9c8a319C"
    ],
    contract: "@openzeppelin/contracts/governance/TimelockController.sol:TimelockController"
  });
}

main().catch((error) => {
  console.error("❌ Verification failed:", error);
  process.exitCode = 1;
});