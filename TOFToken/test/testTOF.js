const Token = artifacts.require("TOFToken");
const { expect, assert } = require('chai');
const truffleAssert = require('truffle-assertions');
const { ethers } = require("hardhat");
const uri="Satya";
let tokenIdcounter=0;

describe('TOFToken', (accounts) => {
    let token, balance;
    let ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

    before(async function () {
        accounts = await web3.eth.getAccounts();

        token = await Token.new();
    });

    it('has correct name', async () => {
        const name = await token.name();
        assert.equal(name, 'Real World Smart Contract Token');
    })

    it('has correct symbol', async () => {
        const symbol = await token.symbol();
        assert.equal(symbol, 'RWSCT');
    })


    it('has correct owner', async () => {
        const owner = await token.author();
        assert.equal(owner, accounts[0]);
    })

    it('mint works', async () => {
        await token.mintNFT(accounts[1],uri,tokenIdcounter);
        assert.equal(await token.ownerOf(tokenIdcounter), accounts[1]);
        await truffleAssert.reverts(token.mintNFT(accounts[2],uri,tokenIdcounter),"VM Exception while processing transaction: reverted with reason string 'ERC721: token already minted'");
        tokenIdcounter++;
        await truffleAssert.reverts(token.mintNFT(accounts[2],uri,tokenIdcounter,{from:accounts[1]}),"VM Exception while processing transaction: reverted with reason string 'Unauthorised Access'");
        tokenIdcounter--;
    })

    it('approve  works', async () => {
        await truffleAssert.reverts(token.approve(accounts[2],tokenIdcounter),"VM Exception while processing transaction: reverted with reason string 'ERC721: approve caller is not owner nor approved for all'");
        await token.approve(accounts[2],tokenIdcounter,{from:accounts[1]});
        assert.equal(await token.getApproved(tokenIdcounter), accounts[2]);

    })

    it('transfers  works', async () => {
        await truffleAssert.reverts(token.transferNFT(accounts[1],accounts[3],tokenIdcounter),"VM Exception while processing transaction: reverted with reason string 'ERC721: transfer caller is not owner nor approved'");
        await truffleAssert.reverts(token.transferFrom(accounts[1],accounts[3],tokenIdcounter),"VM Exception while processing transaction: reverted with reason string 'ERC721: transfer caller is not owner nor approved'");
        await truffleAssert.reverts(token.safeTransferFrom(accounts[1],accounts[3],tokenIdcounter),"VM Exception while processing transaction: reverted with reason string 'ERC721: transfer caller is not owner nor approved'");
        await truffleAssert.reverts(token.safeTransferFrom(accounts[1],accounts[3],tokenIdcounter,[]),"VM Exception while processing transaction: reverted with reason string 'ERC721: transfer caller is not owner nor approved'");

        await token.transferNFT(accounts[1],accounts[3],tokenIdcounter,{from : accounts[2]});

        assert.equal(await token.ownerOf(tokenIdcounter),accounts[3]);
        tokenIdcounter++;
        await token.mintNFT(accounts[1],uri,tokenIdcounter);
        await token.transferNFT(accounts[1],accounts[3],tokenIdcounter,{from : accounts[1]});

        assert.equal(await token.ownerOf(tokenIdcounter),accounts[3]);

        tokenIdcounter++;
        await token.mintNFT(accounts[1],uri,tokenIdcounter);
        await token.transferFrom(accounts[1],accounts[3],tokenIdcounter,{from : accounts[1]});

        assert.equal(await token.ownerOf(tokenIdcounter),accounts[3]);

        tokenIdcounter++;
        await token.mintNFT(accounts[1],uri,tokenIdcounter);
        await token.approve(accounts[2],tokenIdcounter,{from: accounts[1]});
        await token.transferFrom(accounts[1],accounts[3],tokenIdcounter,{from : accounts[2]});

        assert.equal(await token.ownerOf(tokenIdcounter),accounts[3]);

        tokenIdcounter++;
        await token.mintNFT(accounts[1],uri,tokenIdcounter);
        await token.safeTransferFrom(accounts[1],accounts[3],tokenIdcounter,{from : accounts[1]});

        assert.equal(await token.ownerOf(tokenIdcounter),accounts[3]);

        tokenIdcounter++;
        await token.mintNFT(accounts[1],uri,tokenIdcounter);
        await token.approve(accounts[2],tokenIdcounter,{from: accounts[1]});
        await token.safeTransferFrom(accounts[1],accounts[3],tokenIdcounter,{from : accounts[2]});

        assert.equal(await token.ownerOf(tokenIdcounter),accounts[3]);

    })

    /*it('set approval for all', async () => {
        tokenIdcounter++;
        await token.mintNFT(accounts[1],uri,tokenIdcounter)
        //await truffleAssert.reverts(token.setApprovalForAll(accounts[2],tokenIdcounter),"VM Exception while processing transaction: reverted with reason string 'ERC721: approve caller is not owner nor approved for all'");
        await token.setApprovalForAll(accounts[2],tokenIdcounter,{from : accounts[1]});
        assert.equal(await token.getApproved(tokenIdcounter),accounts[2]);

    })*/

    it('set uri for all', async () => {
        tokenIdcounter++;
        await token.mintNFT(accounts[1],uri,tokenIdcounter)
        await truffleAssert.reverts(token.setTokenURI(tokenIdcounter,"newURI"),"VM Exception while processing transaction: reverted with reason string 'ERC721: update caller is not owner nor approved'");
        await token.setTokenURI(tokenIdcounter,"newURI",{from : accounts[1]});
        assert.equal(await token.tokenURI(tokenIdcounter),"newURI");
        

    })

    it('contract should be able to receive NFTS', async () => {
        tokenIdcounter++;
        await token.mintNFT(token.address,uri,tokenIdcounter);
        assert.equal(await token.ownerOf(tokenIdcounter),token.address);
        assert.equal(await token.onERC721Received(),"0xa8fcc417")
        

    })
   
});
