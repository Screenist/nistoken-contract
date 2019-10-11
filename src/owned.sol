/*
    owner.sol v1.0.0
    Owner
    
    This file is part of Screenist [NIS] token project.
    
    Author: Andor 'iFA' Rajci, Fusion Solutions KFT @ contact@fusionsolutions.io
*/
pragma solidity 0.4.26;

contract Owned {
    /* Variables */
    address public owner = msg.sender;
    /* Constructor */
    constructor(address _owner) public {
        if ( _owner == address(0x00000000000000000000000000000000000000) ) {
            _owner = msg.sender;
        }
        owner = _owner;
    }
    /* Externals */
    function replaceOwner(address _owner) external returns(bool) {
        require( isOwner() );
        owner = _owner;
        return true;
    }
    /* Internals */
    function isOwner() internal view returns(bool) {
        return owner == msg.sender;
    }
    /* Modifiers */
    modifier forOwner {
        require( isOwner() );
        _;
    }
}
