const {
    ethers,
    upgrades
} = require("hardhat")

async function main() {
    const EthMCBv2 = await ethers.getContractFactory("EthMCBv2");
    await upgrades.upgradeProxy('0x4e352cf164e64adcbad318c3a1e222e9eba4ce42', EthMCBv2)
    console.log("all checks done")
}

main().then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
