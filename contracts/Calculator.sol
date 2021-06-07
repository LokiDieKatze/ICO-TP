// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./LokToken.sol";
import "@openzeppelin/contracts/utils/Address.sol";


contract Calculator {
    //library usage
    using Address for address payable;
    
    // state variables
    LokToken private _token;
    uint256 private _result;
    string private _operator;
    address private _sender;
    address private _recipient;

    //event
    event Operated(address indexed sender, uint256 firstNumber, string operator, uint256 secondNumber, uint256 result);

    // constructor, déclaration du owner
    constructor (address LokTokenAddress) { 
        _token = LokToken(LokTokenAddress);
        _recipient = _token.tokenHolder();
    }
    
    // modifier pour vérifier balance du msg.sender et le montant correct de msg.value à 1 finney

    modifier enoughToken () {
        require(_token.balanceOf(msg.sender) >= 1, "Calculator: This operation costs 1 Loktoken, please credit your account.");
        _;
    }
    
    // fonction générique qu'on passera à chaque fonction pour débiter un token
    function _transaction() private {
        _token.transferFrom(_sender, _recipient, 1);
    }
    
    // Les différentes fonctions du calculateur avec application de transaction(), incrémentation du compteur des opérations via indexation (event/emit), et resultat avec le return
    function add (uint256 a, uint256 b) public payable enoughToken returns (uint256) {
        _sender = msg.sender;
        _transaction();
        _operator = "+";
        _result = a + b;
        emit Operated(_sender, a, _operator, b, _result);
        return _result;
    }
    
    function sub (uint256 a, uint256 b) public payable enoughToken returns (uint256) {
        _sender = msg.sender;
        _transaction();
        _operator = "-";
        _result = a - b;
        emit Operated(_sender, a, _operator, b, _result);
        return _result;
    }
    
    function mul (uint256 a, uint256 b) public payable enoughToken returns (uint256) {
        _sender = msg.sender;
        _transaction();
        _operator = "*";
        _result = a * b;
        emit Operated(_sender, a, _operator, b, _result);
        return _result;
    }
    
    function div (uint256 a, uint256 b) public payable enoughToken returns (uint256) {
        require(b != 0, "Calculator: impossible to divide by 0.");
        _sender = msg.sender;
        _transaction();
        _operator = "/";
        _result = a / b;
        emit Operated(_sender, a, _operator, b, _result);
        return _result;
    }
    
    function modulo (uint256 a, uint256 b) public payable enoughToken returns (uint256) {
        require(b != 0, "Calculator: impossible to operate modulo 0.");
        _sender = msg.sender;
        _transaction();
        _operator = "%";
        _result = a % b;
        emit Operated(_sender, a, _operator, b, _result);
        return _result;
    }
    function tokenAddress() public view returns(address) {
        return address(_token);
    }
}
