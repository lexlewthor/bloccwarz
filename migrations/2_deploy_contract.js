var BloccWarz = artifacts.require('./BloccWarz.sol')

module.exports = function(deployer, network) {
  const periodLength = 60 * 5

  deployer.deploy(BloccWarz, periodLength)
}
