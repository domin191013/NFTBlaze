/* eslint-disable prettier/prettier */
import { ethers } from "ethers";
import {
    ChainType,
    getProvider,
    getMarketContract
} from "../src";

const main = async () => {
    let provider = getProvider(ChainType.TestNet);
    let marketContract: ethers.Contract = getMarketContract(ChainType.TestNet, provider);

    console.log(provider);
    console.log(marketContract);
}

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
