# BloccWarz
Turn-based strategy game on the Ethereum blockchain

## Setup and run tests
```
$ npm i
$ npm run ganache &
$ npm test
```
## Deploy
1. Modify params in `migrations/2_deploy_contract.js`
2. Run truffle migrate using npm script

       $ npm run migrate

## Road map

### Phase 0
- Core game mechanics
- Webapp launched on Firebase
- Testnet Wyre / Moonpay integration
- Testnet Abriged integration

### Phase 1
- In-game resource marketplace
- Mainnet launch

### Phase 2
- Uniswap integration
- NFT collectibles, buffs
- Lightning/other state channel support

## Game design (WIP)

Set in a future world where communities as small as city blocks have been able to decentralize and form
micro-governments facilitated by the collapse of central banks due to mass adoption of cryptocurrency technology.  The working title "BloccWarz" is a play on blockchain, city blocks, but also the communist states of the Cold War era, called "Blocs."

Free to play, turn-based strategy, resource management, harvesting, crafting, and p2p marketplace.
Ability to form alliances with other players and compete via a balanced battle system that awards/penalizes in-game resources based on random weighted outcome. Alliance mechanism should also be balanced to incentivize decentralization and avoid griefing.  Pay to play features limited to minor buffs, NFTs, with grinding and longevity being incentivized. Monetization should occur through crypto on-boarding fees, transactions with layer 1 game contract (TBD), and microtransaction fees from layer 2 transactions. Players main incentive is to grow their account resources which equate to crypto assets with real-world value that can be transfered out of the game at any time.

### On-boarding
- Firebase social auth (github/twitter/facebook) + Abriged
- Use Wyre/Moonpay widget to facilitate crypto purchase
- Game is free to play
- Consider a bonus for onboarding with crypto

### BloccWarz smart contract
- The BW contract is the "central bank" for in-game resources
- This could include game resources / assets (NFTs)
- The contract should accept DAI and issue in-game resources
- Use various bonding curves for pegging resources to DAI
- Could this be eliminated entirely through layer 2 synthetic assets?

### Layer 2 transactions
- Various in-game assets will be transfered between players as a result of battles etc
- In-game marketplace between players could be facilitated by Abriged synthetic assets

### Game actions
- Players can call a set of game actions each period based on energy or similar resource
  - Harvest
    - Collect more resources based on number of periods played and elapsed periods since last played
  - GrowPopulation
    - Resource sink
    - Example `food + medicine = population`, with modifiers and bonuses
  - RecruitArmy
    - Resource sink
    - Example `food + ore + population = army`, with modifiers and bonuses
  - Attack initiates battle (see below)
  - Defend offers a defensive bonus in battles (see below)
- Marketplace actions (see below)
  - Place market orders/limit orders
  - Trading pairs between all in-game assets/currency
  - Resource scarcity and pegged values could be enforced via layer 1 contract

### Battles
- Attack initiates a battle and can only be called once per period, disallowing further actions during the period.
- Defend gives a player a defensive boost for any battles they participate in during the period, also disallowing any further actions during the period.
- A player can respond to any number of attacks within a period
- Battles will consist of a wagered amount of resources from each party (attacker and defender)
  - Attacker calls Attack as their single period action
  - Defender can respond to the attack at any point, regardless of period action
  - Formula for determining outcome will give a weighted advantage to one party based on
    - alliance strength
    - resource totals
    - number of periods played
    - periods elapsed since last period played
    - defensive boost
    - size of wager
  - TODO all the maths

### Marketplace
- TBD how this should be implemented across layers 1 and 2

### Game Resources
- Players will be created and allocated initial game resources after on-boarding
  - food
  - medicine
  - ore
  - population
  - army (can be broken down into multiple unit types)
- Players can harvest an amount of specific base resources per period
- Other resources can be crafted with base resources
- Resources can be purchased / traded for on marketplace

### v0 BloccWarz contract token purchases/sales
- ERC-20 mint/burn token implemented on a bonding curve as a proof of concept
- Using linear bonding curve to mint/burn BW tokens `f(x) = 0.0001x`
- Contract charges fixed 0.25% of wei value on mint/burn transactions to create spread
- Minimum token transaction amount in wei (lot size) enforced in contract on buy/sell sides
  - Ensures at least x wei in fees
- Fees collected are locked in contract and withdrawable by owner
- There could be a lock up threshold on the liquidity pool which ensures profit for early adopters
- Much of the existing data structures will be removed as game logic becomes centralized and crypto transactions are facilitated by layer 2

## References
- Game design inspired by <http://teq3.playteq.com>
- Abriged SDK <https://github.com/netgum/archanova>
- Bonding curve research <https://blog.relevant.community/how-to-make-bonding-curves-for-continuous-token-models-3784653f8b17>
- Used <https://www.integral-calculator.com/> to play with some different bonding curves
- Solidity project reference from work at SpankChain <https://github.com/SpankChain/spankbank>
- Solidity project reference from work at SpankChain <https://github.com/ConnextProject/contracts>


