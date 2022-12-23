//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Whitelist{
    uint8 public maxWhitelistAddresses;
    uint8 public numAddressesWhitelisted;

    mapping(address => bool) public WhitelistAddresses;

    constructor(uint8 _maxWhitelistAddresses){
        maxWhitelistAddresses = _maxWhitelistAddresses;
    }

    function addAddressToWhitelist() public {
        require(!WhitelistAddresses[msg.sender], "Sender has already been whitelisted");
        require(numAddressesWhitelisted < maxWhitelistAddresses, "More addresses cant be added, limit reached");

        WhitelistAddresses[msg.sender] = true;
        numAddressesWhitelisted ++;
    } 

}