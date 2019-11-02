/*
    tokenLib.sol v1.0.1
    Token Library
    
    This file is part of Screenist [NIS] token project.
    
    Author: Andor 'iFA' Rajci, Fusion Solutions KFT @ contact@fusionsolutions.io
*/
pragma solidity 0.4.26;

import "./token.sol";
import "./tokenDB.sol";

contract TokenLib is Token {
    /* Constructor */
    constructor(address _owner, address _freezeAdmin, address _vestingAdmin, address _libAddress, address _dbAddress) Token(_owner, _freezeAdmin, _vestingAdmin, _libAddress, _dbAddress, true) public {}
    /* Externals */
    function approve(address _spender, uint256 _amount) public returns (bool _success) {
        _approve(_spender, _amount);
        return true;
    }
    function transfer(address _to, uint256 _amount) public returns (bool _success) {
        _transfer(msg.sender, _to, _amount);
        return true;
    }
    function bulkTransfer(address[] memory _to, uint256[] memory _amount) public returns (bool _success) {
        uint256 i;
        require( _to.length == _amount.length );
        require( db.bulkTransfer(msg.sender, _to, _amount) );
        for ( i=0 ; i<_to.length ; i++ ) {
            require( _amount[i] > 0 );
            require( _to[i] != address(0x0000000000000000000000000000000000000000) );
            require( msg.sender != _to[i] );
            emit Transfer(msg.sender, _to[i], _amount[i]);
        }
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool _success) {
        bool    _subResult;
        uint256 _remaining;
        if ( _from != msg.sender ) {
            (_subResult, _remaining) = db.getAllowance(_from, msg.sender);
            require( _subResult );
            _remaining = _remaining.sub(_amount);
            require( db.setAllowance(_from, msg.sender, _remaining) );
            emit AllowanceUsed(msg.sender, _from, _amount);
        }
        _transfer(_from, _to, _amount);
        return true;
    }
    function setVesting(address _beneficiary, uint256 _amount, uint256 _startBlock, uint256 _endBlock) {
        require( _beneficiary != address(0x0000000000000000000000000000000000000000) );
        if ( _amount == 0 ) {
            _startBlock = 0;
            _endBlock = 0;
        } else {
            require( _endBlock > _startBlock );
        }
        require( db.setVesting(_beneficiary, _amount, _startBlock, _endBlock, 0) );
        emit VestingDefined(_beneficiary, _amount, _startBlock, _endBlock);
    }
    function claimVesting() public {
        uint256 _amount;
        uint256 _startBlock;
        uint256 _endBlock;
        uint256 _claimedAmount;
        uint256 _reward;
        ( _amount, _startBlock, _endBlock, _claimedAmount ) = _getVesting(msg.sender);
        _reward = _calcVesting(_amount, _startBlock, _endBlock, _claimedAmount);
        require( _reward > 0 );
        _claimedAmount = _claimedAmount.add(_reward);
        if ( _claimedAmount == _amount ) {
            require( db.setVesting(msg.sender, 0, 0, 0, 0) );
            emit VestingDefined(msg.sender, 0, 0, 0);
        } else {
            require( db.setVesting(msg.sender, _amount, _startBlock, _endBlock, _claimedAmount) );
            emit VestingDefined(msg.sender, _amount, _startBlock, _endBlock);
        }
        _transfer(address(this), msg.sender, _reward);
        emit VestingClaimed(msg.sender, _reward);
    }
    /* Constants */
    function allowance(address _owner, address _spender) public constant returns (uint256 _remaining) {
        bool _subResult;
        (_subResult, _remaining) = db.getAllowance(_owner, _spender);
        require( _subResult );
    }
    function balanceOf(address _owner) public constant returns (uint256 _balance) {
        bool _subResult;
        (_subResult, _balance) = db.getBalance(_owner);
        require( _subResult );
    }
    function totalSupply() public constant returns (uint256 _totalSupply) {
        bool _subResult;
        (_subResult, _totalSupply) = db.getTotalSupply();
        require( _subResult );
    }
    function totalVesting() public constant returns (uint256 _totalVesting) {
        bool _subResult;
        (_subResult, _totalVesting) = db.getTotalVesting();
        require( _subResult );
    }
    function getVesting(address _owner) public constant returns(uint256 _amount, uint256 _startBlock, uint256 _endBlock, uint256 _claimedAmount) {
        return _getVesting(_owner);
    }
    function calcVesting(address _owner) public constant returns(uint256 _reward) {
        uint256 _amount;
        uint256 _startBlock;
        uint256 _endBlock;
        uint256 _claimedAmount;
        ( _amount, _startBlock, _endBlock, _claimedAmount ) = _getVesting(_owner);
        return _calcVesting(_amount, _startBlock, _endBlock, _claimedAmount);
    }
    /* Internals */
    function _transfer(address _from, address _to, uint256 _amount) internal {
        require( _amount > 0 );
        require( _from != address(0x0000000000000000000000000000000000000000) && _to != address(0x0000000000000000000000000000000000000000) );
        require( db.transfer(_from, _to, _amount) );
        emit Transfer(_from, _to, _amount);
    }
    function _approve(address _spender, uint256 _amount) internal {
        require( msg.sender != _spender );
        require( db.setAllowance(msg.sender, _spender, _amount) );
        emit Approval(msg.sender, _spender, _amount);
    }
    function _getVesting(address _owner) internal constant returns(uint256 _amount, uint256 _startBlock, uint256 _endBlock, uint256 _claimedAmount) {
        bool _subResult;
        bool _valid;
        ( _subResult, _amount, _startBlock, _endBlock, _claimedAmount, _valid ) = db.getVesting(_owner);
        require( _subResult );
    }
    function _calcVesting(uint256 _amount, uint256 _startBlock, uint256 _endBlock, uint256 _claimedAmount) internal constant returns(uint256 _reward) {
        if ( _amount > 0 && block.number > _startBlock ) {
            _reward = _amount.mul( block.number.sub(_startBlock) ).div( _endBlock.sub(_startBlock) );
            if ( _reward > _amount ) {
                _reward = _amount;
            }
            if ( _reward <= _claimedAmount ) {
                _reward = 0;
            } else {
                _reward = _reward.sub(_claimedAmount);
            }
        }
    }
}
