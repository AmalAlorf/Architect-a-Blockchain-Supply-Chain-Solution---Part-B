// migrating the appropriate contracts
var SellerRole = artifacts.require("./SellerRole.sol");
var DeliveryAgentRole = artifacts.require("./DeliveryAgentRole.sol");
var ConsumerRole = artifacts.require("./ConsumerRole.sol");
var SupplyChain = artifacts.require("./SupplyChain.sol");

module.exports = function(deployer) {
    deployer.deploy(SellerRole);
    deployer.deploy(DeliveryAgentRole);
    deployer.deploy(ConsumerRole);
    deployer.deploy(SupplyChain);
};