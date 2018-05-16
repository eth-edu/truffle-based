var Migrations = artifacts.require("Migrations");

module.exports = function(deployer) {
  // Truffle dummy migration
  deployer.deploy(Migrations);
};
