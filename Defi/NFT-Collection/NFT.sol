//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./WhitelistInhert.sol";

contract CryptoDevs is ERC721Enumerable, Ownable{

    string _baseTokenURL;
    WhitelistInhert whitelist;
    uint256 public tokenId;
    uint256 public _price = 0.01 ether;
    bool public presaleStarted;
    uint256 public presaleEnded;
    uint256 public maxTokenId = 20;
    bool public _paused;

    modifier onlyWhenPaused{
        require(!_paused, "Contract Paused");
        _;
    }

    constructor(string memory baseURI, address whitelistContract) ERC721("CryptoDev","CD"){
        _baseTokenURL = baseURI;
        whitelist = WhitelistInhert(whitelistContract);
    }

    function presaleStared() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;
    }
    function presaleMint() public payable onlyWhenPaused{
        require(presaleStarted && block.timestamp < presaleEnded, "Presale has Ended");
        require(whitelist.WhitelistAddresses(msg.sender), "You are not whitelisted");
        require(tokenId <= maxTokenId, "Max Tokens Reached!");
        require(msg.value >= _price, "Price too low :(");

        tokenId += 1;

        _safeMint(msg.sender, tokenId);
    }

    function mint() public payable onlyWhenPaused{
        require(presaleStarted && block.timestamp > presaleEnded, "Presale has not yet ended!");
        require(tokenId <= maxTokenId, "Max tokens reached!");
        require(msg.value >= _price, "Price too low :(");

        tokenId += 1;

        _safeMint(msg.sender, tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURL;
    }

    function setPaused(bool _val) public onlyOwner{
        _paused = _val;
    }

    function withdraw() public payable onlyOwner{
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value : amount}("");
        require(sent,"Failed to send owner the amount");
    }

    receive() external payable{}
    fallback() external payable{}
}