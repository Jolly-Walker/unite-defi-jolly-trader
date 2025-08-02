const { ethers } = require("ethers");
const { LimitOrderBuilder } = require("@1inch/limit-order-protocol-utils");

async function createOrders() {
  const providerRpc = "https://mainnet.infura.io/v3/YOUR_INFURA_KEY";
  const chainId = 1; // Mainnet
  const provider = new ethers.JsonRpcProvider(providerRpc);

  const ownerPrivateKey = "0x...";
  const wallet = new ethers.Wallet(ownerPrivateKey, provider);

  const makerContract = "0xYourGridMakerOnceContract";
  const makerAsset = "0xYourTokenToSell";
  const takerAsset = "0xYourTokenToBuy";

  const builder = new LimitOrderBuilder(chainId, wallet);

  const gridPrices = [
    ethers.parseUnits("1000", 18),
    ethers.parseUnits("1100", 18),
    ethers.parseUnits("1200", 18),
  ];

  const orders = [];

  for (let i = 0; i < gridPrices.length; i++) {
    const salt = (Date.now() + i).toString();

    const order = builder.buildLimitOrder({
      makerAssetAddress: makerAsset,
      takerAssetAddress: takerAsset,
      makerAddress: makerContract,
      receiver: makerContract,
      allowedSender: ethers.ZeroAddress,
      makingAmount: ethers.parseUnits("1", 18),
      takingAmount: gridPrices[i],
      salt,
      predicate: "0x",
      permit: "0x",
      interaction: ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [salt]),
    });

    const signature = await builder.signOrder(order);

    orders.push({ order, signature });
  }

  console.log(JSON.stringify(orders, null, 2));
  return orders;
}

createOrders();
