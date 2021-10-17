const Lottery_Migration = artifacts.require("Lottery");
const Governance_Migration = artifacts.require("ChainlinkGovernance");

module.exports = async function (deployer,network,accounts) {
  const userAddress = accounts[3];
  var governanceContract = await Governance_Migration.deployed();
  await deployer.deploy(Lottery_Migration, governanceContract.address);
};
