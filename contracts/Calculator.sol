// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./LokToken.sol";
import "@openzeppelin/contracts/utils/Address.sol";


///@title Loktoken-payable Calculator
///@author Sarah Marques
///@notice prior holding of Loktoken is required as payment for using this calculator
/**
*@dev this contract could be made more generic by deploying it with any ERC20-based Tokens 
*other than the one foreseen for this case.
**/
contract Calculator {

    using Address for address payable;
    
    LokToken private _token;
    uint256 private _result;
    string private _operator;
    address private _sender;
    address private _recipient;

    ///@param sender address of the user
    ///@param firstNumber the number that comes as first in the writing of the operation
    ///@param operator the operation sign
    ///@param secondNumber the number that comes as second in the writing of the operation
    ///@param result the result of the operation

    event Operated(address indexed sender, uint256 firstNumber, string operator, uint256 secondNumber, uint256 result);

    /**@dev the constructor sets the address of the Token contract used for the payment
    and at the same time the recipient of the calculator payments which is also the holder of the 
    initial supply of Tokens
    */

    constructor (address LokTokenAddress) { 
        _token = LokToken(LokTokenAddress);
        _recipient = _token.tokenHolder();
    }
    
    ///@dev this modifier prevents a user to use a function if he does not own the required amount of Token for the payment

    modifier enoughToken () {
        require(_token.balanceOf(msg.sender) >= 1, "Calculator: This operation costs 1 Loktoken, please credit your account.");
        _;
    }
    
    ///@dev transfers the payment in token from the user to the recipient 

    function _transaction() private {
        _token.transferFrom(_sender, _recipient, 1);
    }

    ///@notice use this function to get the result of an addition between two numbers
    ///@param a the first number to add up
    ///@param b the second number to add up
    ///@return the result of the operation `a` + `b`

    function add (uint256 a, uint256 b) public payable enoughToken returns (uint256) {
        _sender = msg.sender;
        _transaction();
        _operator = "+";
        _result = a + b;
        emit Operated(_sender, a, _operator, b, _result);
        return _result;
    }
    
    ///@notice use this function to get the result of a substraction between two numbers
    ///@param a the number that comes as first in the writing of the operation
    ///@param b the number that comes as second in the writing of the operation
    ///@return the result of the operation `a` - `b`
    
    function sub (uint256 a, uint256 b) public payable enoughToken returns (uint256) {
        _sender = msg.sender;
        _transaction();
        _operator = "-";
        _result = a - b;
        emit Operated(_sender, a, _operator, b, _result);
        return _result;
    }
    
    ///@notice use this function to get the result of a multiplication between two numbers
    ///@param a the first number to multiply
    ///@param b the second number to multiply
    ///@return the result of the operation `a` * `b`

    function mul (uint256 a, uint256 b) public payable enoughToken returns (uint256) {
        _sender = msg.sender;
        _transaction();
        _operator = "*";
        _result = a * b;
        emit Operated(_sender, a, _operator, b, _result);
        return _result;
    }
    
    ///@notice use this function to get the result of a division between two numbers
    ///@param a the dividend or number that comes as first in the writing of the operation
    ///@param b the divisor or number that comes as second in the writing of the operation
    ///@return the result of the operation `a` / `b`

    function div (uint256 a, uint256 b) public payable enoughToken returns (uint256) {
        require(b != 0, "Calculator: impossible to divide by 0.");
        _sender = msg.sender;
        _transaction();
        _operator = "/";
        _result = a / b;
        emit Operated(_sender, a, _operator, b, _result);
        return _result;
    }
    
    ///@notice use this function to get the result of a modulo operation between two numbers
    ///@param a the dividend or number that comes as first in the writing of the operation
    ///@param b the divisor or number that comes as second in the writing of the operation
    ///@return the result of the operation `a` % `b`

    function modulo (uint256 a, uint256 b) public payable enoughToken returns (uint256) {
        require(b != 0, "Calculator: impossible to operate modulo 0.");
        _sender = msg.sender;
        _transaction();
        _operator = "%";
        _result = a % b;
        emit Operated(_sender, a, _operator, b, _result);
        return _result;
    }

    ///@return the address of the token contract used as payment solution in this contract
    ///@dev used for the smart contract testing
    function tokenAddress() public view returns(address) {
        return address(_token);
    }
}
