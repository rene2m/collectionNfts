const Ultimate = artifacts.require("BohemianUltimateTest");

module.exports = function (deployer) {
  deployer.deploy(Ultimate);
};
