var LandTitle = artifacts.require("LandTitleRegistry");
module.exports = function(deployer) {
    deployer.deploy(LandTitle);
};