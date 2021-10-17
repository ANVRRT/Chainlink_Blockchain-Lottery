//This is for Educational Purposes Only
pragma solidity ^0.6.6;

//Chainlink Github
import"@chainlink/contracts/src/v0.6/ChainlinkClient.sol";

//Import ChainlinkRandomness_Interface.sol and ChainlinkGovernance_Interface.sol
import {VRF_Random} from "./Interfaces/ChainlinkRandomness_Interface.sol";
import {ChainlinkGovernance_Interface} from "./Interfaces/ChainlinkGovernance_Interface.sol";


//Lottery contract inherits from the ChainlinkClient contract
contract Lottery is ChainlinkClient {
    
        //Defines lottery states as open, closed,or calculating
        enum Lottery_state { Open, Closed, Calculating }

        //Displays the state of the lottery externally
        Lottery_state public Lottery_Status;

        //Stores enum value of Lottery_state
        uint256 public LotteryValue;

        //Creates a list for Players to join
        address payable[] public players;

        //Displays Interfaces 
        ChainlinkGovernance_Interface public governance;
        
        //Defines Entry Costs as .01 ETH
        //This value can be changed to whatever entry costs are required
        uint256 Minimum_requirement = 1000000000000000;
        
        //Defines Gas/Transactional Fees to use Oracle Nodes as .1 LINK
        uint256 Payment_to_Oracle=100000000000000000;
        
        //Sets Chainlink Alarm clocks by connecting them to Kovan Testnet LINK Token/Oracles
        //Kovan Testnet Website: https://kovan-testnet.github.io/website/
        //Comment _link if using Main network
        address _link=0xa36085F69e2889c224210F603D836748e7dC0088;
        address Chainlink_Oracle_Alarm = 0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b;
        bytes32 Chainlink_Alarm_JobId = "982105d690504c5d9ce374d040c08654";


    //Sets initial values for variables
    constructor(address _governance) public
    {
        //Required to connect with Chainlink Oracles
        //Currently using Kovan Testnet LINK token
        setChainlinkToken(_link);
    
        //If using Main network, use setPublicChainlinkToken() instead  
        //setPublicChainlinkToken();

        //Intializes LotteryValue to Closed (Value {1})
        LotteryValue=1;
    
        //Sets Lottery State as Closed
        Lottery_Status=Lottery_state.Closed;
        
        //sets value of Governance for VRF_Random
        governance = ChainlinkGovernance_Interface(_governance);
    }
    
    
    //Function to check if lottery is open and also require payment before adding to Player list
    function enter() public payable {
        
        //Requires Players to pay entry costs
        assert(msg.value == Minimum_requirement);
        
        //Checks that Lottery is open
        assert(Lottery_Status == Lottery_state.Open);
        
        //Adds new player to the existing Player list
        players.push(msg.sender);
    }

    //Function to display total amount of players 
    function player_count() public view returns(address payable[] memory) {
        return players;
    }

    //Function to display toal amount of earnings in a given Lottery
    function Total() public view returns(uint256){
        return address(this).balance;
    }
    
    
    //Private Function to pick winner randomly using Chainlink VRFs
    function PickWinner() private {
        
        //Checks that Lottery is Calculating Winner
        require(Lottery_Status==Lottery_state.Calculating,"The Lottery hasn't chosen a winner yet.");
        //Uses Chainlink VRF function in ChainlinkLotteryGovernance.sol to generate randomness
        VRF_Random(governance.randomness()).getRandom(LotteryValue,LotteryValue);
    }
    

      //Function to stop player enteries and initiate the PickWinner() function
    function fulfill_alarm(bytes32 _requestId)
    
        //Ensures that the request is valid and viewable externally 
        public  
        recordChainlinkFulfillment(_requestId)
            {
                //Checks that Lottery is Calculating Winner   
                require(Lottery_Status==Lottery_state.Open,"The Lottery is opening soon!");
                
                //Changes Lottery Status to Calculating
                Lottery_Status=Lottery_state.Calculating;
                
                //Changes LotteryValue to Calculating (Value {2})
                LotteryValue=LotteryValue + 1;
                
                //Initiates PickWinner() function
                PickWinner();
                
            }

     
    //Function to start new lottery and send Alarm Request to Oracle       
    function start_Lottery(uint256 duration) public {
        
        //Ensures previous lottery is closed
        require(Lottery_Status==Lottery_state.Closed,"Lottery opening soon");
        
        //Starts new lottery
        Lottery_Status=Lottery_state.Open;
        
        //Connects to Chainlink Alarm
        Chainlink.Request memory req = buildChainlinkRequest(Chainlink_Alarm_JobId, address(this), this.fulfill_alarm.selector);
        
        //Returns fulfill_alarm function after now + duration amount of time
        req.addUint("until", now + duration);
        
        //Sends the Chainlink Request to The Chainlink Alarm, and sends associated Gas/Transactional fees)
        sendChainlinkRequestTo(Chainlink_Oracle_Alarm,req,Payment_to_Oracle);
    
    }

  
    //Function to decide who is the winner and transfer winnings
    function fulfill_randomness(uint256 randomness) external {
        //Checks that Lottery is Calculating Winner
        require(Lottery_Status==Lottery_state.Calculating,"The Lottery hasn't chosen a winner yet.");
        
        //Checks that VRF randomness is completed
        require(randomness>0,"No random!");
        
        //Converts the randomized number to a value from 0 to players.length in order to pick a winner
        uint256 index = randomness % players.length;
        
        //Transfer Total earnings of the lottery to the winning player
        players[index].transfer(address(this).balance);
        
        //Clears out player list
        players = new address payable[](0);
        
        //Closes lottery
        Lottery_Status==Lottery_state.Closed;

        //Uncomment to loop Lottery process
        //start_Lottery();
    }
    
    
}