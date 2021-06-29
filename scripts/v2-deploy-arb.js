const {
    ethers,
    network,
    upgrades
} = require("hardhat")

async function main() {
    const ArbMCBv2 = await ethers.getContractFactory("ArbMCBv2");
    // const arbMCBv2 = await upgrades.deployProxy(ArbMCBv2);
    // await arbMCBv2.deployed();
    // console.log("ArbMCBv2 deployed to:", arbMCBv2.address);

    const upgraded = await upgrades.upgradeProxy('0x4e352cf164e64adcbad318c3a1e222e9eba4ce42', ArbMCBv2);
    console.log("ArbMCBv2 upgraded to:", upgraded.address);
}

main().then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
