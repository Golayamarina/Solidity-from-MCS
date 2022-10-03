
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { TASK_COMPILE_SOLIDITY_LOG_NOTHING_TO_COMPILE } = require("hardhat/builtin-tasks/task-names");

describe("Paments", function () {

  let acc1
  let acc2
  let payments

  beforeEach(async function() {
    [acc1, acc2] = await ethers.getSigners()
    const Paments = await ethers.getContractFactory("Payments", acc1)
    payments = await Paments.deploy()
    await payments.deployed()
    //console.log(payments.address)
    
  })

  it("shoud be daeployed", async function() {
    expect(payments.address).to.be.properAddress
  })

  it("shoud have 0 ether by default", async function() {
    const balance = await payments.currentBalance()
    expect(balance).to.eq(0)
  })

  it("shoud be possible to send funds", async function() {
    const sum = 100
    const msg = "hello from hh"
    const tx = await payments.pay(msg, { value: sum })
    await expect(() => tx).to.changeEtherBalances([acc1, payments], [-sum, sum])
    await tx.wait()

    const newPayment = await payments.getPayment(acc1.address, 0)
    console.log(newPayment)

    const balance = await payments.currentBalance()
    expect(newPayment.message).to.eq(msg)
    expect(newPayment.amount).to.eq(sum)
    expect(newPayment.from).to.eq(acc1.address)
  })

})
