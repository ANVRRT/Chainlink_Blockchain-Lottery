//This is for Educational Purposes Only
pragma solidity ^0.6.6;

//External interface for Lottery randomness
interface get_Lottery{
    function fulfill_random(uint) external;
}