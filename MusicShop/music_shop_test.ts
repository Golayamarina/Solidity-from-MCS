import { expect } from "./chai-setup";
import { ethers, deployments, getNamedAccounts, } from "hardhat";
import type { MusicShop } from "../typechain-types";

describe("MusicShop", function () {
    let deployer: string;
    let user: string;
    let musicShop: MusicShop;
    let musicShopAsUser: MusicShop;

    async function addAlbum() {
        const tx = await musicShop.addAlbum("test.123", "Demo Album", 100, 5);
           await tx.wait();
    }
    beforeEach(async function() {
        await deployments.fixture(["MusicShop"]);

        ({deployer, user} = await getNamedAccounts());
        musicShop = await ethers.getContract<MusicShop>("MusicShop");
        musicShopAsUser = await ethers.getContract<MusicShop>("MusicShop", user);
    
    });

    it("sets owner", async function() {
        console.log(await musicShop.owner());
        expect (await musicShop.owner()).to.eq(deployer);
    });

    describe("addAlbum()", function() {
        it("allowns owner to add album", async function() {
            await addAlbum();

           const newAlbum = await musicShop.albums(0);
           console.log(newAlbum);
           expect(newAlbum.uid).to.eq("test.123");
           expect(newAlbum.title).to.eq("Demo Album");
           expect(newAlbum.price).to.eq(100);
           expect(newAlbum.quantity).to.eq(5);
           expect(newAlbum.index).to.eq(0);

           expect(await musicShop.currentIndex()).to.eq(1);
        });

        it("doesn't allow other users to add albums", async function(){
            //const musicShopAsUser = await ethers.getContract<MusicShop>("MusicShop", user);
                    await expect(musicShopAsUser.addAlbum("test.123", "Demo Album", 100, 5))
              .to.be.revertedWith('not an owner');
        });
    });

    describe("buy()", function() {
    it("allows buy an album", async function () {
        await addAlbum();
        const tx = await musicShopAsUser.buy(0, {value: 100});
        await tx.wait();

        const album = await musicShopAsUser.albums(0);
        expect(album.quantity).to.eq(4);

        const order = await musicShopAsUser.orders(0);
        expect(order.albumUid).to.eq(album.uid);
        expect(order.customer).to.eq(user);
        expect(order.status).to.eq(0);

        const ts = (await ethers.provider.getBlock(<number>tx.blockNumber)).timestamp;
        expect(order.orderedAt).to.eq(ts);


    });
    });
});
