/* eslint-disable prettier/prettier */
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { run, network, ethers } from "hardhat";

let erc721Contract: Contract;
let marketContract: Contract;

const deployContract = async (contractName: string, args: any) => {
  console.log(`⌛ Deploying ${contractName}...`);

  const consumerFactory = await ethers.getContractFactory(contractName);

  const contract = await consumerFactory.deploy(...args);
  await contract.deployed();

  console.log(`✅ Deployed ${contractName} to ${contract.address}`);
  return contract;
};

const displayNFT = async (tokenId: any) => {
  console.log("\n");
  console.log("List of nfts on marketplace");
  console.log(await marketContract.nfts(tokenId));
};

const displayNftBalance = async (address: string) => {
  console.log("\n");
  const balance = await erc721Contract.balanceOf(address);
  console.log(`Address ${address} have nft balance of ${balance}`);
};

const displayBalance = async (wallet: SignerWithAddress) => {
  console.log("\n");
  console.log(
    `Address ${wallet.address} have ether balance of ${await wallet.getBalance()}`
  );
};

const main = async () => {
  const [owner, buyer] = await ethers.getSigners();
  const tokenId = 1;

  erc721Contract = await deployContract("TestERC721", []);
  marketContract = await deployContract("SingleMarketplace", [
    erc721Contract.address,
  ]);

  await erc721Contract.setBaseURI(
    "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/"
  );
  await erc721Contract.freeMintMultiple(5);

  await erc721Contract.approve(marketContract.address, tokenId);
  await marketContract.putOnAuction(tokenId, 1, 1685809757);

  await displayNFT(tokenId);

  const txn = await marketContract
    .connect(buyer)
    .bid(tokenId, { value: ethers.utils.parseEther("0.9") });
  await txn.wait();

  await displayNFT(tokenId);

  console.log("End Sale");
  await marketContract.endSale(tokenId);
  await displayNFT(tokenId);

  await marketContract.connect(buyer).claim(tokenId);

  await displayNftBalance(owner.address);
  await displayBalance(owner);

  await displayNftBalance(buyer.address);
  await displayBalance(buyer);
};

const runMain = async () => {
  try {
    await main();
    process.exitCode = 0;
  } catch (error) {
    console.log(error);
    process.exitCode = 1;
  }
};

runMain();
