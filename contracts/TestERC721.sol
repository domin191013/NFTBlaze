//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TestERC721 is ERC721, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _idCounter;
    string private _baseURIextended;
    uint public MAX_NFTs = 5000;

    constructor() ERC721("TestERC721", "Test721") {}

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    /**
     @dev A minting function where a user can't mint more than 10 items.
     */
    function freeMintMultiple(uint256 numberOfTokens) external {
        require(numberOfTokens <= 10, "Exceeded max token purchase (max 3)");
        require(
            _idCounter.current().add(numberOfTokens) <= MAX_NFTs,
            "Purchase would exceed max supply of the collection"
        );

        for (uint256 i = 0; i < numberOfTokens; i++) {
            if (_idCounter.current() < MAX_NFTs) {
                _safeMint(msg.sender, _idCounter.current());
                _idCounter.increment();
            }
        }
    }
}
