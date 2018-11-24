pragma solidity 0.4.25;

import { MintAndBurnToken } from "./MintAndBurnToken.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract BloccWarz is Ownable {
  using SafeMath for uint256;

  // Contract variables
  MintAndBurnToken public bwToken;
  uint256 public poolBalance = 0;
  uint256 public periodLength = 300; // time length of each period in seconds
  uint256 public currentPeriod = 0; // index of current period
  uint256 public minimumTokenPurchaseWei = 4000; // enforce a minimum purchase amount
  uint256 public transactionFeeAs1PctDenom = 4; // used to keep fee calculations as integers using
  mapping(address => Player) public players;
  mapping(address => mapping(address => Battle)) public battles; // attacker -> defender -> battle
  mapping(uint256 => Period) public periods;

  // Data structures
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
    // Battles
    uint256 battlesTotal;
    uint256 battlesWon;
  }

  struct Battle {
    BattleState state;
    uint256 periodStarted;
    // TODO score
  }

  // Events
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

  constructor (
    uint256 _periodLength
  ) public {
    periodLength = _periodLength;
    bwToken = new MintAndBurnToken('BloccWarzCash', 18, 'BLCCWZC');
  }

  function updatePeriod() public {
    while (now >= periods[currentPeriod].endTime) {
      Period memory prevPeriod = periods[currentPeriod];
      currentPeriod += 1;
      periods[currentPeriod].startTime = prevPeriod.endTime;
      periods[currentPeriod].endTime = SafeMath.add(prevPeriod.endTime, periodLength);
    }
  }

  function buyTokens() public payable {
    // Purchase must be enough wei for owner to collect fee
    require(msg.value >= minimumTokenPurchaseWei, "Must send minimum purchase amount to buyTokens()");
    // Calculate fee as a fraction of 1%
    uint256 feeWei = SafeMath.div(SafeMath.div(msg.value, 100), transactionFeeAs1PctDenom);
    uint256 purchaseWei = SafeMath.sub(msg.value, feeWei);
    // Determine how many tokens to be minted
    // f(x) = 0.001x
    // F(x) = (x^2)/2000 + C
    // purchaseWei = ((bwToken.totalSupply() + tokensMinted)^2)/2000 - poolBalance
    // tokensMinted = sqrt(2000 * (purchaseWei - poolBalance)) - bwToken.totalSupply()
    uint256 tokensMinted = SafeMath.sub(
      sqrt(SafeMath.mul(2000, SafeMath.sub(purchaseWei, poolBalance))),
      bwToken.totalSupply()
    );
    // mint tokens for sender
    bwToken.mint(msg.sender, tokensMinted);
    // Pay contract owner
    owner().transfer(feeWei);
    // incerement balance
    poolBalance = SafeMath.add(poolBalance, purchaseWei);
  }

  function sellTokens(uint256 _tokensBWCWei) public {
    require(_tokensBWCWei > 0, "Sale amount must be greater than 0");
    // Sender must have enough tokens
    require(bwToken.balanceOf(msg.sender) >= _tokensBWCWei, "Sender has not enough tokens to sell");
    // Calculate wei value of tokens for sale
    // f(x) = 0.001x
    // F(x) = (x^2)/2000 + C
    // salePriceWei = address(this).balance - ((bwToken.totalSupply() - _tokensBWCWei)^2)/2000
    uint256 targetTokenSupply = SafeMath.sub(bwToken.totalSupply(), _tokensBWCWei);
    uint256 salePriceWei = SafeMath.sub(
      address(this).balance,
      SafeMath.div(
        SafeMath.mul(targetTokenSupply, targetTokenSupply),
        2000
      )
    );
    require(address(this).balance >= salePriceWei, "Contract balance insufficient for sale");
    // Calculate fee as a fraction of 1% of sale price
    uint256 feeWei = SafeMath.div(SafeMath.div(salePriceWei, 100), transactionFeeAs1PctDenom);
    uint256 sellerBalanceWei = SafeMath.sub(salePriceWei, feeWei);
    // Pay contract owner
    owner().transfer(feeWei);
    // Pay seller
    msg.sender.transfer(sellerBalanceWei);
    // Transfer tokens to contract
    bwToken.transferFrom(msg.sender, this, _tokensBWCWei);
    // Burn tokens
    bwToken.burn(_tokensBWCWei);
    // update pool balance
    poolBalance = address(this).balance;
  }

  // Math
  function sqrt(uint x) internal pure returns (uint y) {
    uint z = (x + 1) / 2;
    y = x;
    while (z < y) {
        y = z;
        z = (x / z + z) / 2;
    }
  }

  // Fallback
  function() external payable {}
}
