/*
    token.sol v1.0.0
    Token Proxy
    
    This file is part of Screenist [NIS] token project.
    
    Author: Andor 'iFA' Rajci, Fusion Solutions KFT @ contact@fusionsolutions.io
*/
pragma solidity 0.4.26;

import "./safeMath.sol";
import "./owned.sol";
import "./tokenDB.sol";

contract Token is Owned {
    /* Declarations */
    using SafeMath for uint256;
    /* Variables */
    string  public name = "Screenist Token";
    string  public symbol = "NIS";
    uint8   public decimals = 8;
    address public libAddress;
    address public freezeAdmin;
    address public vestingAdmin;
    TokenDB public db;
    bool    public underFreeze;
    /* Constructor */
    constructor(address _owner, address _freezeAdmin, address _vestingAdmin, address _libAddress, address _dbAddress, bool _isLib) Owned(_owner) public {
        if ( ! _isLib ) {
            db = TokenDB(_dbAddress);
            libAddress = _libAddress;
            vestingAdmin = _vestingAdmin;
            freezeAdmin = _freezeAdmin;
            require( db.setAllowance(address(this), _owner, uint256(0)-1) );
            require( db.mint(address(this), 1.5e16) );
            emit Mint(address(this), 1.5e16);
        }
    }
    /* Fallback */
    function () external payable {
        owner.transfer(msg.value);
    }
    /* Externals */
    function changeLibAddress(address _libAddress) public forOwner {
        libAddress = _libAddress;
    }
    function changeDBAddress(address _dbAddress) public forOwner {
        db = TokenDB(_dbAddress);
    }
    function setFreezeStatus(bool _newStatus) public forFreezeAdmin {
        underFreeze = _newStatus;
    }
    function approve(address _spender, uint256 _value) public returns (bool _success) {
        address _trg = libAddress;
        assembly {
            let m := mload(0x40)
            calldatacopy(m, 0, calldatasize)
            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)
            switch success case 0 {
                revert(0, 0)
            } default {
                return(m, 0x20)
            }
        }
    }
    function transfer(address _to, uint256 _amount) public isNotFrozen returns(bool _success)  {
        address _trg = libAddress;
        assembly {
            let m := mload(0x40)
            calldatacopy(m, 0, calldatasize)
            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)
            switch success case 0 {
                revert(0, 0)
            } default {
                return(m, 0x20)
            }
        }
    }
    function bulkTransfer(address[] memory _to, uint256[] memory _amount) public isNotFrozen returns(bool _success)  {
        address _trg = libAddress;
        assembly {
            let m := mload(0x40)
            calldatacopy(m, 0, calldatasize)
            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)
            switch success case 0 {
                revert(0, 0)
            } default {
                return(m, 0x20)
            }
        }
    }
    function transferFrom(address _from, address _to, uint256 _amount) public isNotFrozen returns (bool _success)  {
        address _trg = libAddress;
        assembly {
            let m := mload(0x40)
            calldatacopy(m, 0, calldatasize)
            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)
            switch success case 0 {
                revert(0, 0)
            } default {
                return(m, 0x20)
            }
        }
    }
    function setVesting(address _beneficiary, uint256 _amount, uint256 _startBlock, uint256 _endBlock) public forVestingAdmin {
        address _trg = libAddress;
        assembly {
            let m := mload(0x40)
            calldatacopy(m, 0, calldatasize)
            let success := delegatecall(gas, _trg, m, calldatasize, m, 0)
            switch success case 0 {
                revert(0, 0)
            } default {
                return(m, 0)
            }
        }
    }
    function claimVesting() public isNotFrozen {
        address _trg = libAddress;
        assembly {
            let m := mload(0x40)
            calldatacopy(m, 0, calldatasize)
            let success := delegatecall(gas, _trg, m, calldatasize, m, 0)
            switch success case 0 {
                revert(0, 0)
            } default {
                return(m, 0)
            }
        }
    }
    /* Constants */
    function allowance(address _owner, address _spender) public constant returns (uint256 _remaining) {
        address _trg = libAddress;
        assembly {
            let m := mload(0x40)
            calldatacopy(m, 0, calldatasize)
            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)
            switch success case 0 {
                revert(0, 0)
            } default {
                return(m, 0x20)
            }
        }
    }
    function balanceOf(address _owner) public constant returns (uint256 _balance) {
        address _trg = libAddress;
        assembly {
            let m := mload(0x40)
            calldatacopy(m, 0, calldatasize)
            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)
            switch success case 0 {
                revert(0, 0)
            } default {
                return(m, 0x20)
            }
        }
    }
    function totalSupply() public constant returns (uint256 _totalSupply) {
        address _trg = libAddress;
        assembly {
            let m := mload(0x40)
            calldatacopy(m, 0, calldatasize)
            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)
            switch success case 0 {
                revert(0, 0)
            } default {
                return(m, 0x20)
            }
        }
    }
    function getVesting(address _owner) public constant returns(uint256 _amount, uint256 _startBlock, uint256 _endBlock, uint256 _claimedAmount) {
        address _trg = libAddress;
        assembly {
            let m := mload(0x40)
            calldatacopy(m, 0, calldatasize)
            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x80)
            switch success case 0 {
                revert(0, 0)
            } default {
                return(m, 0x80)
            }
        }
    }
    function totalVesting() public constant returns(uint256 _amount) {
        address _trg = libAddress;
        assembly {
            let m := mload(0x40)
            calldatacopy(m, 0, calldatasize)
            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)
            switch success case 0 {
                revert(0, 0)
            } default {
                return(m, 0x20)
            }
        }
    }
    function calcVesting(address _owner) public constant returns(uint256 _reward) {
        address _trg = libAddress;
        assembly {
            let m := mload(0x40)
            calldatacopy(m, 0, calldatasize)
            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)
            switch success case 0 {
                revert(0, 0)
            } default {
                return(m, 0x20)
            }
        }
    }
    /* Events */
    event AllowanceUsed(address indexed _spender, address indexed _owner, uint256 indexed _value);
    event Mint(address indexed _addr, uint256 indexed _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event VestingDefined(address _beneficiary, uint256 _amount, uint256 _startBlock, uint256 _endBlock);
    event VestingClaimed(address _beneficiary, uint256 _amount);
    /* Modifiers */
    modifier isNotFrozen {
        require( ! underFreeze );
        _;
    }
    modifier forOwner {
        require( isOwner() );
        _;
    }
    modifier forVestingAdmin {
        require( msg.sender == vestingAdmin );
        _;
    }
    modifier forFreezeAdmin {
        require( msg.sender == freezeAdmin );
        _;
    }
}
