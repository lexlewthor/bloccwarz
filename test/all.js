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
  let snapshotId, bloccWarz, bwcTokenAddress, bwcToken, user1, user2, user3

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
    it('expects correct values for minimum purchase', async () => {
      const value = await bloccWarz.minTokenTransactionWei()
      await bloccWarz.buyTokens({ from: user1.address, value })
      const contractWei = await web3.eth.getBalance(bloccWarz.address)
      const userBWCWei = await bwcToken.balanceOf(user1.address)
      const totalTokens = await bwcToken.totalSupply()

      assert.equal(contractWei.toString(), value.toString())
      assert.equal(userBWCWei.toString(), totalTokens.toString())
    })

    it('fails with insufficient purchase amount wei', async () => {
      const minWei = await bloccWarz.minTokenTransactionWei()
      const value = (new BN(minWei)).minus(1)
      await bloccWarz.buyTokens({ from: user1.address, value })
        .should
        .be
        .rejectedWith('Must send minimum transaction amount to buy tokens')
    })
  })

  describe('sellTokens', () => {
    it('expects correct values for minimum sale', async () => {
      // user1 buys enough tokens where sale will meet minimum price
      const minPurchaseWei = await bloccWarz.minTokenTransactionWei()
      const value = minPurchaseWei * 10
      await bloccWarz.buyTokens({ from: user1.address, value })

      // collect values before sell
      const userBWCWeiBefore = await bwcToken.balanceOf(user1.address)
      const userWeiBefore = await web3.eth.getBalance(user1.address)

      // user1 sells all tokens
      await bwcToken.approve(bloccWarz.address, userBWCWeiBefore, { from: user1.address })
      await bloccWarz.sellTokens(userBWCWeiBefore, { from: user1.address })

      const userBWCWeiAfter = await bwcToken.balanceOf(user1.address)
      const contractWeiAfter = await web3.eth.getBalance(bloccWarz.address)
      const userWeiAfter = await web3.eth.getBalance(user1.address)
      const netUser = (new BN(userWeiAfter)).minus(new BN(userWeiBefore))
      const totalTokens = await bwcToken.totalSupply()

      assert.isTrue(netUser < 0)
      assert.equal(userBWCWeiAfter.toString(), '0')
      assert.equal(contractWeiAfter.toString(), '19')
      assert.equal(totalTokens.toString(), '0')
    })

    it('fails with 0 tokens provided', async () => {
      // user1 buys enough tokens where sale will meet minimum price
      const value = await bloccWarz.minTokenTransactionWei() * 10
      await bloccWarz.buyTokens({ from: user1.address, value })

      // collect values before sell
      const userBWCWeiBefore = await bwcToken.balanceOf(user1.address)

      // user1 sells 0
      await bwcToken.approve(bloccWarz.address, userBWCWeiBefore, { from: user1.address })
      await bloccWarz.sellTokens(0, { from: user1.address })
        .should
        .be
        .rejectedWith('Token amount for sale must be greater than 0')
    })

    it('fails with insufficient sale amount wei', async () => {
      // user1 buys enough tokens where sale will NOT meet minimum price
      const value = await bloccWarz.minTokenTransactionWei()
      await bloccWarz.buyTokens({ from: user1.address, value })

      // collect values before sell
      const userBWCWeiBefore = await bwcToken.balanceOf(user1.address)

      // user1 sells all
      await bwcToken.approve(bloccWarz.address, userBWCWeiBefore, { from: user1.address })
      await bloccWarz.sellTokens(userBWCWeiBefore, { from: user1.address })
        .should
        .be
        .rejectedWith('Token sale value must meet minimum transaction amount')
    })

    it('fails token transfer', async () => {
      // user1 buys enough tokens where sale will meet minimum price
      const value = await bloccWarz.minTokenTransactionWei() * 10
      await bloccWarz.buyTokens({ from: user1.address, value })

      // collect values before sell
      const userBWCWeiBefore = await bwcToken.balanceOf(user1.address)

      // user1 sells all but does not approve
      await bloccWarz.sellTokens(userBWCWeiBefore, { from: user1.address })
        .should
        .be
        .rejectedWith('Returned error: VM Exception while processing transaction: revert')
    })
  })
})