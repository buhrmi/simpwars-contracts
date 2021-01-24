require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/ba97076f633b4ce9ade707bedda6d1c8",
      accounts: ['0xd5a4dd7e92312af34ecfd5907ce47acad230b84ff59fefa23410e159c4f720fb']
            // 0x841673b7b8c7cbe0dacd1fbb6e24c7b026a9eafa
    }
  },
  etherscan: {
    apiKey: "RMF3SAIPU2H2GDNNCHX612RIJ7M1CK7WMF",
  },
  solidity: "0.7.3",
};
