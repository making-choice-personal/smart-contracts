// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "oracle/contractB.sol";

contract MainC{

    ContractB public _contractB;

    constructor(address _addB){
        _contractB = ContractB(_addB);
    }

    /*
    * @dev gives the current price of BTC
    * @returns current price of BTC (as a string) fetched from the 'Oracle-contractB'. 
    */
    function dataPriceBTC() view public returns(string memory){
        string memory priceBTC = _contractB.provideBTC();
        return priceBTC;
    }
    /*
    * @dev gives the current price of ETH
    * @returns current price of ETH (as a string) fetched from the 'Oracle-contractB'. 
    */
    function dataPriceETH() view public returns(string memory){
        string memory priceETH = _contractB.provideETH();
        return priceETH;
    }
    /*
    * @dev gives the current price of SOL
    * @returns current price of SOL (as a string) fetched from the 'Oracle-contractB'. 
    */
    function dataPriceSOL() view public returns(string memory){
        string memory priceSOL = _contractB.provideSOL();
        return priceSOL;
    }
    /*
    * @dev gives the current price of AVAX
    * @returns current price of AVAX (as a string) fetched from the 'Oracle-contractB'. 
    */
    function dataPriceAVAX() view public returns(string memory){
        string memory priceAVAX = _contractB.provideAVAX();
        return priceAVAX;
    }
    /*
    * @dev gives the current price of KLAY
    * @returns current price of KLAY (as a string) fetched from the 'Oracle-contractB'. 
    */
    function dataPriceKLAY() view public returns(string memory){
        string memory priceKLAY = _contractB.provideKLAY();
        return priceKLAY;
    }
    /*
    * @dev gives the current price of MATIC
    * @returns current price of MATIC (as a string) fetched from the 'Oracle-contractB'. 
    */
    function dataPriceMATIC() view public returns(string memory){
        string memory priceMATIC = _contractB.provideMATIC();
        return priceMATIC;
    }
}