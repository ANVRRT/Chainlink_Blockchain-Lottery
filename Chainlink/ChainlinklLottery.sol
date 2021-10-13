//This is for Educational Purposes Only
pragma solidity ^0.6.6;

//Chainlink Github
import "https://github.com/smartcontractkit/chainlink/contracts/src/v0.6/ChainlinkClient.sol";

//Import ChainlinkRandomness_Interface.sol and ChainlinkGovernance_Interface.sol
import {VRF_Random} from "./Interfaces/ChainlinkRandomness_Interface.sol";
import {ChainlinkGovernance} from "./Interfaces/ChainlinkGovernance_Interface.sol";


//Lottery contract inherits from the ChainlinkClient contract
contract Lottery is ChainlinkClient {
    
        //Sets Chainlink Alarm clocks by connecting them to Kovan Testnet Oracles
        //Kovan Testnet Website: https://kovan-testnet.github.io/website/
        address Chainlink_Oracle_Alarm = 0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b;
        bytes32 Chainlink_Alarm_JobId = "982105d690504c5d9ce374d040c08654";
        
        //Defines Entry Costs as .0025 ether (~8.75 USD as of 10/12/2021)
        //This value can be changed to whatever entry costs are required
        uint256 Minimum_requirement=.0025 ether;
        
        //Defines Gas/Transactional Fees to use Oracle Nodes(.1 LINK=0.00070023 Ether)
        uint256 Payment_to_Oracle= 0.1 * 10 ** 18;
        
        //Defines lottery states as open, closed,or calculating
        enum Lottery_state { Open, Closed, Calculating }
    
        //Displays the state of the lottery externally
        Lottery_state public Lottery_Status;
        
        //displays interfaces 
        ChainlinkGovernance public governance;
    
        //Creates a list for Players to join
        address payable[] public players;
    
        //Counts how many Lotteries have been played
        uint256 public LotteryCount;
    
    
    //Sets initial values for variables
    constructor(address _governance) public
    {
        //Required to connect with Chainlink Oracles
        setPublicChainlinkToken();
    
        //First Lottery
        LotteryCount=1;
    
        //Sets Lottery State as Closed
        Lottery_Status=Lottery_state.Closed;
        
        governance = ChainlinkGovernance(_governance);
    }
    
    
    //Function to check if lottery is open and also require payment before adding to Player list
    function enter() public payable {
        
        //Requires Players to pay entry costs
        assert(msg.value == Minimum_requirement);
        
        //Checks that Lottery is open
        assert(Lottery_Status == Lottery_state.Open);
        
        //adds new player to the existing Player list
        players.push(msg.sender);
    }
    
    
    //function to display total amount of players 
    function player_count()public view returns(address payable[] memory){
        return players;
    }
    
    
    //function to display toal amount of earnings in a given Lottery
    function Total() public view returns(uint256){
        return address (this).balance;
    }
    
    
    //Private Function to pick winner randomly using Chainlink VRFs
    function PickWinner() private {
        
        //Checks that Lottery is Calculating Winner
        require(Lottery_Status==Lottery_state.Calculating);
        
        //Uses Chainlink VRF function in ChainlinkLotteryGovernance.sol to generate randomness
        VRF_Random(governance.randomness()).getRandom(LotteryCount,LotteryCount);
    }
    
    
    //Function to stop player enteries and initiate the PickWinner() function
    function fulfill_alarm(bytes32 _requestId)
    
        //Ensures that the request is valid and viewable externally 
        public  
        recordChainlinkFulfillment(_requestId)
            {
                //Checks that Lottery is Calculating Winner   
                require(Lottery_Status==Lottery_state.Open);
                
                //Changes Lottery Status to Calculating
                Lottery_Status=Lottery_state.Calculating;
                
                //Increases the Completed Lottery Count by 1 
                LotteryCount=LotteryCount + 1;
                
                //Initiates PickWinner() function
                PickWinner();
                
            }
     
     
    //Function to start new lottery and         
    function start_Lottery(uint256 duration) public {
        
        //Ensures previous lottery is closed
        require(Lottery_Status==Lottery_state.Closed);
        
        //Starts new lottery
        Lottery_Status=Lottery_state.Open;
        
        //Connects to Chainlink Alarm
        Chainlink.Request memory req = buildChainlinkRequest(Chainlink_Alarm_JobId, address(this), this.fulfill_alarm.selector);
        
        //Returns fulfill_alarm function after now + duration amount of time
        req.addUint("until", now + duration);
        
        //Sends the Chainlink Request to The Chainlink Alarm, and sends associated Gas/Transactional fees)
        sendChainlinkRequestTo(Chainlink_Oracle_Alarm,req,Payment_to_Oracle);
    
    
    }
    function fulfill_randomness(uint256 randomness) external{
        //Checks that Lottery is Calculating Winner
        require(Lottery_Status==Lottery_state.Calculating);
        
        //Checks that VRF randomness is completed
        require(randomness>0);
        
        //converts the randomized number to a value from 0 to players.length in order to pick a winner
        uint256 index=randomness%players.length;
        
        //transfer Total earnings of the lottery to the winning player
        players[index].transfer(address(this).balance);
        
        //clears out player list
        players = new address payable[](0);
        
        //closes lottery
        Lottery_Status==Lottery_state.Closed;
    }
    
    
}