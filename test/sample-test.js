const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTM arket", function () {
  it("Should create and execute market sales", async function () {
    const Market = await ethers.getContractFactory("NFTMarket");
    const market = await Market.deploy();
    await market.deployed(); //deploy the NFTMarket contract
    const marketAddress = market.address; //give us the contract address


    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy();
    await nft.deployed(); //deploy the NFT contract
    const nftContractAddress = nft.address; //give us the nft address

    let listingPrice = await market.getListingPrice();
    listingPrice = listingPrice.toString();

    //set up auction price
    const auctionPrice = ethers.utils.parseUnits("100", "ether");

    //create 2 test tokens
    await nft.createToken("https:www.mytokenlocation.com");
    await nft.createToken("https:www.mytokenlocation2.com");

    //create 2 test nfts
    await market.createMarketItem(nftContractAddress, 1, auctionPrice, {value: listingPrice});

    await market.createMarketItem(nftContractAddress, 2, auctionPrice, {value: listingPrice});

    const [_, buyerAddress] = await ethers.getSigners(); 
    
    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, {value: auctionPrice});

    //fetch market items
    const items = await market.fetchMarketItems();

    console.log('items:', items);
    




  });
});
