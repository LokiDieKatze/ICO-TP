// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LokToken is ERC20 {
    address private _tokenHolder;
    constructor(uint256 totalSupply_, address tokenHolder_) ERC20("LokToken", "LOK") {
        _mint(tokenHolder_, totalSupply_);
        _tokenHolder = tokenHolder_;
    }
    function tokenHolder() public view returns(address) {
        return _tokenHolder;
    }
}
