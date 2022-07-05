import { ethers } from "ethers";
import { ChainType } from "../types";
import { abi as AbiErc721 } from "../abis/erc721";
import { getCollectionContractAddress } from './network';
import { getMarketContractAddress } from "./network";

export const getCollectionContract = (
    chainType: ChainType,
    provider: ethers.providers.Provider
): ethers.Contract => {
    return new ethers.Contract(getCollectionContractAddress(chainType), AbiErc721, provider);
}

export const getMaxSupply = async (
    contract: ethers.Contract,
): Promise<number> => {
    try {
        return await contract.MAX_NFTs();
    } catch (e) {
        console.log("getMaxSupply error == ", e);
    }
    return 10000;
}

export const getNFTBalance = async (
    contract: ethers.Contract,
    wallet: string
): Promise<number> => {
    try {
        return await contract.balanceOf(wallet);
    } catch (e) {
        console.log("getNFTBalance error == ", e);
    }
    return 0;
}

export const getOwnerOf = async (
    contract: ethers.Contract,
    tokenId: number
): Promise<string> => {
    try {
        return await contract.ownerOf(tokenId);
    } catch (e) {
        console.log("getNFTBalance error == ", e);
    }
    return "";
}

export const getTokenURI = async (
    contract: ethers.Contract,
    tokenId: number
): Promise<string> => {
    try {
        return await contract.tokenURI(tokenId);
    } catch (e) {
        console.log("getTokenURI error == ", e);
    }
    return "";
}

export const getNFTItems = async (
    contract: ethers.Contract,
    wallet: string
): Promise<Array<number>> => {
    let nfts = new Array();
    let maxSupply = await getMaxSupply(contract);

    try {
        for (let i = 0; i < maxSupply; i++) {
            let owner = await getOwnerOf(contract, i);
            if (owner == wallet)
                nfts.push(i);
        }
    } catch (e) {
        console.log("getTokenURI error == ", e);
    }
    return nfts;
}

export const approveTokenToMarket = async (
    chainType: ChainType,
    contract: ethers.Contract,
    tokenId: number
): Promise<boolean> => {
    try {
        await contract.approve(getMarketContractAddress(chainType), tokenId);
        return true;
    } catch (e) {
        console.log("getTokenURI error == ", e);
    }
    return false;
}