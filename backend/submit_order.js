const { ethers } = require("ethers");
const { LimitOrderProtocolFacade } = require("@1inch/limit-order-protocol-utils");

async function fillOrder(order, signature) {
  const providerRpc = "https://mainnet.infura.io/v3/YOUR_INFURA_KEY";
  const chainId = 1; // Mainnet
  const provider = new ethers.JsonRpcProvider(providerRpc);

  const takerPrivateKey = "0x...";
  const takerWallet = new ethers.Wallet(takerPrivateKey, provider);

  const facade = new LimitOrderProtocolFacade(chainId, takerWallet);

  const tx = await facade.fillContractOrder(order, signature, {});
  console.log("Tx hash:", tx.hash);
  await tx.wait();
  console.log("Order filled!");
}

// Example usage:
// const orders = require("./orders.json");
// fillOrder(orders[0].order, orders[0].signature);
