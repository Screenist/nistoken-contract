/*
    multiOwnerWallet.sol v1.0.0
    Multi owner wallet
    
    This file is part of Screenist [NIS] token project.
    
    Author: Andor 'iFA' Rajci, Fusion Solutions KFT @ contact@fusionsolutions.io
*/
pragma solidity 0.4.26;

import "./token.sol";
import "./safeMath.sol";

contract MultiOwnerWallet {
    /* Declarations */
    using SafeMath for uint256;
    /* Structures */
    struct action_s {
        address origin;
        uint256 voteCounter;
        uint256 uid;
        mapping(address => uint256) voters;
    }
    /* Variables */
    mapping(address => bool) public owners;
    mapping(bytes32 => action_s) public actions;
    uint256 public actionVotedRate;
    uint256 public ownerCounter;
    uint256 public voteUID;
    Token public token;
    /* Constructor */
    constructor(address _tokenAddress, uint256 _actionVotedRate, address[] memory _owners) public {
        uint256 i;
        token = Token(_tokenAddress);
        require( _actionVotedRate <= 100 );
        actionVotedRate = _actionVotedRate;
        for ( i=0 ; i<_owners.length ; i++ ) {
            owners[_owners[i]] = true;
        }
        ownerCounter = _owners.length;
    }
    /* Fallback */
    function () external {
        revert();
    }
    /* Externals */
    function transfer(address _to, uint256 _amount) external returns (bool _success) {
        bytes32 _hash;
        bool    _subResult;
        _hash = keccak256(abi.encodePacked(address(token), 'transfer', _to, _amount));
        if ( actions[_hash].origin == address(0x00000000000000000000000000000000000000) ) {
            emit newTransferAction(_hash, _to, _amount, msg.sender);
        }
        if ( doVote(_hash) ) {
            _subResult = token.transfer(_to, _amount);
            require( _subResult );
        }
        return true;
    }
    function bulkTransfer(address[] memory _to, uint256[] memory _amount) public returns (bool _success) {
        bytes32 _hash;
        bool    _subResult;
        _hash = keccak256(abi.encodePacked(address(token), 'bulkTransfer', _to, _amount));
        if ( actions[_hash].origin == address(0x00000000000000000000000000000000000000) ) {
            emit newBulkTransferAction(_hash, _to, _amount, msg.sender);
        }
        if ( doVote(_hash) ) {
            _subResult = token.bulkTransfer(_to, _amount);
            require( _subResult );
        }
        return true;
    }
    function changeTokenAddress(address _tokenAddress) external returns (bool _success) {
        bytes32 _hash;
        _hash = keccak256(abi.encodePacked(address(token), 'changeTokenAddress', _tokenAddress));
        if ( actions[_hash].origin == address(0x00000000000000000000000000000000000000) ) {
            emit newChangeTokenAddressAction(_hash, _tokenAddress, msg.sender);
        }
        if ( doVote(_hash) ) {
            token = Token(_tokenAddress);
        }
        return true;
    }
    function addNewOwner(address _owner) external returns (bool _success) {
        bytes32 _hash;
        require( ! owners[_owner] );
        _hash = keccak256(abi.encodePacked(address(token), 'addNewOwner', _owner));
        if ( actions[_hash].origin == address(0x00000000000000000000000000000000000000) ) {
            emit newAddNewOwnerAction(_hash, _owner, msg.sender);
        }
        if ( doVote(_hash) ) {
            ownerCounter = ownerCounter.add(1);
            owners[_owner] = true;
        }
        return true;
    }
    function delOwner(address _owner) external returns (bool _success) {
        bytes32 _hash;
        require( owners[_owner] );
        _hash = keccak256(abi.encodePacked(address(token), 'delOwner', _owner));
        if ( actions[_hash].origin == address(0x00000000000000000000000000000000000000) ) {
            emit newDelOwnerAction(_hash, _owner, msg.sender);
        }
        if ( doVote(_hash) ) {
            ownerCounter = ownerCounter.sub(1);
            owners[_owner] = false;
        }
        return true;
    }
    /* Constants */
    function selfBalance() public view returns (uint256 _balance) {
        return token.balanceOf(address(this));
    }
    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return token.balanceOf(_owner);
    }
    function hasVoted(bytes32 _hash, address _owner) public view returns (bool _voted) {
        return actions[_hash].origin != address(0x00000000000000000000000000000000000000) && actions[_hash].voters[_owner] == actions[_hash].uid;
    }
    /* Internals */
    function doVote(bytes32 _hash) internal returns (bool _voted) {
        require( owners[msg.sender] );
        if ( actions[_hash].origin == address(0x00000000000000000000000000000000000000) ) {
            voteUID = voteUID.add(1);
            actions[_hash].origin = msg.sender;
            actions[_hash].voteCounter = 1;
            actions[_hash].uid = voteUID;
        } else if ( ( actions[_hash].voters[msg.sender] != actions[_hash].uid ) && actions[_hash].origin != msg.sender ) {
            actions[_hash].voters[msg.sender] = actions[_hash].uid;
            actions[_hash].voteCounter = actions[_hash].voteCounter.add(1);
            emit vote(_hash, msg.sender);
        }
        if ( actions[_hash].voteCounter.mul(100).div(ownerCounter) >= actionVotedRate ) {
            _voted = true;
            emit votedAction(_hash);
            delete actions[_hash];
        }
    }
    /* Events */
    event newTransferAction(bytes32 _hash, address _to, uint256 _amount, address _origin);
    event newBulkTransferAction(bytes32 _hash, address[] _to, uint256[] _amount, address _origin);
    event newChangeTokenAddressAction(bytes32 _hash, address _tokenAddress, address _origin);
    event newAddNewOwnerAction(bytes32 _hash, address _owner, address _origin);
    event newDelOwnerAction(bytes32 _hash, address _owner, address _origin);
    event vote(bytes32 _hash, address _voter);
    event votedAction(bytes32 _hash);
}
