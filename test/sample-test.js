const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Main", function () {
  it("Should deploy", async function () {
    const Main = await ethers.getContractFactory("Adapter");
    const main = await Main.deploy();
    await main.deployed();

    expect(main.total_deposited).to.equal(0);

    const deposit_tx = await main.deposit(10);

    await deposit_tx.wait();

    expect(main.total_deposited).to.equal(10);
  });
});
