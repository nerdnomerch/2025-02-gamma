// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const config = require("../config.json");


async function main() {
  const PerpetualVault = await hre.ethers.getContractFactory("PerpetualVault", {
    libraries: {
      ParaSwapUtils: config.paraswapUtilsAddress
    }
  });
  const perpetualVault = await upgrades.upgradeProxy(config.perpVaultAddress, PerpetualVault, {
    unsafeAllowLinkedLibraries: true
  });
  await perpetualVault.waitForDeployment();
  
  const deployedAddress = await perpetualVault.getAddress();
  console.log(`PerpetualVault upgraded at ${deployedAddress}`);
  await hre.run("verify:verify", {
    address: deployedAddress,
    constructorArguments: []
  })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
