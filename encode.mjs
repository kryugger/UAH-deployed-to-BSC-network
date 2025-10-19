import { AbiCoder } from "ethers";

const abi = new AbiCoder();

const types = [
  "uint256",
  "address[]",
  "address[]",
  "address"
];

const args = [
  3600,
  ["0x12A3dE2375C0330ef3aaDf6Bb6c02A7D9c8a319C"],
  ["0x12A3dE2375C0330ef3aaDf6Bb6c02A7D9c8a319C"],
  "0x12A3dE2375C0330ef3aaDf6Bb6c02A7D9c8a319C"
];

const encoded = abi.encode(types, args);
console.log(encoded);