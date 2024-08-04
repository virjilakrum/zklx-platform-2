// wormhole-file-transfer/src/config.ts

import dotenv from "dotenv";

dotenv.config();

export const config = {
  network: process.env.NETWORK || "Testnet",
  solana: {
    rpc: "https://api.testnet.solana.com",
    chainId: 1,
    tokenBridge: process.env.SOLANA_TOKEN_BRIDGE,
  },
  evm: {
    rpc: "https://rpc.testnet.ethereum.org",
    chainId: 2,
    tokenBridge: process.env.EVM_TOKEN_BRIDGE,
  },
};
