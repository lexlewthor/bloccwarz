var BloccWarz = artifacts.require('./BloccWarz.sol');

module.exports = function(deployer) {
  const periodLength = 60 * 5;
  const bwCashSupply = "100000000000000000000";

  deployer.deploy(BloccWarz, periodLength, bwCashSupply);
};
