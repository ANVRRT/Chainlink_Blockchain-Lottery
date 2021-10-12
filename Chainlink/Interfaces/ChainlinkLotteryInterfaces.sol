pragma solidity ^0.8.8;

interface ChainlinkGovernance {
    function randomness() external view returns(address);
    function lottery() external view returns(address);
}

interface get_Lottery{
    function fulfill_random(uint) external;
}

interface VRF_Random {
    function randomNumber(uint) external view returns (uint);
    function getRandom (uint, uint) external;
    
}