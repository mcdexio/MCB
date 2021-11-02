const { ethers } = require("hardhat");
import { expect, use } from "chai";
import { toWei, fromWei, toBytes32, getAccounts, createContract, createFactory } from "../scripts/utils";

describe("EthMCBv2", () => {
  let accounts;
  let user0;
  let user1;
  let user2;
  let user3;

  let mcb;

  before(async () => {
    accounts = await getAccounts();
    user0 = accounts[0];
    user1 = accounts[1];
    user2 = accounts[2];
    user3 = accounts[3];
  });

  beforeEach(async () => {
    mcb = await createContract("EthMCBv2")
    await mcb.initialize("MCB", "MCB")
  });

  it("mint", async () => {
    await mcb.mint(user1.address, toWei("1"));
    expect(await mcb.balanceOf(user1.address)).to.equal(toWei("1"))
    await mcb.mint(user1.address, toWei("99"));
    expect(await mcb.balanceOf(user1.address)).to.equal(toWei("100"))
    await expect(mcb.connect(user1).mint(user1.address, toWei("1"))).to.be.revertedWith("must have minter role to mint")
    await expect(mcb.mint(user1.address, toWei("9999900.1"))).to.be.revertedWith("max supply exceeded")
  });
});


