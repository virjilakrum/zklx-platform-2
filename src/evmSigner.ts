// wormhole-file-transfer/src/evmSigner.ts

import { ethers } from "ethers";
import { Signer } from "@wormhole-foundation/sdk";

class EVMSigner implements Signer {
  private wallet: ethers.Wallet;

  constructor(privateKey: string) {
    this.wallet = new ethers.Wallet(privateKey);
  }

  async sign(data: Uint8Array): Promise<Uint8Array> {
    try {
      const signature = await this.wallet.signMessage(data);
      return ethers.utils.arrayify(signature);
    } catch (error) {
      console.error("Error signing data:", error);
      throw error; // Re-throw the error to propagate it to the caller
    }
  }

  getPublicKey(): Uint8Array {
    return ethers.utils.arrayify(this.wallet.publicKey);
  }

  getAddress(): string {
    return this.wallet.address;
  }
}

export default EVMSigner;
