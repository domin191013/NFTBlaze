// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, run } from "hardhat";

const verifyContract = async (contract: any, args: any) => {
  await new Promise((resolve) => {
    setTimeout(resolve, 25000);
  });

  try {
    await run("verify:verify", {
      address: contract.address,
      constructorArguments: args,
    });
    console.log("Contract verified");
  } catch (e) {
    console.log("Contract verification error occurred : ", e);
  }
};

const deployContract = async (contractName: string, args: any) => {
  console.log(`⌛ Deploying ${contractName}...`);

  const consumerFactory = await ethers.getContractFactory(contractName);

  const contract = await consumerFactory.deploy(...args);
  await contract.deployed();

  await verifyContract(contract, args);

  console.log(`✅ Deployed ${contractName} to ${contract.address}`);
};

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  await deployContract("SingleMarketplace", [
    "0x0F0b394C98851A7A82028DBAAB1ed1b997f873EC",
  ]);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
