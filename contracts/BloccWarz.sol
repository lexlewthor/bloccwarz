pragma solidity 0.4.25;

import { MintAndBurnToken } from "./MintAndBurnToken.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract BloccWarz is Ownable {
  using SafeMath for uint32;
  using SafeMath for uint64;
  using SafeMath for uint256;

  // Contract variables
  MintAndBurnToken public bwCash;
  uint32 public periodLength; // time length of each period in seconds
  uint64 public currentPeriod = 0;
  mapping(address => Player) public players;
  mapping(address => mapping(address => Battle)) public battles; // attacker -> defender -> battle

  // Data structures
  struct Player {
    address account; // used for id, eth and bwc balances
    uint64 periodSpawned; // the period in which the player joined the game
    uint64 periodLastPlayedd; // the last period in which the player has interacted
    uint32 periodsPlayed; // the total count of periods a player has interacted
    mapping(uint64 => bool) periodHasPlayed; // track if the user has played in a given period
    // Resources
    uint64 food;
    uint64 medicine;
    uint64 ore;
    uint64 population;
    // Battles
    uint32 battlesTotal;
    uint32 battlesWon;
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
    uint64 food,
    uint64 medicine,
    uint64 ore,
    uint64 population
  );

  event BattleStart(
    uint64 period,
    address attacker,
    address defender
  );

  event BattleEnd(
    uint64 period,
    address attacker,
    address defender,
    address winner
  );

  constructor (uint32 _periodLength, uint256 _bwCashSupply) public {
    periodLength = _periodLength;
    bwCash = new MintAndBurnToken('BloccWarzCash', 18, 'BLCCWZC');
    bwCash.mint(this, _bwCashSupply);
  }

  function joinGame() public payable {

  }
}
