const HDWalletProvider = require('truffle-hdwallet-provider');
const mnemonic = 'usage vivid hour immense online acoustic ripple iron kingdom lumber alley egg'

module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*' // match any network
    },
    mainnet: {
      provider: function() {
        return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/M2xeaVefzxkLhvrTLq43')
      },
      network_id: '1', // match any network
      gas: 7900000
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(mnemonic, 'https://rinkeby.infura.io/M2xeaVefzxkLhvrTLq43')
      },
      network_id: 4
    }
  }
};

/*
Ganache CLI v6.1.8 (ganache-core: 2.2.1)

Available Accounts
==================
(0) 0xc0c72b068c4ba51f7e01d64a18e63bb922820a63 (~100 ETH)
(1) 0x49be9ef79b6a275da25eb7700651ab2a4b397b10 (~100 ETH)
(2) 0x93bdeab5b717283c997a4e627b17b26e423ac862 (~100 ETH)
(3) 0x385075eb2b100f95672b8b95121d520e19e3e10d (~100 ETH)
(4) 0x99bfd43d452d0c6602bac6c6eb33bc7d3a6ecca7 (~100 ETH)
(5) 0x99eb01fe2f720b02ab780f66b92a64f41001c496 (~100 ETH)
(6) 0xb74bf69856074d081c644106dde706162832c7b9 (~100 ETH)
(7) 0xab654ec2af474278bb22a1d1cd0cdb41ffc599d9 (~100 ETH)
(8) 0x47de6dc26d7b2aad8b71f5e070700e6b80af74a7 (~100 ETH)
(9) 0x40cc3182ccdf07514ac113040814afaedb132e9a (~100 ETH)

Private Keys
==================
(0) 0x70a45fad1a0acaaf6f96ed1cab3ca49daff1853282dd82022ddd2cf0438c8a89
(1) 0x5ac1f10bc55f4715ef45f02605e6a272402099e2df11243b3d8cd1dc338b6b6f
(2) 0xba3bd9a63626596d2e4b31bc1d23efd4d71de48a7d0ef9645df38d2dae53d106
(3) 0x701bcf2eca5c76d8c458d1b5c259c62efc37b440a1db75c81eb9bf8c71f5b374
(4) 0x873074ed53d731c5b696db77fe5cac6d8da172cef1d6f426e0048673f621201b
(5) 0x1e8e14b0355cbcb36d32f78567594c33fd4eabcb9a094e7c81574934f543054a
(6) 0xf966da7efd46231366f05b08c9c70b6a1041d5b45e2b80db0280fca4a75265e8
(7) 0xf50891396ad2a0a6d2726840797aef7d484aec0d49b593249615c6ed96959840
(8) 0xa5aaba5cae950386e2504074ae4d981da58a71b65f3bac1f265fd1462dd2c0a6
(9) 0x6a55ffe2a64d7bfb98c13c352424881934840300097bec50cb6109c091982aea

HD Wallet
==================
Mnemonic:      usage vivid hour immense online acoustic ripple iron kingdom lumber alley egg
Base HD Path:  m/44'/60'/0'/0/{account_index}
*/
