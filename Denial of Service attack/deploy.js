const hre = require('hardhat');
const ethers = hre.ethers;


async function main() {

    const [deployer, user] = await ethers.getSigners()
    const Auction = await ethers.getContractFactory("Auction", deployer)
    const auction = await Auction.deploy()
    await auction.deployed()

    const Attack = await getContractFactory("Attack", deployer)
    const attack = await Attack.deploy(auction.address)
    await attack.deployed()

    const txBid = await auction.bid({value: ethers.utils.parseEther('5.0')})
    await txBid.wait()

    const txAttackBid = await auction.doBid({value: 50})
    await txAttackBid.wait()

    const txUserBid = await auction.connect(user).bid({value: 200})
    await txUserBid.wait()

    console.log(await ethers.provider.getBalance(auction.address))

    const txRefund = await auction.refund()
    await txRefund.wait()

    console.log(await auction.refundprogress())
    console.log(await ethers.provider.getBalance(deployer.address))

 }

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
