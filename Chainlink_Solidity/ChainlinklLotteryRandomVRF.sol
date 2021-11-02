//This is for Educational Purposes Only
pragma solidity 0.6.6;

//VRF Github
import "https://github.com/alphachainio/chainlink-lottery/blob/master/ethereum/contracts/vrf/VRFConsumerBase.sol";

//Import ChainlinkLottery_Interface.sol and ChainlinkGovernance_Interface.sol
import {get_Lottery} from "./Interfaces/ChainlinkLottery_Interface.sol";
import {ChainlinkGovernance_Interface} from "./Interfaces/ChainlinkGovernance_Interface.sol";

//Random contract inherits from the VRFConsumerBase contract
contract Random is VRFConsumerBase{
    
    //Creates internal hash variable
    bytes32 internal hash;
    
    //Creates internal fees variable
    uint256 internal fees;
    
    //Creates hash map for random number assignment
    mapping (uint=>uint) public randomNumber;
    
    //Creates hash map for requestIds
    mapping (bytes32 => uint) public requestIds;
    
    //Displays interfaces 
    ChainlinkGovernance_Interface public governance;
    
    //Creates variable to store the most recent random number generated
    uint256 public recent; 
    
    //Ropsten test-net allows for test development using ETH

     constructor(address _governance)
     //VRFs are used to generate random numbers
        VRFConsumerBase(
            0xf720CF1B963e0e7bE9F58fd471EFa67e7bF00cfb, // Ropsten VRF Coordinator
            0x20fE562d797A42Dcb3399062AE9546cd06f63280  // Ropsten LINK Token
        ) public
    {
        hash = 0xced103054e349b8dfb51352f0f8fa9b5d20dde3d06f9f43cb2b85bc64b238205;
        fees = 0.1 * 10 ** 18; // 0.1 LINK
        governance = ChainlinkGovernance_Interface(_governance);
    }

    function getRandom(uint256 Seed, uint256 LotteryIdenitity) public {
        //Makes sure that enough LINK is there to cover fees
        require(LINK.balanceOf(address(this)) > fees);
        
        //creates random number using given hash, associated fees, and User-assigned Seed Value
        bytes32 _requestId=requestRandomness(hash,fees,Seed);
        
        //assigns random value to LotteryIdenitity based on VRF and requestIds Hash map
        requestIds[_requestId]=LotteryIdenitity;
    }
    function fulfillRandomness(bytes32 requestId, uint256 randomness) external override {
        //ensures VRF coordinator is the one fufilling the function
        require(msg.sender == vrfCoordinator);
        
        //assigns variable the most recent random number
        recent = randomness;
        
        //reassigns LotteryIdenitity
        uint LotteryIdenitity = requestIds[requestId];
        
        //randomizes numbers
        randomNumber[LotteryIdenitity] = randomness;
        get_Lottery(governance.lottery()).fulfill_random(randomness);
    }
}