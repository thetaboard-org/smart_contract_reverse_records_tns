const ReverseRecords = artifacts.require("ReverseRecords");
const secrets = require('../secrets.json');

module.exports = async function (deployer, network, accounts) {
  const ENSRegistryInstanceAddress = secrets.mainnet.ENSRegistryInstanceAddress;
  
  // deploy ReverseRecords
  await deployer.deploy(ReverseRecords, ENSRegistryInstanceAddress);
  const ReverseRecordsInstance = await ReverseRecords.deployed();
  const ReverseRecordsInstanceAddress = ReverseRecordsInstance.address;
  console.log(ReverseRecordsInstanceAddress)
}
