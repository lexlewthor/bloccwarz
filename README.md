# BloccWarz
Turn-based strategy game on the Ethereum blockchain
## Setup and run test
```
$ npm i
$ npm run ganache &
$ npm test
```
## Deploy
1. Modify params in `migrations/2_deploy_contract.js`
2. Run truffle migrate using npm script

       $ npm run migrate

## Notes

### Token purchase/sale
- Using linear bonding curve to mint/burn BW tokens `f(x) = 0.001x`
  - Some research https://blog.relevant.community/how-to-make-bonding-curves-for-continuous-token-models-3784653f8b17
  - Used https://www.integral-calculator.com/ to play with some different curves
  - Using google to search for different implementations in Solidity, probably Bancor best example
- Owner of contract charges fixed % of wei value on mint/burn transactions

### Game resources
- Players will be created and allocated initial game resources on token deposit (full list of resources and balancing functions TBD)
  - food
  - medicine
  - ore
  - population
  - army

### Game actions
- Tokens will be spent on game actions
- Tokens will be offered as a wager during battles
- Tokens spent will be stored in the contract, with an ownerOnly function to withdraw
  - TBD, could leave tokens frozen in contract, or only allow withdraw above a minimum amount frozen
- Players can call a fixed set of functions (game actions) once each period, each with associated resource cost/reward (full list of actions and cost/rewards TBD)
  - Harvest
    - collect more resources based on number of periods played and elapsed periods since last played
  - Repair
    - spend a moderate amount of resources to increase other resources
  - Build
    - spend a larger amount of resources to increase other resources
  - Trade
    - take a buy/sell order for resources in the contract market place
  - Order
    - place/cancel a buy/sell order for resources in the contract market place
  - Attack (initiates battle, see below)
  - Defend (offers a defensive bonus in battles, see below)

### Battles
- Attack initiates a battle and can only be called as the first action during a period, disallowing further actions during the period.
- Defend gives a player a defensive boost for any battles they participate in during the period, also disallowing any further actions during the period.
- Battles will consist of a wagered amount of BW tokens from each party (attacker and defender)
  - Battle outcome will be based on mutually agreed upon random number generation
  - Formula for determining outcome will give a weighted advantage to one party based on
    - resource totals
    - number of periods played
    - periods elapsed since last period played
    - defensive boost
    - size of wager
  - TODO maths for above formula
  - TODO alorithm for shared prng

### Market place
- TODO