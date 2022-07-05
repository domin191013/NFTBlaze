//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "hardhat/console.sol";

contract SingleMarketplace is Context {
    using SafeMath for uint256;

    IERC721 public token;

    struct NFT {
        uint256 minPrice;
        uint256 endTime;
        uint256 bid;
        address payable seller;
        address payable bidder;
        bool isOnSale;
        uint256 bidCount;
        mapping(address => uint256) userBalances; // keep records of user balances deposited
    }

    mapping(uint256 => NFT) public nfts; // stores details of nft on auction

    event OnSale(uint256 indexed tokenId, uint256 minPrice, uint256 endTime);
    event Bid(uint256 indexed tokenId, address indexed bidder, uint256 price);
    event SaleEnded(
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price
    );
    event quitedBid(uint256 indexed tokenId);
    event EndedSale(uint256 tokenId);

    constructor(address erc721) {
        token = IERC721(erc721);
    }

    modifier OnlyItemOwner(uint256 tokenId) {
        require(
            token.ownerOf(tokenId) == msg.sender,
            "Sender does not own the item"
        );
        _;
    }

    modifier HasTransferApproval(uint256 tokenId) {
        require(
            token.getApproved(tokenId) == address(this),
            "Market is not approved"
        );
        _;
    }

    /**
     * Owner can put a token on auction.
     * @param tokenId - token id
     * @param price - minimum price required
     * @param endTime - end time of auction
     */
    function putOnAuction(
        uint256 tokenId,
        uint256 price,
        uint256 endTime
    ) external OnlyItemOwner(tokenId) HasTransferApproval(tokenId) {
        require(nfts[tokenId].isOnSale == false, "Already on sale");

        NFT storage nftItem = nfts[tokenId];

        nftItem.minPrice = price;
        nftItem.endTime = endTime;
        nftItem.seller = payable(msg.sender);
        nftItem.bid = 0;
        nftItem.isOnSale = true;
        nftItem.bidCount = 0;

        emit OnSale(tokenId, price, endTime);
    }

    function endSale(uint256 tokenId) external OnlyItemOwner(tokenId) {
        require(
            nfts[tokenId].isOnSale == true,
            "It's already ended."
        );

        NFT storage nftItem = nfts[tokenId];
        nftItem.isOnSale = false;

        emit EndedSale(tokenId);
    }

    /**
     * Bid for a token on sale. Bid amount has to be higher than current bid or minimum price.
     * Accepts ether as the function is payable
     * @param tokenId - token id
     */
    function bid(uint256 tokenId)
        external
        payable
        HasTransferApproval(tokenId)
    {
        require(
            token.ownerOf(tokenId) != _msgSender(),
            "Owner cannot bid on his token"
        );

        NFT storage nftItem = nfts[tokenId];

        require(nftItem.isOnSale == true, "Not on sale");
        require(nftItem.endTime > block.timestamp, "Sale ended");

        if (nftItem.bid == 0) {
            require(
                msg.value > nftItem.minPrice,
                "value sent is lower than min price"
            );
        } else {
            require(
                msg.value > nftItem.bid,
                "value sent is lower than current bid"
            );
        }

        nftItem.bid = msg.value;
        nftItem.userBalances[_msgSender()] = msg.value;

        nftItem.bidder = payable(_msgSender());
        nftItem.bidCount = nftItem.bidCount.add(1);
        emit Bid(tokenId, nftItem.bidder, msg.value);
    }

    /**
     * Claim a token after end of sale
     * @param tokenId - token id
     */
    function claim(uint256 tokenId) public {
        NFT storage nftItem = nfts[tokenId];

        require(_msgSender() == nftItem.bidder, "Not the highest bidder");
        require(
            nftItem.endTime < block.timestamp || nftItem.isOnSale == false,
            "It's on sale"
        );
        require(
            nftItem.userBalances[_msgSender()] == nftItem.bid,
            "User already withdrawed money"
        );
        require(
            address(this).balance >= nftItem.bid,
            "Marketplace is currently out of money, please try again later."
        );

        nftItem.userBalances[_msgSender()] = 0;
        nftItem.isOnSale = false;

        token.safeTransferFrom(nftItem.seller, _msgSender(), tokenId);

        (bool success, ) = nftItem.seller.call{value: nftItem.bid}("");
        require(success, "Sending Ether to seller: Transfer failed.");

        emit SaleEnded(tokenId, _msgSender(), nftItem.bid);
    }

    function quitBid(uint256 tokenId) public {
        require(
            _msgSender() != nfts[tokenId].bidder,
            "Shouldn't be the highest bidder"
        );

        NFT storage nftItem = nfts[tokenId];
        uint256 sendMount = nftItem.userBalances[_msgSender()];

        require(
            address(this).balance >= sendMount,
            "Marketplace is currently out of money, please try again later."
        );
        (bool success, ) = payable(_msgSender()).call{value: sendMount}("");
        require(success, "Sending Ether to user: Transfer failed.");
        nftItem.userBalances[_msgSender()] = 0;

        emit quitedBid(tokenId);
    }
}
