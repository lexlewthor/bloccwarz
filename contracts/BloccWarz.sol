pragma solidity 0.4.25;

import { MintAndBurnToken } from "./MintAndBurnToken.sol";
import "./OZ_Ownable.sol";
import "./SafeMath.sol";

contract BloccWarz is Ownable {
  using SafeMath for uint32;
  using SafeMath for uint64;
  using SafeMath for uint256;

  // Contract variables
  MintAndBurnToken public bwCash;
  uint32 public periodLength; // time length of each period in seconds
  uint256 public currentPeriod = 0;
  mapping(address => Player) public players;

  // Data structures
  struct Player {
    address account; // used for eth, bwc balances
    uint256 periodSpawned; // the period in which the player joined the game
    // Resources
    uint64 food;
    uint64 medicine;
    uint64 ore;
    uint64 population;
    // Battles
    mapping(address => Battle) battles; // look up by opponent address
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
  );

  constructor (uint32 _periodLength, uint256 _bwCashSupply) public {
    periodLength = _periodLength;
    bwCash = new MintAndBurnToken('BloccWarzCash', 18, 'BWC');
    bwCash.mint(this, _bwCashSupply);
  }
}
