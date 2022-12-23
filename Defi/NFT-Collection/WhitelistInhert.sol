//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface WhitelistInhert{
    function WhitelistAddresses(address) external view returns(bool);
    
}