const { ethers, upgrades } = require("hardhat")
const OZ_SDK_EXPORT = require("../openzeppelin-cli-export.json");


async function main() {
    const [ MCB ] = OZ_SDK_EXPORT.networks.mainnet.proxies["mcb/MCB"]
    const EthMCBv2 = await ethers.getContractFactory("EthMCBv2");
    await upgrades.prepareUpgrade(MCB.address, EthMCBv2)
    console.log("all checks done")
}

main().then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });