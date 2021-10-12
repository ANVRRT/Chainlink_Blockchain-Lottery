pragma solidity ^0.8.8;

contract ChainlinkGovernance {
    
    uint256 public once;
    address public Lottery;
    address public randomness;
    
    constructor() public{
        once=1;
    }
    function init(address _lottery, address _randomness) public{
        require(_randomness != address(0));
        require(_lottery != address(0));
        randomness=_randomness;
        Lottery=_lottery;
    }
}