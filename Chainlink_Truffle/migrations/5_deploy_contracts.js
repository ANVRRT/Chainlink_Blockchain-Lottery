const Governance_Migration = artifacts.require("ChainlinkGovernance");
const Random_Migration = artifacts.require("Random");
const Lottery_Migration = artifacts.require("Lottery");

module.exports = async function(deployer, network, accounts) {
  var governanceContract = await Governance_Migration.deployed();
  var randomnessContract = await Random_Migration.deployed();
  var lotteryContract = await Lottery_Migration.deployed();

  await governanceContract.init(
    lotteryContract.address,
    randomnessContract.address
  );
};