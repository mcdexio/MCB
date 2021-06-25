const {
    ethers,
    network,
    upgrades
} = require("hardhat")
const OZ_SDK_EXPORT = require("../openzeppelin-cli-export.json");


const EnvConfigs = {
    mainnet: {
        l1Token: OZ_SDK_EXPORT.OZ_SDK_EXPORT.networks.mainnet.proxies["mcb/MCB"],
        // l2CustomGateway: ""
    },
    arb: {

    },
    arbrinkeby: {
        l1Token: "0x01B019DCdfc39C537b1143c79a31B4733bD4C985",
        l2CustomGateway: "0x9b014455AcC2Fe90c52803849d0002aeEC184a06",
    }
}

async function main() {
    const env = EnvConfigs[network.name]

    const ethMCBv2 = await ethers.getContractAt("IERC20", env.l1Token)
    const ethTotalSupply = await ethMCBv2.totalSupply()

    const ArbMCBv2 = await ethers.getContractFactory("ArbMCBv2");
    const arbMCBv2 = await upgrades.deployProxy(ArbMCBv2, [
        "MCB", // name
        "MCB", // symbol
        env.l2CustomGateway, // l2 gateway
        env.l1Token, // l1 counterparty
        ethTotalSupply // l1 totalSupply
    ]);
    await arbMCBv2.deployed();
    console.log("ArbMCBv2 deployed to:", arbMCBv2.address);
}

main().then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });