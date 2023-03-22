// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/facets/Auction.sol";
import "../../lib/forge-std/src/Test.sol";
import "../contracts/Diamond.sol";
import "../contracts/KZN.sol";
import "../contracts/interfaces/IAuction.sol";

contract DiamondDeployer is Test, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    Auction auctionF;
    NFT nftF;

    function setUp() public {
        //deploy facets 
        vm.startPrank(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        vm.deal(0xFa027a58eF89d124CA94418CE5403C29Af2D7459, 5 ether); 
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(0xFa027a58eF89d124CA94418CE5403C29Af2D7459), address(dCutFacet));
        nftF = new NFT(address(diamond));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        auctionF = new Auction();
        vm.stopPrank();
    }
    function testDeployDiamond() public {
        //upgrade diamond with facets
        vm.startPrank(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        //build cut struct
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(auctionF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("Auction")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
        nftF.safeMint("https://ipfs.filebase.io/ipfs/QmYqEcCNJiP7pP2nzSsvyv7Ji1tNpv6omWMJ4Nph22dmfn");
        IAuction(address(diamond)).CreateAuction{value: 0.0065 ether}(address(nftF), 0, 1 ether);
       IAuction(address(diamond)).startBidding(1);
       vm.stopPrank();
        vm.startPrank(address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC));
        vm.deal(address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC), 5 ether);  
       IAuction(address(diamond)).bid{value: 2 ether}(1);
        vm.stopPrank();
        vm.startPrank(address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720));
        vm.deal(address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720), 9 ether);
       IAuction(address(diamond)).bid{value: 3 ether}(1);
        vm.stopPrank();
        IAuction(address(diamond)).getSeller(1);
        uint balance = address(diamond).balance;
        console.log(balance); 
          vm.startPrank(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        vm.deal(0xFa027a58eF89d124CA94418CE5403C29Af2D7459, 5 ether);   
        IAuction(address(diamond)).settleBid(1);
      vm.stopPrank();
        vm.startPrank(address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC));
       IAuction(address(diamond)).withdraw(1);       
        vm.stopPrank();
        
         vm.startPrank(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        vm.deal(0xFa027a58eF89d124CA94418CE5403C29Af2D7459, 5 ether);
        IAuction(address(diamond)).cashOut(1);
        IAuction(address(diamond)).withdrawContractFunds();
         uint balance2 = address(diamond).balance;
        console.log(balance2);
        vm.stopPrank();
  
    }

    function generateSelectors(string memory _facetName)
        internal
        returns (bytes4[] memory selectors)
    {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }


    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
