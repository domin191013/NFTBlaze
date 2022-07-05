export enum ChainType {
  MainNet = "mainnet",
  TestNet = "testnet",
}

export interface SaleItem {
  minPrice: number;
  endTime: number;
  bid: number;
  seller: string;
  bidder: string;
  isOnSale: boolean;
  bidCount: number;
}
