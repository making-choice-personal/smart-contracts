// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.10;

contract NestDIDRegistry {

    address public author;
    mapping(string => address) private owners;
    mapping(string => uint) public changed;
   
    constructor() {
        author = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == author, "Unauthorised Access"); 
        _;                              
    }

    event DIDIdentityAdded(
        string indexed identity,
        address owner
    );

    event DIDOwnerChanged(
        string indexed identity,
        address owner,
        uint previousChange
    );

    function identityOwner(string memory _identity) public view returns(address) {
        address owner = owners[_identity];
        if (owner != address(0x0)) {
            return owner;
        }
        return address(0x0);
    }

    function addIdentity(string memory _identity, address _owner) public onlyOwner {
        require(identityOwner(_identity) == address(0x0), "Identity Exists!");
        require(_owner != address(0x0) ,"null address cant be owner");
        owners[_identity] = _owner;
        emit DIDIdentityAdded(_identity, _owner);
    }

    function changeOwner(string memory _identity, address _newOwner) public onlyOwner {
        require(identityOwner(_identity) != address(0x0), "Identity Doesn't Exist!");
        require(_newOwner != address(0x0) ,"null address cant be owner");
        owners[_identity] = _newOwner;
        emit DIDOwnerChanged(_identity, _newOwner, changed[_identity]);
        changed[_identity]++;
    }

    //verify if identity owner is the signer
    function verifySigner(string memory _identity, bytes memory _sig) public view returns (bool) {
        require(identityOwner(_identity) != address(0x0), "Identity Doesn't Exist!");
        bytes32 message = keccak256(abi.encodePacked(_identity, owners[_identity]));
        return (recoverSigner(message, _sig) == owners[_identity]);
    }

    function recoverSigner(bytes32 message, bytes memory sig)  internal pure  returns(address) {
       uint8 v;
       bytes32 r;
       bytes32 s;
       (v, r, s) = splitSignature(sig);
       return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)   internal pure returns(uint8, bytes32, bytes32) {
       require(sig.length == 65);
       bytes32 r;
       bytes32 s;
       uint8 v;
       assembly {
           // first 32 bytes, after the length prefix
           r := mload(add(sig, 32))
           // second 32 bytes
           s := mload(add(sig, 64))
           // final byte (first byte of the next 32 bytes)
           v := byte(0, mload(add(sig, 96)))
       }
       return (v, r, s);
    }


}
