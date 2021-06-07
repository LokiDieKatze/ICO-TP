// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./LokToken.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/* j'ai pris le parti de ne pas instaurer un owner pour ICO.sol car c'était superflu dans mon code 
    dans le sens où j'importe et utilise le owner de mon ERC20 ou plutôt l'adresse qui possède la total supply de tokens..
*/
contract ICO {

        using Address for address payable;

    //state variables
    LokToken private _token;
    address private _tokenHolder;
    uint256 private _rate;
    uint256 private _beginning;
    uint256 private _end;
    uint256 private _boughtTokens;
    address private _recipient;

    //events
    event Received(address indexed sender, uint256 value);
    event BoughtToken(address indexed buyer, uint256 amountOfTokens);
    event Withdrawn(address indexed owner, uint256 icoContent);

    //constructor
    constructor (address LokTokenAddress, uint256 tokenPriceInEther_) {
        _token = LokToken(LokTokenAddress);
        _beginning = block.timestamp;
        _end = _beginning + 2 weeks;
        _rate = tokenPriceInEther_;
        _tokenHolder = _token.tokenHolder();
    }

    modifier after2Weeks {
        require(block.timestamp > _end, "Sorry, the sale has not ended yet.");
        _;
    }

    modifier beforeEnd {
        require(block.timestamp <= _end, "Sorry, the sale has ended already");
        _;
    }

    modifier enoughToken {
        require((_token.totalSupply() - _boughtTokens) >= (msg.value / (1 ether * _rate)), "Ooops, there is not enough Tokens left.");
        _;
    }

    modifier enoughValue {
        require(msg.value >= (1 ether * _rate), "Sorry, this is not enough Ether (in weis) to buy one Token.");
        _;
    }

    //functions
    
    receive() external payable beforeEnd enoughToken enoughValue {
        _recipient = msg.sender;
        _buyToken();
    }

    function buyToken() public payable beforeEnd enoughToken enoughValue {
        _recipient = msg.sender;
        _buyToken();
    }

    function _buyToken() private {
        _boughtTokens += (msg.value/(1 ether * _rate));
        _token.transferFrom(_token.tokenHolder(), _recipient, (msg.value/(1 ether * _rate)));
        emit BoughtToken(_recipient, (msg.value/(1 ether * _rate)));
    }

    function withdraw() public after2Weeks {
        require(msg.sender == _tokenHolder, "Sorry you are not allowed to withdraw the content of this contract.");
        emit Withdrawn(msg.sender, address(this).balance);
        payable(msg.sender).sendValue(address(this).balance);
    }

    //getters
    function name() public view returns(string memory) {
        return _token.name();
    }

    function symbol() public view returns(string memory) {
        return _token.symbol();
    }

    function tokenAddress() public view returns(address) {
        return address(_token);
    }

    function end() public view returns(uint256) {
        return _end;
    }

    function timeLeft() public view returns(uint256) {
        return _end - _beginning;
    }

    function tokenPrice() public view returns(uint256) {
        return _rate;
    }

    function initialSupply() public view returns(uint256) {
        return _token.totalSupply();
    }

    function alreadyBought() public view returns(uint256) {
        return _boughtTokens;
    }

    function tokenForSale() public view returns(uint256) {
        return _token.totalSupply() - _boughtTokens;
    }
}
