// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract ContractB {
    string public btcPrice;
    string public ethPrice;
    string public solPrice;
    string public avaxPrice;
    string public klayPrice;
    string public maticPrice;

    /*
    * @dev to fetch the current price of BTC from the API
    * @param current price of BTC (as a string)
    */
    function fetchBTC(string memory btc) public{
        btcPrice = btc;
    }
    /*
    * @dev to fetch the current price of ETH from the API
    * @param current price of ETH (as a string)
    */
    function fetchETH(string memory eth) public{
        ethPrice = eth;
    }
    /*
    * @dev to fetch the current price of SOL from the API
    * @param current price of SOL (as a string)
    */
    function fetchSOL(string memory sol) public{
        solPrice = sol;
    }
    /*
    * @dev to fetch the current price of AVAX from the API
    * @param current price of AVAX (as a string)
    */
    function fetchAVAX(string memory avax) public{
        avaxPrice = avax;
    }
    /*
    * @dev to fetch the current price of KLAY from the API
    * @param current price of KLAY (as a string)
    */
    function fetchKLAY(string memory klay) public{
        klayPrice = klay;
    }
    /*
    * @dev to fetch the current price of MATIC from the API
    * @param current price of MATIC (as a string)
    */
    function fetchMATIC(string memory matic) public{
        maticPrice = matic;
    }


    /*
    * @dev to provide the BTC price to contractA
    * @returns current price of BTC (as a string) fetched from the 'fetchBTC' function
    */
    function provideBTC() view public returns(string memory){
        return btcPrice;
    }
    /*
    * @dev to provide the ETH price to contractA
    * @returns current price of ETH (as a string) fetched from the 'fetchETH' function
    */
    function provideETH() view public returns(string memory){
        return ethPrice;
    }
    /*
    * @dev to provide the SOL price to contractA
    * @returns current price of SOL (as a string) fetched from the 'fetchSOL' function
    */
    function provideSOL() view public returns(string memory){
        return solPrice;
    }
    /*
    * @dev to provide the AVAX price to contractA
    * @returns current price of AVAX (as a string) fetched from the 'fetchAVAX' function
    */
    function provideAVAX() view public returns(string memory){
        return avaxPrice;
    }
    /*
    * @dev to provide the KLAY price to contractA
    * @returns current price of KLAY (as a string) fetched from the 'fetchKLAY' function
    */
    function provideKLAY() view public returns(string memory){
        return klayPrice;
    }
    /*
    * @dev to provide the MATIC price to contractA
    * @returns current price of MATIC (as a string) fetched from the 'fetchMATIC' function
    */
    function provideMATIC() view public returns(string memory){
        return maticPrice;
    }
}