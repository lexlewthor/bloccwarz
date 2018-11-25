# BloccWarz
Turn-based strategy game on the Ethereum blockchain
## Setup and Run Tests
```
$ npm i
$ npm run ganache &
$ npm test
```
## Deploy
1. Modify params in `migrations/2_deploy_contract.js`
2. Run truffle migrate using npm script

       $ npm run migrate

## Game Design (WIP)

### Token Purchases/Sales
- Using linear bonding curve to mint/burn BW tokens `f(x) = 0.001x`
  - Some research here https://blog.relevant.community/how-to-make-bonding-curves-for-continuous-token-models-3784653f8b17
  - Used https://www.integral-calculator.com/ to play with some different curves
- Contract charges fixed 0.25% of wei value on mint/burn transactions to create spread
- Minimum token transaction amount in wei (lot size) enforced in contract on buy/sell sides
  - Ensures at least 1 wei in fees

### Game Resources
- Players will be created and allocated initial game resources on token deposit (full list of resources and balancing functions TBD)
  - food
  - medicine
  - ore
  - population
  - army

### Game Actions Using BloccWarzCash Tokens
- Tokens will be spent on certain game actions, not all
- Tokens will be offered as a wager during battles, held in escrow and distributed at end of battle
- Tokens spent will be stored in the contract, with an ownerOnly function to withdraw
  - TBD, could leave tokens frozen in contract, or only allow withdraw above a minimum amount frozen
- Players can call a single game action once each period, each with associated resource cost/reward (full list of actions and cost/rewards TBD)
  - Harvest
    - collect more resources based on number of periods played and elapsed periods since last played
  - Repair
    - spend a moderate amount of resources to increase other resources
  - Build
    - spend a larger amount of resources to increase other resources
  - Trade
    - take a buy/sell order for resources in the contract marketplace
    - TBD allow this multiple times per period?
  - Order
    - place/cancel a buy/sell order for resources in the contract marketplace
    - TBD allow this multiple times per period?
  - Attack (initiates battle, see below)
  - Defend (offers a defensive bonus in battles, see below)

### Battles
- Attack initiates a battle and can only be called once per period, disallowing further actions during the period.
- Defend gives a player a defensive boost for any battles they participate in during the period, also disallowing any further actions during the period.
- A player can respond to any number of attacks within a period
- Battles will consist of a wagered amount of BW tokens from each party (attacker and defender)
  - Attacker calls Attack as their single period action
  - Defender can respond to the attack at any point, regardless of period action
  - Battle outcome will be based on mutually agreed upon random number generation
  - Formula for determining outcome will give a weighted advantage to one party based on
    - resource totals
    - number of periods played
    - periods elapsed since last period played
    - defensive boost
    - size of wager
  - TODO maths for above formula
  - TODO alorithm for shared prng

### Marketplace
- Players can build an in-contract marketplace for game resources


## Sources
- https://github.com/SpankChain/spankbank
- https://github.com/ConnextProject/contracts
