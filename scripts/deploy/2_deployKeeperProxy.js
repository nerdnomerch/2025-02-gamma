// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const fs = require('node:fs');

async function main() {
  const KeeperProxy = await hre.ethers.getContractFactory("KeeperProxy");
  const keeperProxy = await upgrades.deployProxy(KeeperProxy, []);

  await keeperProxy.waitForDeployment();
  const deployedAddress = await keeperProxy.getAddress();
  console.log(`KeeperProxy deployed at ${deployedAddress}`);
  await hre.run("verify:verify", {
    address: deployedAddress,
    constructorArguments: []
  });

  const data = fs.readFileSync('./scripts/config.json', 'utf-8');
  let jsonData = JSON.parse(data);
  jsonData.keeperProxyAddress = deployedAddress;
  fs.writeFileSync('./scripts/config.json', JSON.stringify(jsonData), 'utf-8');

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
