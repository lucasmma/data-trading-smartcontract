const DataTradingCircle = artifacts.require("DataTradingCircle");

module.exports = function (deployer) {
  deployer.deploy(DataTradingCircle, "DataTradingCircle", "DTC", "0x989638f0D879Be8b132Cde8E2058F11187Bcd7De");
};
