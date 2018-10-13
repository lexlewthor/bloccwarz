pragma solidity 0.4.25;
import { MintAndBurnToken } from "./MintAndBurnToken.sol";
import "./BytesLib.sol";
import "./OZ_Ownable.sol";
import "./SafeMath.sol";

contract BloccWarz is Ownable {
  using BytesLib for bytes;
  using SafeMath for uint256;

  // Variables
  uint256 public periodLength; // time length of each period in seconds
  MintAndBurnToken public bwCash;
  uint256 public currentPeriod = 0;

  // Data structures
  // struct Staker {
  //     uint256 spankStaked // the amount of spank staked
  //     uint256 startingPeriod // the period this staker started staking
  //     uint256 endingPeriod // the period after which this stake expires
  //     mapping(uint256 => uint256) spankPoints // the spankPoints per period
  //     mapping(uint256 => bool) didClaimBooty // true if staker claimed BOOTY for that period
  //     mapping(uint256 => bool) votedToClose // true if staker voted to close for that period
  //     address delegateKey // address used to call checkIn and claimBooty
  //     address bootyBase // destination address to receive BOOTY
  // }

  // Events
  // event SpankBankCreated(
  //     uint256 periodLength,
  //     uint256 maxPeriods,
  //     address spankAddress,
  //     uint256 initialBootySupply,
  //     string bootyTokenName,
  //     uint8 bootyDecimalUnits,
  //     string bootySymbol
  // )

  // Mappings
  // mapping(address => Staker) public stakers

  constructor (uint256 _periodLength, uint256 _bwCashSupply) public {
    periodLength = _periodLength;
    bwCash = new MintAndBurnToken('BloccWarzCash', 18, 'BWC');
    bwCash.mint(this, _bwCashSupply);
  }
}
