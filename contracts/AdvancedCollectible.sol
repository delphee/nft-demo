// An NFT Contract
// Where the tokenURI can be one of 3 different dogs
// Randomly selected
// SPDX-License-Identifier: MIT

pragma solidity 0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBase {
    uint256 public tokenCounter;
    bytes32 public keyhash;
    uint256 public fee;
    enum Breed{PUG, SHIBA_INU, ST_BERNARD}
    mapping(uint256 => breed) public tokenIdToBreed; // like a dictionary: mapping[tokenId] = PUG
    mapping(bytes32 => address) public requestIdToSender; // keeps track of who make the createCollectible cal

    constructor(
        address _vrfCoordinator,
        address _linkToken,
        bytes32 _keyhash,
        uint256 _fee
    )
        public
        VRFConsumerBase(_vrfCoordinator, _linkToken)
        ERC721("Doggie", "DOG")
    {
        tokenCounter = 0;
        keyhash = _keyhash;
        fee = _fee
    }

    function createCollectible(string memory tokenURI) public returns(bytes32){
        // the return is an event ID 
        bytes32 requestId = requestRandomness(keyhash, fee);
        requestIdToSender[requestId] = msg.sender;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
        // override ensures only the VRFCoordinator can call this
        Breed breed = Breed(randomNumber % 3);
        // need tokenId
        uint256 newTokenId = tokenCounter;
        tokenIdToBreed[newTokenId] = breed;
        // Since this is being called by the VRFCoordinator, can't use msg.sender in safeMint.  Need the original caller of createCollectible
        address owner = requestIdToSender[requestId];
        _safeMint(owner, newTokenId);
        tokenCounter = tokenCounter + 1;

    }
}
