const fs = require("fs");
const path = require("path");
const some = require("lodash/some");

const FiatTokenV2_1 = artifacts.require("FiatTokenV2_1");
const FiatTokenProxy = artifacts.require("FiatTokenProxy");
const SignatureChecker = artifacts.require("SignatureChecker");

const THROWAWAY_ADDRESS = "0x0000000000000000000000000000000000000001";

let proxyContractAddress = "";

// Read config file if it exists
if (fs.existsSync(path.join(__dirname, "..", "config.js"))) {
  ({ PROXY_CONTRACT_ADDRESS: proxyContractAddress } = require("../config.js"));
}

module.exports = async (deployer, network) => {
  if (
    !proxyContractAddress ||
    some(["development", "coverage"], (v) => network.includes(v))
  ) {
    proxyContractAddress = (await FiatTokenProxy.deployed()).address;
  }

  console.log(`FiatTokenProxy: ${proxyContractAddress}`);

  console.log("Deploying and linking SignatureChecker library contract...");
  await deployer.deploy(SignatureChecker);
  await deployer.link(SignatureChecker, FiatTokenV2_1);

  console.log("Deploying FiatTokenV2_1 implementation contract...");
  await deployer.deploy(FiatTokenV2_1);

  const fiatTokenV2_1 = await FiatTokenV2_1.deployed();
  console.log("Deployed FiatTokenV2_1 at", fiatTokenV2_1.address);

  // Initializing the implementation contract with dummy values here prevents
  // the contract from being reinitialized later on with different values.
  // Dummy values can be used here as the proxy contract will store the actual values
  // for the deployed token.
  console.log(
    "Initializing FiatTokenV2_1 implementation contract with dummy values..."
  );
  await fiatTokenV2_1.initialize(
    "",
    "",
    "",
    0,
    THROWAWAY_ADDRESS,
    THROWAWAY_ADDRESS,
    THROWAWAY_ADDRESS,
    THROWAWAY_ADDRESS
  );
  await fiatTokenV2_1.initializeV2("");
  await fiatTokenV2_1.initializeV2_1(THROWAWAY_ADDRESS);
};
