//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract NFTCollectible is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    //The maximum number of NFTs that can be minted in the collection
    uint public constant MAX_SUPPLY = 100;

    // The amount of ether required to buy 1 NFT
    uint public constant PRICE = 0.01 ether;

    // The upper limit of NFTs that can mint at once
    uint public constant MAX_PER_MINT = 5;

    //The IPFS URL of the folder containing the JSON metadata
    string public baseTokenURI;

    // constructor
    constructor(string memory baseURI) ERC721("NFT Collectible", "NFTC") {
     setBaseURI(baseURI);
    }

    // For mint a 5 NFTs for free ( only the owner can call it)
    function reserveNFTs() public onlyOwner {
        uint totalMinted = _tokenIds.current();
        require(
            totalMinted.add(5) < MAX_SUPPLY, "Not enough NFTs"
        );
        for (uint i = 0; i < 5; i++) {
            _mintSingleNFT();
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function mintNFTs(uint _count) public payable {
        uint totalMinted = _tokenIds.current();
        require(
            totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFTs!"
        );
        require(
            _count > 0 && _count <= MAX_PER_MINT, 
        "Cannot mint specified number of NFTs."
        );
        require(
            msg.value >= PRICE.mul(_count), 
        "Not enough ether to purchase NFTs."
        );
        for (uint i = 0; i < _count; i++) {
                _mintSingleNFT();
        }
    }

    function _mintSingleNFT() private {
        uint newTokenID = _tokenIds.current();
        _safeMint(msg.sender, newTokenID);
        _tokenIds.increment();
    }

    function tokensOfOwner(address _owner) external view returns (uint[] memory) {
        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);
        for (uint i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    
}