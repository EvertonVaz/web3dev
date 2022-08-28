require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.4",
  networks: {
    mumbai: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/xhLUItuU6vdbVsvRoCIudgEm8RuprB_y",
      accounts: ["2a1dceb825590ec423fc7bf13dfeeb786eac94bfb340d2e002510df76c129fbd"],
    },
  },
};
