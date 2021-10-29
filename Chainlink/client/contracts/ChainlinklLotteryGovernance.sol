//This is for Educational Purposes Only
pragma solidity ^0.6.6;

//Everytime a lottery is done,ChainlinkGovernance contract ensures that random numbers are generated only once per lottery
contract ChainlinkGovernance {
    
    //Variable to make sure that ChainlinkGovernance will only be called once
    uint256 public once;
    
    //address for Lottery that will be changed when init function is run
    address public Lottery;
    
    //address for randomness that will be changed when init function is run
    address public randomness;
    
    constructor() public{
        
        //establishes that ChainlinkGovernance can only be called once
        once=1;
    }
    function init(address _lottery, address _randomness) public{
        
        //checks that an random address is chosen
        require(_randomness != address(0));
        
        //checks that an Lottery address is chosen
        require(_lottery != address(0));
        
        //checks that ChainlinkGovernance has not been run before per Lottery
        require(once>0);
        
        //sets once=0 so that ChainlinkGovernance won't be run again per Lottery
        once=once-1;
        
        //sets public randomness to equal given_randomness in function init
        randomness=_randomness;
        
        //sets public Lottery to equal given _lottery in function init
        Lottery=_lottery;
    }
}