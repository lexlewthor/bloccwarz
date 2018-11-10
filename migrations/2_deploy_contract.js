var BloccWarz = artifacts.require('./BloccWarz.sol');

module.exports = function(deployer, network) {
  const bwCashSupply = "100000000000000000000";
  let periodLength = 60 * 5;

  if (network === "development") {
    periodLength = 60;
  }

  deployer.deploy(BloccWarz, periodLength, bwCashSupply);
};
