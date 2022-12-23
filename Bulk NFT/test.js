const {expect} = require("chai")
const { ethers } = require("hardhat")
const {BigNumber} = require("bignumber")

describe("Test", function(){

  it("Checking baseURI and owner set using constructor", async function(){

    const Token = await ethers.getContractFactory("RWSCT")
    const testing = await Token.deploy("www.google.com")
    
    const [owner] = await ethers.getSigners()
    const setOwner = await testing.owner()
    const baseUri = await testing.baseURI()
    
    expect(owner.address).to.equal(setOwner);
    expect(baseUri).to.equal('www.google.com');
  })
  it("Should mint the number of NFTs passed to the passed address", async function(){

    const Token = await ethers.getContractFactory("RWSCT")
    const testing = await Token.deploy("www.google.com")
    
    const [owner,add1] = await ethers.getSigners()
    
    const nftMinting = await testing.bulkMint(5,add1.address)
    const balance = await testing.balanceOf(add1.address)
    
    expect(balance).to.equal(5);
  })
})