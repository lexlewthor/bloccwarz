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
- I've had this idea since ETHBuenosAires to build this game in a smart contract http://teq3.playteq.com/
- I'm thinking maybe it could be done using MintAndBurnTokens for the resources and a weighted lottery system for battles
- Gameplay is turned based using a period system similar to SpankBank
- Each period resources are generated/consumed for each player
- Any player can initiate a battle between another player given some constraints
- The outcome of each battle burns / transfers certain resources
- I've been looking at something like this for battles https://medium.com/@promentol/lottery-smart-contract-can-we-generate-random-numbers-in-solidity-4f586a152b27

No idea if it will work, but I want to give it a go once things settle down at work :)
