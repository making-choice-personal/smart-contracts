// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract eventsOnchain is Ownable
{
    mapping(string => string[]) private profileToevents;

    function storeEvents(string memory profileID,string memory events) public onlyOwner
    {   
        
        profileToevents[profileID].push(events);

    }


    function getEvents(string memory profileID) view public returns(string[] memory)
    {
        return profileToevents[profileID];
    }
}
