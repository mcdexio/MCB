const {
    ethers,
    network,
    upgrades
} = require("hardhat")
const OZ_SDK_EXPORT = require("../openzeppelin-cli-export.json");


const EnvConfigs = {
    arb: {
        l1Token: "0x4e352cf164e64adcbad318c3a1e222e9eba4ce42",
        l2CustomGateway: "0x096760F208390250649E3e8763348E783AEF5562",
    },
    arbrinkeby: {
        l1Token: "0x01B019DCdfc39C537b1143c79a31B4733bD4C985",
        l2CustomGateway: "0x9b014455AcC2Fe90c52803849d0002aeEC184a06",
    }
}

async function main() {
    const env = EnvConfigs[network.name]

    const ethTotalSupply = '2193176548671886899345095'

    const ArbMCBv2 = await ethers.getContractFactory("ArbMCBv2");
    // const arbMCBv2 = await upgrades.deployProxy(ArbMCBv2);
    // await arbMCBv2.deployed();
    // console.log("ArbMCBv2 deployed to:", arbMCBv2.address);

    const upgraded = await upgrades.upgradeProxy('0xCb0A409271468A77Ed497455f895D47B48022740', ArbMCBv2);
    console.log("ArbMCBv2 upgraded to:", upgraded.address);
}

main().then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });