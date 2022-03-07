const Migrations = artifacts.require("MumbaiUltimate");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
