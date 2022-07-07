const Contract = artifacts.require("MultiSigWallet");
const { assert } = require('chai');
const truffleAssert = require('truffle-assertions');
const { ethers } = require("hardhat");


describe('MultiSig', (accounts) => {
    let contract, balance;
    let ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
    let ssid="satya"

    before(async function () {
        accounts = await web3.eth.getAccounts();
        contract = await Contract.new();
    });

    it('has correct creator', async () => {
        const creator=await contract.creator.call();
        assert.equal(creator,accounts[0]);
    })

    it('add owners', async () => {
        await contract.addOwners([accounts[0],accounts[1],accounts[2]],ssid,2);
        for(let i=0;i<3;i++)
        {
            assert.equal(await contract.ssidOwners(ssid,i),accounts[i]);
        }
        assert.equal(await contract.required(ssid),2)
        await contract.addOwners([accounts[0],accounts[1],accounts[2]],ssid,2);
        for(let i=0;i<3;i++)
        {
            assert.equal(await contract.ssidOwners(ssid,i),accounts[i]);
        }
        let owners=await contract.getOwners(ssid);
        for(let i=0;i<3;i++)
        {
            assert.equal(owners[i],accounts[i]);
        }
        await  truffleAssert.reverts(contract.addOwners([accounts[0],accounts[1],ZERO_ADDRESS],ssid,2),"VM Exception while processing transaction: reverted with reason string 'null address cant be added'");
        await  truffleAssert.reverts(contract.addOwners([accounts[0],accounts[1],accounts[2]],ssid,0),"VM Exception while processing transaction: reverted with reason string 'zero quorum'");
        await  truffleAssert.reverts(contract.addOwners([accounts[0],accounts[1],accounts[2]],ssid,4),"VM Exception while processing transaction: reverted with reason string 'quorum exceeds no of owners'");
        await  truffleAssert.reverts(contract.addOwners([accounts[0],accounts[1],accounts[2],accounts[3],accounts[4],accounts[5]],ssid,4),"VM Exception while processing transaction: reverted with reason string 'Exceeds max count'");
        await  truffleAssert.reverts(contract.addOwners([accounts[0],accounts[1],accounts[2]],ssid,2,{from : accounts[1]}),"VM Exception while processing transaction: reverted with reason string 'sender is not creator'");
        
    })

    it('add whitelisters', async () => {
        await contract.addWhitelisters([accounts[0],accounts[1],accounts[2]],ssid);
        for(let i=0;i<3;i++)
        {
            assert.equal(await contract.whiteListers(ssid,i),accounts[i]);
        }
        let whiteListers=await contract.getWhiteListers(ssid);
        for(let i=0;i<3;i++)
        {
            assert.equal(whiteListers[i],accounts[i]);
        }
        await  truffleAssert.reverts(contract.addWhitelisters([accounts[0],accounts[1],ZERO_ADDRESS],ssid),"VM Exception while processing transaction: reverted with reason string 'null address cant be added'");
        await  truffleAssert.reverts(contract.addWhitelisters([accounts[0],accounts[1],accounts[2]],ssid,{from : accounts[4]}),"VM Exception while processing transaction: reverted with reason string 'sender is not owner of ssid'");
        
    })

    it('change required of ssid', async () => {
        await contract.changeRequirement(1,ssid);
        assert.equal(await contract.required(ssid),1);
        await  truffleAssert.reverts(contract.changeRequirement(0,ssid),"VM Exception while processing transaction: reverted with reason string 'zero quorum'");
        await  truffleAssert.reverts(contract.changeRequirement(4,ssid),"VM Exception while processing transaction: reverted with reason string 'quorum exceeds no of owners'");
        await  truffleAssert.reverts(contract.changeRequirement(2,ssid,{from : accounts[4]}),"VM Exception while processing transaction: reverted with reason string 'sender is not owner of ssid'");
        await contract.changeRequirement(2,ssid);

    })

    it('submit transaction', async () => {
        await contract.submitTransaction(ssid);
        assert.equal(await contract.transactionCount.call(),1);
        assert.equal(await contract.txSsid(0),ssid);
        let confirmedAccounts=await contract.getConfirmations(0);
        assert.equal(confirmedAccounts[0],accounts[0])
        assert.equal(await contract.isConfirmed(0),false)

        await contract.submitTransaction(ssid,{from : accounts[1]});
        assert.equal(await contract.transactionCount.call(),2);
        assert.equal(await contract.txSsid(1),ssid);
        confirmedAccounts=await contract.getConfirmations(1);
        assert.equal(confirmedAccounts[0],accounts[1])
        assert.equal(await contract.isConfirmed(1),false)

        await  truffleAssert.reverts(contract.submitTransaction(ssid,{from : accounts[3]}),"VM Exception while processing transaction: reverted with reason string 'sender is not owner of ssid'")
        

    })
    it('getConfirmations revert ', async () => {

        await  truffleAssert.reverts(contract.getConfirmations(4),"VM Exception while processing transaction: reverted with reason string 'transaction doesn't exists'")

        
    })
    it('confirm transaction', async () => {


        assert.equal(parseInt(await contract.getTransactionCount(false,false)),0);
        assert.equal(parseInt(await contract.getTransactionCount(true,true)),2);
        assert.equal(parseInt(await contract.getConfirmationCount(0)),1);


        await  truffleAssert.reverts(contract.confirmTransaction(0,{from : accounts[3]}),"VM Exception while processing transaction: reverted with reason string 'doesnt have access to confirm'")
        await  truffleAssert.reverts(contract.confirmTransaction(2),"VM Exception while processing transaction: reverted with reason string 'transaction doesnt exist'");
        await  truffleAssert.reverts(contract.confirmTransaction(0),"VM Exception while processing transaction: reverted with reason string 'sender already confirmed transaction'");
        await contract.confirmTransaction(0,{from : accounts[1]});
        await  truffleAssert.reverts(contract.confirmTransaction(0,{from : accounts[2]}),"VM Exception while processing transaction: reverted with reason string 'transaction executed'");

        assert.equal(parseInt(await contract.getConfirmationCount(0)),2);
        let confirmedAccounts=await contract.getConfirmations(0);
        assert.equal(confirmedAccounts[1],accounts[1])
        assert.equal(await contract.isConfirmed(0),true)
        assert.equal(parseInt(await contract.getConfirmationCount(0)),2);
        assert.equal(parseInt(await contract.getTransactionCount(true,false)),1);
        assert.equal(parseInt(await contract.getTransactionCount(false,true)),1);

        assert.equal(parseInt(await contract.getConfirmationCount(1)),1);
        await  truffleAssert.reverts(contract.confirmTransaction(1,{from : accounts[3]}),"VM Exception while processing transaction: reverted with reason string 'doesnt have access to confirm'")
        await  truffleAssert.reverts(contract.confirmTransaction(2),"VM Exception while processing transaction: reverted with reason string 'transaction doesnt exist'");
        await  truffleAssert.reverts(contract.confirmTransaction(1,{from : accounts[1]}),"VM Exception while processing transaction: reverted with reason string 'sender already confirmed transaction'");
        await contract.confirmTransaction(1,{from : accounts[0]});
        await  truffleAssert.reverts(contract.confirmTransaction(1,{from : accounts[2]}),"VM Exception while processing transaction: reverted with reason string 'transaction executed'");
        assert.equal(parseInt(await contract.getConfirmationCount(1)),2);
        confirmedAccounts=await contract.getConfirmations(1);
        assert.equal(confirmedAccounts[0],accounts[0])
        assert.equal(await contract.isConfirmed(1),true)
        assert.equal(parseInt(await contract.getConfirmationCount(1)),2);

       

       await  truffleAssert.reverts(contract.confirmTransaction(0,{from : accounts[3]}),"VM Exception while processing transaction: reverted with reason string 'doesnt have access to confirm'")
       await  truffleAssert.reverts(contract.confirmTransaction(2),"VM Exception while processing transaction: reverted with reason string 'transaction doesnt exist'");
       await  truffleAssert.reverts(contract.confirmTransaction(0),"VM Exception while processing transaction: reverted with reason string 'sender already confirmed transaction'");
       assert.equal(parseInt(await contract.getTransactionCount(true,false)),0);
       assert.equal(parseInt(await contract.getTransactionCount(false,true)),2);
       await contract.isConfirmed(4)

    })



})
