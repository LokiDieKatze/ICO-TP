// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./LokToken.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/* j'ai pris le parti de ne pas instaurer un owner pour ICO.sol car c'était superflu dans mon code 
    dans le sens où j'importe et utilise le owner de mon ERC20 ou plutôt l'adresse qui possède la total supply de tokens..
*/

///@title Initial Coin Offering for the LokToken
///@author Sarah Marques
/**
*@notice it is possible to purchase LokToken only during two weeks, after which the sale will be definitely closed
*only the owner of the initial supply of Tokens will be able to withdraw his funds (ether) after that periode of time
**/
/**
*@dev this contract could be made more generic by deploying it with any ERC20-based Tokens 
*other than the one foreseen for this case and the set its own price.
**/

contract ICO {

        using Address for address payable;

    LokToken private _token;
    address private _tokenHolder;
    uint256 private _rate;
    uint256 private _beginning;
    uint256 private _end;
    uint256 private _boughtTokens;
    address private _recipient;

    ///@param sender the address of the payer
    ///@param value the value the payer sends in ether(wei)

    event Received(address indexed sender, uint256 value);

    ///@param buyer the address of the buyer
    ///@param amountOfTokens the amount of token that the user buys

    event BoughtToken(address indexed buyer, uint256 amountOfTokens);

    ///@param owner the address of the owner of the inital supply of token
    ///@param icoContent the content of this smart contract in ether(wei), from the sale of token 
    ///@dev owner is also the only allowed person to use the withdraw function

    event Withdrawn(address indexed owner, uint256 icoContent);

    ///@notice determine the ERC20-based Token Contract used for this ICO Contract
    ///@param LokTokenAddress address of the Token Contract
    ///@param tokenPriceInEther_ price of one Token in Ether
    /**
    *@dev set the beginning of the sale as the contract is deployed
    *set the end of the sale 2 weeks after it has begun
    *the token holer of the token initial supply is used as an alternative to an owner of this contract
    **/

    constructor (address LokTokenAddress, uint256 tokenPriceInEther_) {
        _token = LokToken(LokTokenAddress);
        _beginning = block.timestamp;
        _end = _beginning + 2 weeks;
        _rate = tokenPriceInEther_;
        _tokenHolder = _token.tokenHolder();
    }

    ///@dev function requires the sale is over

    modifier after2Weeks {
        require(block.timestamp > _end, "Sorry, the sale has not ended yet.");
        _;
    }

    ///@dev function requires the sale is still ongoing

    modifier beforeEnd {
        require(block.timestamp <= _end, "Sorry, the sale has ended already");
        _;
    }

    ///@dev function requires the supply of token is sufficient

    modifier enoughToken {
        require((_token.totalSupply() - _boughtTokens) >= (msg.value / (1 ether * _rate)), "Ooops, there is not enough Tokens left.");
        _;
    }

    ///@dev function requires the user has at least enough ether(wei) for the purchase of 1 token

    modifier enoughValue {
        require(msg.value >= (1 ether * _rate), "Sorry, this is not enough Ether (in weis) to buy one Token.");
        _;
    }

    ///@notice enter the value in ether(wei) of your choice and you will receive the matching amount of token
    ///@dev calls the _buyToken() private function    
    receive() external payable beforeEnd enoughToken enoughValue {
        _recipient = msg.sender;
        _buyToken();
    }

    ///@notice enter the value in ether(wei) of your choice and you will receive the matching amount of token
    ///@dev calls the _buyToken() private function

    function buyToken() public payable beforeEnd enoughToken enoughValue {
        _recipient = msg.sender;
        _buyToken();
    }

    ///@dev proceeds to the transfer (transferFrom() of the ERC20 contract) of token between owner and buyer

    function _buyToken() private {
        _boughtTokens += (msg.value/(1 ether * _rate));
        _token.transferFrom(_token.tokenHolder(), _recipient, (msg.value/(1 ether * _rate)));
        emit BoughtToken(_recipient, (msg.value/(1 ether * _rate)));
    }

    ///@notice only the owner of the initial supply of token is allowed to withdraw the takings of the token sale
    ///@dev the ether saved on this contract will be send to the owners account

    function withdraw() public after2Weeks {
        require(msg.sender == _tokenHolder, "Sorry you are not allowed to withdraw the content of this contract.");
        emit Withdrawn(msg.sender, address(this).balance);
        payable(msg.sender).sendValue(address(this).balance);
    }

    ///@notice get the name of the Token

    function name() public view returns(string memory) {
        return _token.name();
    }

    ///@notice get the symbol of the Token

    function symbol() public view returns(string memory) {
        return _token.symbol();
    }

    ///@notice get the address of the Token

    function tokenAddress() public view returns(address) {
        return address(_token);
    }

    ///@notice get the end time of the sale

    function end() public view returns(uint256) {
        return _end;
    }

    ///@notice get the time left before sales closing

    function timeLeft() public view returns(uint256) {
        return _end - _beginning;
    }

    ///@notice get the price of the token

    function tokenPrice() public view returns(uint256) {
        return _rate;
    }

    ///@notice get the total amount of token supplied in this sale

    function initialSupply() public view returns(uint256) {
        return _token.totalSupply();
    }

    ///@notice get the amount of already bought token

    function alreadyBought() public view returns(uint256) {
        return _boughtTokens;
    }

    ///@notice get the remaining amount of token for sale

    function tokenForSale() public view returns(uint256) {
        return _token.totalSupply() - _boughtTokens;
    }
}
