// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const fs = require('node:fs');

async function main() {
  const accounts = await ethers.getSigners();

  const data = fs.readFileSync('./scripts/config.json', 'utf-8');
  const jsonData = JSON.parse(data);
  
  const PerpetualVault = await hre.ethers.getContractFactory("PerpetualVault", {
    libraries: {
      ParaSwapUtils: jsonData.paraswapUtilsAddress
    }
  });
  const keeper = jsonData.keeperProxyAddress;
  const treasury = accounts[0].address;
  const perpetualVault = await upgrades.deployProxy(
    PerpetualVault,
    [
      "0x70d95587d40A2caf56bd97485aB3Eec10Bee6336",
      keeper,
      treasury,
      jsonData.gmxUtilsAddress,
      jsonData.vaultReaderAddress,
      "100000000",
      "10000000000000000000000000000"
    ],
    {
      unsafeAllowLinkedLibraries: true
    }
  );

  await perpetualVault.waitForDeployment();
  const deployedAddress = await perpetualVault.getAddress();
  console.log(`PerpetualVault deployed at ${deployedAddress}`);
  await hre.run("verify:verify", {
    address: deployedAddress,
    constructorArguments: []
  });

  jsonData.perpVaultAddress = deployedAddress;
  fs.writeFileSync('./scripts/config.json', JSON.stringify(jsonData), 'utf-8');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
