// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/interfaces/IDiamondLoupe.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/facets/Auction.sol";
import "../contracts/Diamond.sol";
import "../contracts/KZN.sol";
import "../contracts/upgradeInitializers/DiamondInit.sol";


contract AuctionScript is Script, IDiamondCut {
    // DiamondInit init;
    // Diamond diamond;
    // DiamondCutFacet dCutFacet;
    // DiamondLoupeFacet dLoupe;
    // OwnershipFacet ownerF;
    // Auction auctionF;
    // NFT nftF;
   
    address diamond = 0x29EF888A4F68dCa47A788C4d71b5F8320bf4a996;
    address init = 0x6e74cf87a7e33365cDD31FAbAC088C94a6E0b5C6;
    address dCutFacet = 0x24DB5E176406A56C12485ccA0638a9fd54283abA;
    address nftF = 0x4799aE8A9943a9Be4a98a485Cb707DA6A13799bf;
    address dLoupe = 0x953c9515a26D6119c4F95a523C659Cd64284cF11;
    address ownerF = 0xeDA30F4a2B59d246725eDaBCD5d51e0ec7631435;
    address auctionF = 0x1003edef8e29723C3EE2c4Ee300C7974B7514717;
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        // init = new DiamondInit();
        // diamond = new Diamond(address(0x9B69F998b2a2b20FF54a575Bd5fB90A5D71656C1), address(0x24DB5E176406A56C12485ccA0638a9fd54283abA));
        // dCutFacet = new DiamondCutFacet();
        // nftF = new NFT(address(diamond));
        // dLoupe = new DiamondLoupeFacet();
        // ownerF = new OwnershipFacet();
        // auctionF = new Auction();
        
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

        // upgrade diamond
        bytes memory _calldata = abi.encodeWithSignature("init()");
        IDiamondCut(address(diamond)).diamondCut(cut, address(init), _calldata);

        //call a function
        IDiamondLoupe(address(diamond)).facetAddresses();
        DiamondLoupeFacet(address(diamond)).facetAddresses();
        
        
        vm.stopBroadcast();
        // vm.broadcast();
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
