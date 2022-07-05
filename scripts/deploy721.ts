// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, run } from "hardhat";

const verifyContract = async (contract: any) => {
  await new Promise((resolve) => {
    setTimeout(resolve, 15000);
  });

  try {
    await run("verify:verify", {
      address: contract.address,
      constructorArguments: [],
    });
    console.log("Contract verified");
  } catch (e) {
    console.log("Contract verification error occurred : ", e);
  }
};

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const TestERC721 = await ethers.getContractFactory("TestERC721");
  const contract = await TestERC721.deploy();

  await contract.deployed();
  console.log("TestErc721 deployed to:", contract.address);

  await verifyContract(contract);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
