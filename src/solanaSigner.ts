// wormhole-file-transfer/src/solanaSigner.ts

import {
  Keypair,
  Transaction,
  PublicKey,
  TransactionInstruction,
} from "@solana/web3.js";
import { Signer } from "@wormhole-foundation/sdk";

class SolanaSigner implements Signer {
  private keypair: Keypair;

  constructor(secretKey: Uint8Array) {
    this.keypair = Keypair.fromSecretKey(secretKey);
  }

  async sign(data: Uint8Array): Promise<Uint8Array> {
    // Create a transaction with the fee payer as the signer
    const transaction = new Transaction({ feePayer: this.keypair.publicKey });

    // Add a custom instruction (replace with your actual instruction)
    const instruction = new TransactionInstruction({
      keys: [], // Add necessary accounts here
      programId: new PublicKey("your_program_id"), // Replace with your program ID
      data,
    });
    transaction.add(instruction);

    // Sign the transaction
    transaction.sign(this.keypair);

    // Return the serialized signed transaction
    return transaction.serialize();
  }

  getPublicKey(): Uint8Array {
    return this.keypair.publicKey.toBytes();
  }

  getPublicKeyString(): string {
    return this.keypair.publicKey.toBase58();
  }
}

export default SolanaSigner;
