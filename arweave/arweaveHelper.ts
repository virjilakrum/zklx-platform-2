// wormhole-scaffolding-main/arweave/arweaveHelper.ts
import Arweave from "arweave";
import { readFileSync } from "fs";

const arweave = Arweave.init({
  host: "arweave.net",
  port: 443,
  protocol: "https",
});

export async function uploadFile(filePath: string): Promise<string> {
  const data = readFileSync(filePath); // local reading
  const transaction = await arweave.createTransaction({ data });
  await arweave.transactions.sign(transaction);
  await arweave.transactions.post(transaction);
  return transaction.id;
}

export async function getFile(transactionId: string): Promise<string> {
  const transactionData = await arweave.transactions.getData(transactionId, {
    decode: true,
    string: true,
  });
  return transactionData;
}
