const {
    ethers,
    upgrades
} = require("hardhat")

async function main() {
    const MCB = await ethers.getContractFactory("MCB");
    const mcb = await upgrades.deployProxy(MCB, ["TEST", "TEST"]);
    await mcb.deployed();
    console.log("MCB deployed to:", mcb.address);
}

main().then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });