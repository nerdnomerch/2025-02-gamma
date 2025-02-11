// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const fs = require('node:fs');

async function main() {
  const GmxProxy = await hre.ethers.getContractFactory("GmxProxy");
  const gmxProxy = await upgrades.deployProxy(
    GmxProxy,
    [
      "0xB0Fc2a48b873da40e7bc25658e5E6137616AC2Ee",     // GMX OrderHandler
      "0x08A902113F7F41a8658eBB1175f9c847bf4fB9D8",     // GMX LiquidationHandler
      "0x26BC03c944A4800299B4bdfB5EdCE314dD497511",     // GMX AdlHandler
      "0x69C527fC77291722b52649E45c838e41be8Bf5d5",     // GMX ExchangeRouter
      "0x7452c558d45f8afC8c83dAe62C3f8A5BE19c71f6",     // GMX Router
      "0xFD70de6b91282D8017aA4E741e9Ae325CAb992d8",     // GMX DataStore
      "0x31eF83a530Fde1B38EE9A18093A333D8Bbbc40D5",     // GMX OrderVault
      "0x5Ca84c34a381434786738735265b9f3FD814b824",     // GMX Reader
      "0xe6fab3F0c7199b0d34d7FbE83394fc0e0D06e99d"      // GMX ReferralStorage
    ]
  );

  await gmxProxy.waitForDeployment();
  const deployedAddress = await gmxProxy.getAddress();
  console.log(`GmxProxy deployed at ${deployedAddress}`);
  await hre.run("verify:verify", {
    address: deployedAddress,
    constructorArguments: []
  });

  const data = fs.readFileSync('./scripts/config.json', 'utf-8');
  let jsonData = JSON.parse(data);
  jsonData.gmxUtilsAddress = deployedAddress;
  fs.writeFileSync('./scripts/config.json', JSON.stringify(jsonData), 'utf-8');

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
