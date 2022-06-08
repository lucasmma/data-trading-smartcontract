const DataTradingCircle = artifacts.require("DataTradingCircle");

module.exports = function (deployer) {
  deployer.deploy(DataTradingCircle, "DataTradingCircle", "DTC", "0x7E0c9D4DF4dE7e0C09dDa8421970d91D18aBA6c2");
};
