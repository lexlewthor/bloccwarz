const BN = require('bignumber.js')
const should = require('chai')
const HttpProvider = require('ethjs-provider-http')
const EthRPC = require('ethjs-rpc')
const TestData = require('./data.json')
const BloccWarz = artifacts.require('./BloccWarz.sol')
const BWCToken = artifacts.require('./MintAndBurnToken')

should
  .use(require('chai-as-promised'))
  .should()

const ethRPC = new EthRPC(new HttpProvider('http://localhost:8545'))

async function snapshot() {
  return new Promise((accept, reject) => {
    ethRPC.sendAsync({ method: `evm_snapshot` }, (err, result) => {
      if (err) {
        reject(err)
      } else {
        accept(result)
      }
    })
  })
}

async function restore(snapshotId) {
  return new Promise((accept, reject) => {
    ethRPC.sendAsync({ method: `evm_revert`, params: [snapshotId] }, (err, result) => {
      if (err) {
        reject(err)
      } else {
        accept(result)
      }
    })
  })
}

async function moveForwardSecs(secs) {
  await ethRPC.sendAsync({
    jsonrpc: '2.0', method: `evm_increaseTime`,
    params: [secs],
    id: 0
  }, (err) => { `error increasing time` });
  const start = Date.now();
  while (Date.now() < start + 300) { }
  await ethRPC.sendAsync({ method: `evm_mine` }, (err) => { });
  while (Date.now() < start + 300) { }
  return true
}

function getEventParams(tx, event) {
  if (tx.logs.length > 0) {
    for (let idx = 0; idx < tx.logs.length; idx++) {
      if (tx.logs[idx].event == event) {
        return tx.logs[idx].args
      }
    }
  }
  return false
}

contract('BloccWarz', accounts => {
  let snapshotId, bloccWarz, bwcToken, user1, user2, user3

  before('deploy contract', async () => {
    bloccWarz = await BloccWarz.deployed()
    bwcTokenAddress = await bloccWarz.bwToken()
    bwcToken = await BWCToken.at(bwcTokenAddress)

    owner = {
      address: accounts[0],
      pk: TestData.privateKeys[0]
    }
    user1 = {
      address: accounts[1],
      pk: TestData.privateKeys[1]
    }
    user2 = {
      address: accounts[2],
      pk: TestData.privateKeys[2]
    }
  })

  beforeEach(async () => {
    snapshotId = await snapshot()
  })

  afterEach(async () => {
    await restore(snapshotId)
  })

  describe('buyTokens', () => {
    it('has correct values for minimum purchase', async () => {
      const value = await bloccWarz.minimumTokenPurchaseWei()
      const ownerWeiBefore = await web3.eth.getBalance(owner.address)
      await bloccWarz.buyTokens({ from: user1.address, value })
      const contractWei = await web3.eth.getBalance(bloccWarz.address)
      const ownerWeiAfter = await web3.eth.getBalance(owner.address)
      const userBWCWei = await bwcToken.balanceOf(user1.address)
      const netOwner = (new BN(ownerWeiAfter)).minus(new BN(ownerWeiBefore))
      const totalTokens = await bwcToken.totalSupply()

      assert.equal(netOwner.toString(), '10')
      assert.equal(contractWei.toString(), '3990')
      assert.equal(userBWCWei.toString(), '2824')
      assert.equal(userBWCWei.toString(), totalTokens.toString())
    })
  })
})