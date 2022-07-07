const Contract = artifacts.require("NestDIDRegistry");
const { expect, assert } = require('chai');
const truffleAssert = require('truffle-assertions');
const { ethers } = require("hardhat");

function sign(address, data) {
    return hre.network.provider.send(
      "eth_sign",
      [address, ethers.utils.hexlify(ethers.utils.toUtf8Bytes('foo'))]
    )
  }

describe('NEST DID', (accounts) => {
    let contract, balance;
    let ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

    before(async function () {
        accounts = await web3.eth.getAccounts();

        contract = await Contract.new();
    });

    it('has  correct author', async () => {
        const author = await contract.author();
        assert.equal(author, accounts[0]);
    })

    it('add identity', async () => {
        await contract.addIdentity("satya",accounts[0]);
        assert.equal(await contract.identityOwner("satya"),accounts[0]);
        await truffleAssert.reverts(contract.addIdentity("satya",accounts[1]),"VM Exception while processing transaction: reverted with reason string 'Identity Exists!'");
        await truffleAssert.reverts(contract.addIdentity("satya1",ZERO_ADDRESS),"VM Exception while processing transaction: reverted with reason string 'null address cant be owner'");
        await truffleAssert.reverts(contract.addIdentity("satya1",accounts[0],{from : accounts[1]}),"VM Exception while processing transaction: reverted with reason string 'Unauthorised Access'");
    })

    it('change Owner', async () => {

        await contract.changeOwner("satya",accounts[1]);
        assert.equal(await contract.identityOwner("satya"),accounts[1]);
        assert.equal(await contract.changed("satya"),1);
        await truffleAssert.reverts(contract.changeOwner("satya1",accounts[1]),"VM Exception while processing transaction: reverted with reason string 'Identity Doesn't Exist!'");
        await truffleAssert.reverts(contract.changeOwner("satya",ZERO_ADDRESS),"VM Exception while processing transaction: reverted with reason string 'null address cant be owner'");
        await truffleAssert.reverts(contract.changeOwner("satya",accounts[0],{from : accounts[1]}),"VM Exception while processing transaction: reverted with reason string 'Unauthorised Access'");
    })

    it('verify Signer', async () => {
        let signed = await sign(accounts[0],'test');
        let sig = await ethers.utils.splitSignature(signed);
        const result=await contract.verifySigner("satya",sig)
        assert.equal(result,false);
        //assert.equal(signed.hexlify.toString()," ");
        await truffleAssert.reverts(contract.verifySigner("satya1",accounts[1]),"VM Exception while processing transaction: reverted with reason string 'Identity Doesn't Exist!'");
    
    })

    


   
});
