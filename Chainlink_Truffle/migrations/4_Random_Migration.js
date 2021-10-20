const Random_Migration = artifacts.require("Random");
const Governance_Migration = artifacts.require("ChainlinkGovernance");

module.exports = async function (deployer, network, accounts) {
  // const userAddress = accounts[3];
  var governanceContract = await Governance_Migration.deployed();
  await deployer.deploy(Random_Migration, governanceContract.address);
};
