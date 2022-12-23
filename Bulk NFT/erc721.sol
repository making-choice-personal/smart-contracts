// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract RWSCT is ERC721 {

    address public owner;
    uint256 public _mintedTokens = 0;
    string public baseURI;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event batchMinted(uint256 _count, address _recipient);

    constructor(string memory _baseURI) ERC721("Non Fungible Token", "NFT") {
        owner = msg.sender;
        baseURI=_baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function bulkMint(uint256 _count, address _recipient) public onlyOwner {
        uint256 _upperLimit = _mintedTokens + _count;
        for (uint256 i = _mintedTokens; i < _upperLimit; i++) {
            _mint(_recipient, i);
            _mintedTokens++;
        }
        emit batchMinted( _count, _recipient);
    }
}