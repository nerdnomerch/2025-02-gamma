// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const fs = require('node:fs');

async function main() {
  // deploy ParaSwapUtils contract
  const ParaSwapUtils = await hre.ethers.getContractFactory("ParaSwapUtils");
  const paraSwapUtils = await ParaSwapUtils.deploy();
  await paraSwapUtils.waitForDeployment();
  const deployedAddress = await paraSwapUtils.getAddress();
  console.log(`ParaSwapUtils deployed at ${deployedAddress}`);
  await hre.run("verify:verify", {
    address: deployedAddress,
    constructorArguments: []
  })

  // deploy MarketUtils contract
  const MarketUtils = await hre.ethers.getContractFactory("MarketUtils");
  const marketUtils = await MarketUtils.deploy();
  await marketUtils.waitForDeployment();
  const marketUtilsAddress = await marketUtils.getAddress();
  console.log(`MarketUtils deployed at ${marketUtilsAddress}`);
  await hre.run("verify:verify", {
    address: marketUtilsAddress,
    constructorArguments: []
  });

  const data = fs.readFileSync('./scripts/config.json', 'utf-8');
  const jsonData = JSON.parse(data);
  jsonData.paraswapUtilsAddress = deployedAddress;
  jsonData.marketUtilsAddress = marketUtilsAddress;
  fs.writeFileSync('./scripts/config.json', JSON.stringify(jsonData), 'utf-8');

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
