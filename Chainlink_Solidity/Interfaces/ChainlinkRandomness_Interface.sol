//This is for Educational Purposes Only
pragma solidity ^0.6.6;

//External interface for VRF randomness
interface VRF_Random {
    function randomNumber(uint) external view returns (uint);
    function getRandom (uint, uint) external;
    
}