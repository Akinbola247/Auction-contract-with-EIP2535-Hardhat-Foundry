// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";
contract NFT is ERC721URIStorage{
      using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    address auctionAddress;
    constructor(address _auctionAddress) ERC721("Kenzman", "KZN") {
        auctionAddress = _auctionAddress;
    }

     function safeMint(string memory TokenUri) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, TokenUri);
        setApprovalForAll(auctionAddress, true);
    }
    

}
