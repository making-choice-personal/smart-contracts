// Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract TOFToken is ERC721URIStorage {

    address public author;

    constructor()  ERC721("Real World Smart Contract Token", "RWSCT") {
        author = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == author, "Unauthorised Access"); 
        _;                              
    }

    function mintNFT(address recipient, string memory tokenURI, uint256 tokenId) public onlyOwner {
        _mint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: update caller is not owner nor approved"
        );
        _setTokenURI(tokenId, tokenURI);
    }

    function transferNFT(address from, address to, uint256 tokenId) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _transfer(from, to, tokenId);
    }

    function onERC721Received( ) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
