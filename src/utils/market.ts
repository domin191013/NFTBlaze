import { ethers } from "ethers";
import { ChainType, SaleItem } from "../types";
import { abi as AbiMarket } from "../abis/market";
import { getMarketContractAddress } from "./network";

export const getMarketContract = (
    chainType: ChainType,
    provider: ethers.providers.Provider
): ethers.Contract => {
    return new ethers.Contract(getMarketContractAddress(chainType), AbiMarket, provider);
}

export const getNFTSaleItem = async (
    contract: ethers.Contract,
    tokenId: number
): Promise<SaleItem | null> => {
    try {
        return await contract.nfts(tokenId);
    } catch (e) {
        console.log("putToAuction error == ", e);
    }
    return null;
}

export const putToAuction = async (
    contract: ethers.Contract,
    tokenId: number,
    price: number,
    endTime: number
): Promise<boolean> => {
    try {
        await contract.putOnAuction(tokenId, price, endTime);
        return true;
    } catch (e) {
        console.log("putToAuction error == ", e);
    }
    return false;
}

export const bid = async (
    contract: ethers.Contract,
    amount: number,
    tokenId: number,
): Promise<boolean> => {
    try {
        await contract.bid(amount, tokenId);
        return true;
    } catch (e) {
        console.log("bid error == ", e);
    }
    return false;
}

export const endSale = async (
    contract: ethers.Contract,
    tokenId: number,
): Promise<boolean> => {
    try {
        await contract.endSale(tokenId);
        return true;
    } catch (e) {
        console.log("endSale error == ", e);
    }
    return false;
}

export const claim = async (
    contract: ethers.Contract,
    tokenId: number,
): Promise<boolean> => {
    try {
        await contract.claim(tokenId);
        return true;
    } catch (e) {
        console.log("claim error == ", e);
    }
    return false;
}

export const quitBid = async (
    contract: ethers.Contract,
    tokenId: number,
): Promise<boolean> => {
    try {
        await contract.quitBid(tokenId);
        return true;
    } catch (e) {
        console.log("quitBid error == ", e);
    }
    return false;
}