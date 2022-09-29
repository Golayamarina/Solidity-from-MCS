const hre = require('hardhat');
const ethers = hre.ethers

async function main() {
    const [deployer, user, hacker] =  await ethers.getSigners()
    const AuctionRe = await ethers.getContractFactory("AuctionRe", deployer)
    const auction = await AuctionRe.deploy()
    await auction.deployed()

    const AttackRe = await ethers.getContractFactory("AttackRe", deployer)
    const attack = await AttackRe.deploy(auction.address)
    await attack.deployed()

    const txBid = await auction.bid({value: ethers.utils.parseEther("4.0")})
    await txBid.wait()

    const txBid2 = await auction.connect(user).bid({value: ethers.utils.parseEther("8.0")})
    await txBid2.wait()

    const txBid3 = await attack.connect(hacker).doBid({value: ethers.utils.parseEther("3.0")})
    await txBid3.wait()

    console.log(await ethers.provider.getBalance(auction.address))
    console.log("STARTING ATTACK!")

    const doAttack = await attack.connect(hacker).attack()
    await doAttack.wait()

    console.log(await ethers.provider.getBalance(auction.address))
    console.log(await ethers.provider.getBalance(hacker.address))
    console.log(await ethers.provider.getBalance(user.address))
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
