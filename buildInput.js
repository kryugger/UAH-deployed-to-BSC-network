const fs = require("fs");
const path = require("path");

const sourceDir = path.join(__dirname, "sources");
const files = fs.readdirSync(sourceDir).filter(f => f.endsWith(".sol"));

const sources = {};

files.forEach(file => {
  const content = fs.readFileSync(path.join(sourceDir, file), "utf8");
  sources[file] = { content };
});

const input = {
  language: "Solidity",
  sources,
  settings: {
    optimizer: { enabled: true, runs: 50 },
    outputSelection: {
      "*": {
        "*": ["abi", "evm.bytecode", "evm.deployedBytecode"]
      }
    }
  }
};

fs.writeFileSync("input.json", JSON.stringify(input, null, 2));
console.log("✅ input.json создан");