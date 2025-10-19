const { getAddress } = require("ethers");

module.exports = [
  3600,
  [
    getAddress("0xc83722a728f0ea08d2dc0e5af243b49cd0255cc0"),
    getAddress("0xb5515cfc27ef952e0a39f2f1667deeac0cc4947c")
  ],
  [
    getAddress("0xc83722a728f0ea08d2dc0e5af243b49cd0255cc0"),
    getAddress("0xa53dc48e46c86cb67fae00a6749fd1dff5c09987")
  ],
  getAddress("0x12a3de2375c0330ef3aadf6bb6c02a7d9c8a319c")
];