// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

///@title Loktoken: an ERC20-based Token
///@author Sarah Marques

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LokToken is ERC20 {
    address private _tokenHolder;
    constructor(uint256 totalSupply_, address tokenHolder_) ERC20("LokToken", "LOK") {
        _mint(tokenHolder_, totalSupply_);
        _tokenHolder = tokenHolder_;
    }
    ///@notice use this function to know who holds initially the supply of Loktoken
    ///@dev function gets you the owner of the initial supply of Loktoken, which can be used in other contracts such as ICOs
    ///@return the address of the owner of the initial supply of Loktoken
    function tokenHolder() public view returns(address) {
        return _tokenHolder;
    }
}
