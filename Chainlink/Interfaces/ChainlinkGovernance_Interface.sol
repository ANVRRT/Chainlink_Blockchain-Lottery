//This is for Educational Purposes Only
pragma solidity ^0.6.6;

//External interface for Governance
interface ChainlinkGovernance {
    function randomness() external view returns(address);
    function lottery() external view returns(address);
}