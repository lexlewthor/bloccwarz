pragma solidity 0.4.25;

import { MintAndBurnToken } from "./MintAndBurnToken.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract BloccWarz is Ownable {
  using SafeMath for uint256;

  // VARIABLES

  // Financial
  MintAndBurnToken public bwToken;
  uint256 public poolBalance = 0;
  uint256 public minTokenTransactionWei = 400; // enforce a minimum purchase/sale amount
  uint256 public transactionFeeAs1PctDenom = 4; // used to keep fee calculations as integers using
  uint256 public tokenBWCWeiLockup = 1e21; // 1000 tokens will stay locked in the contract
  // Game data
  uint256 public periodLength = 300; // time length of each period in seconds
  uint256 public currentPeriod = 0; // index of current period
  uint256 public initFood = 1e18;
  uint256 public initMedicine = 1e18;
  uint256 public initOre = 1e18;
  uint256 public initPopulation = 1e6;
  uint256 public initArmy = 1e5;
  mapping(address => Player) public players;// store players data by address
  mapping(address => mapping(address => Battle)) public battles; // attacker -> defender -> battle
  mapping(uint256 => Period) public periods;// store data about each period by period index

  // TYPES

  enum BattleState {
    STARTED,
    ENDED,
    EXPIRED
  }

  struct Period {
    uint256 playersSpawned;
    uint256 playersPlayed;
    uint256 battlesStarted;
    uint256 battlesEnded;
    uint256 startTime; // the starting unix timestamp in seconds
    uint256 endTime; // the ending unix timestamp in seconds
  }

  struct Player {
    uint256 periodSpawned; // the period in which the player joined the game
    uint256 periodLastPlayed; // the last period in which the player has interacted
    uint256 periodsPlayedTotal; // the total count of periods a player has interacted
    // Resources
    uint256 food;
    uint256 medicine;
    uint256 ore;
    uint256 population;
    uint256 army;
    // Battles
    uint256 battlesTotal;
    uint256 battlesWon;
  }

  struct Battle {
    BattleState state;
    uint256 periodStarted;
    // TODO score
  }

  // EVENTS

  event PlayerSpawned(
    address account
  );

  event PlayerHarvest(
    address account,
    uint256 food,
    uint256 medicine,
    uint256 ore,
    uint256 population
  );

  event BattleStart(
    uint256 period,
    address attacker,
    address defender
  );

  event BattleEnd(
    uint256 period,
    address attacker,
    address defender,
    address winner
    // TODO results
  );

  // CONSTRUCTOR

  constructor (
    uint256 _periodLength
  ) public {
    // set period length and deploy token
    periodLength = _periodLength;
    bwToken = new MintAndBurnToken('BloccWarzCash', 18, 'BLCCWZC');
    // init period 0
    uint256 startTime = now;
    periods[currentPeriod].startTime = startTime;
    periods[currentPeriod].endTime = SafeMath.add(startTime, periodLength);
  }

  // GAME METHODS

  function updatePeriod() public {
    while (now >= periods[currentPeriod].endTime) {
      Period memory prevPeriod = periods[currentPeriod];
      currentPeriod += 1;
      periods[currentPeriod].startTime = prevPeriod.endTime;
      periods[currentPeriod].endTime = SafeMath.add(prevPeriod.endTime, periodLength);
    }
  }

  function joinGame() public {
    updatePeriod();
    require(currentPeriod > 0, "Can not join in 0th period");
    // check against player rejoining
    require(players[msg.sender].periodSpawned == 0, "Player already exists");
    // initialize player
    players[msg.sender] = Player(
      currentPeriod,
      currentPeriod,
      1,
      initFood,
      initMedicine,
      initOre,
      initPopulation,
      initArmy,
      0,
      0
    );
    // log event
    emit PlayerSpawned(msg.sender);
  }

  // FINANCIAL METHODS

  function buyTokens() public payable {
    // Purchase must be enough wei for contract to collect fee
    require(msg.value >= minTokenTransactionWei, "Must send minimum transaction amount to buy tokens");
    // Calculate fee as a fraction of 1%
    uint256 feeWei = SafeMath.div(SafeMath.div(msg.value, 100), transactionFeeAs1PctDenom);
    uint256 purchaseWei = SafeMath.sub(msg.value, feeWei);
    // Determine how many tokens to be minted
    // f(x) = 0.001x
    // F(x) = (x^2)/2000 + C
    // purchaseWei = ((bwToken.totalSupply() + tokensMinted)^2)/2000 - poolBalance
    // tokensMinted = sqrt(2000 * (purchaseWei + poolBalance)) - bwToken.totalSupply()
    uint256 tokensMinted = SafeMath.sub(
      sqrt(SafeMath.mul(2000, SafeMath.add(purchaseWei, poolBalance))),
      bwToken.totalSupply()
    );
    // mint tokens for sender
    bwToken.mint(msg.sender, tokensMinted);
    // incerement pool balance
    poolBalance = SafeMath.add(poolBalance, purchaseWei);
  }

  function sellTokens(uint256 _tokensBWCWei) public {
    require(_tokensBWCWei > 0, "Token amount for sale must be greater than 0");
    // Calculate wei value of tokens for sale
    // f(x) = 0.001x
    // F(x) = (x^2)/2000 + C
    // salePriceWei = poolBalance - ((bwToken.totalSupply() - _tokensBWCWei)^2)/2000
    uint256 targetTokenSupply = SafeMath.sub(bwToken.totalSupply(), _tokensBWCWei);
    uint256 salePriceWei = SafeMath.sub(
      poolBalance,
      SafeMath.div(
        SafeMath.mul(targetTokenSupply, targetTokenSupply),
        2000
      )
    );
    require(salePriceWei >= minTokenTransactionWei, "Token sale value must meet minimum transaction amount");
    // This should be impossible to trigger
    // require(poolBalance >= salePriceWei, "Contract balance insufficient for sale");
    // Calculate fee as a fraction of 1% of sale price
    uint256 feeWei = SafeMath.div(SafeMath.div(salePriceWei, 100), transactionFeeAs1PctDenom);
    uint256 sellerBalanceWei = SafeMath.sub(salePriceWei, feeWei);
    // transfer the tokens
    require(bwToken.transferFrom(msg.sender, this, _tokensBWCWei));
    // Burn tokens
    bwToken.burn(_tokensBWCWei);
    // Pay seller
    msg.sender.transfer(sellerBalanceWei);
    // update pool balance
    poolBalance = SafeMath.sub(poolBalance, sellerBalanceWei);
  }

  function withdrawWei(uint256 _amountWei) onlyOwner public  {
    // Owner can never take from the pool, only contract profits
    require(_amountWei <= SafeMath.sub(address(this).balance, poolBalance));
    owner().transfer(_amountWei);
  }

  function withdrawTokens(uint256 _tokensBWCWei) onlyOwner public  {
    // Owner can withdraw tokens collected by the contract above the lockup amount
    require(bwToken.balanceOf(this) > tokenBWCWeiLockup, "Not enough tokens locked up");
    require(bwToken.transfer(owner(), _tokensBWCWei), "Contract has not enough tokens for withdraw");
  }

  // UTIL

  function sqrt(uint x) internal pure returns (uint y) {
    uint z = (x + 1) / 2;
    y = x;
    while (z < y) {
        y = z;
        z = (x / z + z) / 2;
    }
  }

  // FALLBACK

  function() external payable {}
}
