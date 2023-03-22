// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// enum Status { start, end}
struct AuctionDetails {
        address contractAddress;
        address NFTowner;
        uint tokenID;
        uint price;
    }
    struct ItemsToAuction {
        uint AuctionID;
        address contractAddress;
        uint tokenID;
        bool status;
        uint price;
        address payable highestBidder;
        uint highestBid;
    }
struct AuctionStorage {
    uint auctionItemiD;
    ItemsToAuction itemsToAuction;
    AuctionDetails auctionDetails;
    mapping(uint => ItemsToAuction) TobeAuctioned;
    mapping (address => AuctionDetails) OwnerAuctionItem;
    mapping (address => mapping(uint => uint))bids;
    mapping (uint => address) seller;
    
}