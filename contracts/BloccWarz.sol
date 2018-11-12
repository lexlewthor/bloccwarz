pragma solidity 0.4.25;

import { MintAndBurnToken } from "./MintAndBurnToken.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract BloccWarz is Ownable {
  using SafeMath for uint256;

  // Contract variables
  MintAndBurnToken public bwCash;
  uint256 public periodLength; // time length of each period in seconds
  uint256 public currentPeriod = 0;
  uint256 public feeToJoinWei = 5000000000000000; // one time fee to join game
  mapping(address => Player) public players;
  mapping(address => mapping(address => Battle)) public battles; // attacker -> defender -> battle
  mapping(uint256 => Period) public periods;

  // Data structures
  struct Period {
    // uint256 playersSpawned;
    // uint256 playersInteracted;
    // uint256 battlesStarted;
    uint256 startTime; // the starting unix timestamp in seconds
    uint256 endTime; // the ending unix timestamp in seconds
  }

  struct Player {
    address account; // used for id, eth and bwc balances
    uint256 periodSpawned; // the period in which the player joined the game
    uint256 periodLastPlayedd; // the last period in which the player has interacted
    uint256 periodsPlayed; // the total count of periods a player has interacted
    mapping(uint256 => bool) periodHasPlayed; // track if the user has played in a given period
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
    bool isEnded;
    address attacker;
    address defender;
    // Score //TODO
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

  constructor (uint256 _periodLength, uint256 _bwCashSupply) public {
    periodLength = _periodLength;
    bwCash = new MintAndBurnToken('BloccWarzCash', 18, 'BLCCWZC');
    bwCash.mint(this, _bwCashSupply);
  }

  function updatePeriod() public {
    while (now >= periods[currentPeriod].endTime) {
      Period memory prevPeriod = periods[currentPeriod];
      currentPeriod += 1;
      periods[currentPeriod].startTime = prevPeriod.endTime;
      periods[currentPeriod].endTime = SafeMath.add(prevPeriod.endTime, periodLength);
    }
  }

  function joinGame() public payable {
    updatePeriod();
    require(msg.value >= feeToJoinWei);

  }
}
