/* eslint-disable prettier/prettier */
import { ethers } from "ethers";
import { ChainType } from "../types";
import * as config from "../config";

export const getProvider = (chainType: ChainType): ethers.providers.Provider => {
  if (chainType === ChainType.TestNet) {
    return new ethers.providers.JsonRpcProvider(config.TESTNET_URL);
  }
  return new ethers.providers.JsonRpcProvider(config.MAINNET_URL);
};

export const getMarketContractAddress = (chainType: ChainType) => {
  if (chainType === ChainType.TestNet) {
    return config.TESTNET_AUCTION_ADDRESS;
  }

  return config.MAINNET_AUCTION_ADDRESS;
}

export const getCollectionContractAddress = (chainType: ChainType) => {
  if (chainType === ChainType.TestNet) {
    return config.TESTNET_ERC721_ADDRESS;
  }

  return config.MAINNET_ERC721_ADDRESS;
}
