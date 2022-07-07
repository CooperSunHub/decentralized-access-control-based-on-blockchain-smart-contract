const AP = artifacts.require("AP");
const BU = artifacts.require("BU");
const POL = artifacts.require("POL");
const TRS = artifacts.require("TRS");
const SIG = artifacts.require("SIG");

module.exports = function(deployer) {
  deployer.deploy(AP);
  deployer.deploy(BU);
  deployer.deploy(POL);
  deployer.deploy(TRS);
  deployer.deploy(SIG);
};