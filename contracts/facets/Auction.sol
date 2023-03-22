// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import { LibDiamond } from "../libraries/LibDiamond.sol";
import {IERC721} from "../../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../../lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import  "../libraries/AppStorage.sol";

contract Auction {
    AuctionStorage ds;
function CreateAuction (address contractAddress, uint tokenID, uint price) public payable {
       require(msg.value == 0.0065 ether, "listing Price is 0.0065 ether");
        ds.auctionItemiD++;
        uint256 itemIds = ds.auctionItemiD;
       AuctionDetails storage _b = ds.OwnerAuctionItem[msg.sender];
       _b.contractAddress = contractAddress;
       _b.NFTowner = msg.sender;
       _b.tokenID = tokenID;
       _b.price = price;
       ItemsToAuction storage _a = ds.TobeAuctioned[itemIds];
       _a.AuctionID = itemIds;
       _a.contractAddress = contractAddress;
       _a.tokenID = tokenID;
       _a.status = false;
       _a.price = price;
       ds.seller[itemIds] = payable(msg.sender);
       IERC721(contractAddress).transferFrom(msg.sender, address(this), tokenID);
    }
function getAuctionedItem() public view returns (address, uint) {
        AuctionDetails memory auctionedItem = ds.OwnerAuctionItem[msg.sender];
        return (auctionedItem.contractAddress, auctionedItem.tokenID);
    }

function startBidding(uint _auctionID) public {
        address owner_ = LibDiamond.contractOwner();
    require(msg.sender == owner_, "Not authorized");
        ItemsToAuction storage _id = ds.TobeAuctioned[_auctionID];
        _id.status = true;
    }
function getSeller(uint id) public view returns(address _seller){
        _seller = ds.seller[id];
    }

function bid(uint auctionID_) public payable{
        ItemsToAuction storage id_ = ds.TobeAuctioned[auctionID_];
        uint __highestbid = id_.highestBid;
        uint bidderStatus = ds.bids[msg.sender][auctionID_];
        require(id_.status == true, "Auction is not open");
        require(msg.value >= id_.price, "price below auction");
        require(msg.value != 0, "cannot bid 0");
        require(bidderStatus == 0, "Cannot bid twice");
        if(__highestbid !=0 && msg.value > __highestbid){
            ds.bids[msg.sender][auctionID_] += msg.value;
            id_.highestBid = msg.value;
            id_.highestBidder = payable(msg.sender);    
        }else {
            ds.bids[msg.sender][auctionID_] += msg.value;
            id_.highestBid = msg.value;
            id_.highestBidder = payable(msg.sender);        
         }  
    }
function withdraw(uint auctionID__) public {
        uint balance = ds.bids[msg.sender][auctionID__];
        ItemsToAuction storage _id_ = ds.TobeAuctioned[auctionID__];
        address _highestBidder = _id_.highestBidder;
        require(balance != 0, "you have no bid");
        require (msg.sender !=_highestBidder, "You're the highestBidder");
        require(_id_.status == false, "Auction has not closed");
        (bool sent, ) = payable(msg.sender).call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

    function settleBid(uint auctionIDm__) public payable {
         address owner_ = LibDiamond.contractOwner();
    require(msg.sender == owner_, "Not authorized");
        ItemsToAuction storage _idm_ = ds.TobeAuctioned[auctionIDm__];
        address _highestBidder_ = _idm_.highestBidder;
        require(_idm_.status == true, "Auction not active");
        _idm_.status = false;
        address contractaddr = _idm_.contractAddress;
        uint nftID = _idm_.tokenID;
        address _seller = getSeller(auctionIDm__);
        if(_highestBidder_ == address(0)){
            IERC721(contractaddr).transferFrom(address(this), _seller, nftID);
        }else {
            IERC721(contractaddr).transferFrom(address(this), _highestBidder_, nftID);
        }
        
    }

    function cashOut(uint _itemMarketID) public  {
        ItemsToAuction storage _idm_ = ds.TobeAuctioned[_itemMarketID];
        uint balance = _idm_.highestBid;
        require(balance != 0, "No bid");
        require(_idm_.status == false, "Auction still active");
        address _seller = getSeller(_itemMarketID);
        require(msg.sender == _seller, "Not Authorized");
         (bool sent, ) = payable(msg.sender).call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

    function withdrawContractFunds() public payable{
        address owner_ = LibDiamond.contractOwner();
        require(msg.sender == owner_, "Not authorized");
        uint balance = address(this).balance;
        (bool sent, ) = payable(msg.sender).call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

receive() external payable{}
fallback() external payable{}

}