const Governance_Migration = artifacts.require("ChainlinkGovernance");

module.exports = async function (deployer,network,accounts) {
  await deployer.deploy(Governance_Migration);
};
