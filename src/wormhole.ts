import {
  wormhole,
  ChainContext,
  WormholeError,
} from "@wormhole-foundation/sdk";
import { getConfig } from "./config";
import { WormholeSigner } from "./types";

// Özel hata türleri
class InvalidChainError extends Error {}
class InvalidPayloadError extends Error {}

export async function createWormholeContext(): Promise<ChainContext[]> {
  const config = getConfig();
  try {
    return wormhole(config.network, [config.evm, config.solana]);
  } catch (error) {
    console.error("Wormhole context oluşturma hatası:", error);
    throw error;
  }
}

export async function sendMessage(
  signer: WormholeSigner,
  payload: Uint8Array,
  recipientChain: string,
  nonce: number,
): Promise<string[]> {
  try {
    const wh = await createWormholeContext();
    const chain = wh.find((c) => c.chain === signer.chain());
    if (!chain) throw new InvalidChainError("Geçersiz zincir");

    if (payload.length > 1024) {
      throw new InvalidPayloadError("Payload çok büyük");
    }

    const coreBridge = await chain.getWormholeCore();
    const txs = coreBridge.publishMessage(signer.address(), payload, nonce, 0);
    const result = await chain.signSendWait(txs, signer);
    return result.map((res) => res.txHash);
  } catch (error) {
    console.error("Mesaj gönderme hatası:", error);
    throw new Error("Mesaj gönderme hatası: " + error.message);
  }
}

export function showProgress(progress: number) {
  console.log(`İşlem tamamlandı: ${progress}%`);
}

export function generateNonce(): number {
  return Date.now();
}

export function validatePrivateKey(privateKey: string): boolean {
  return privateKey.length === 64;
}

export function notifyUser(message: string) {
  console.log(`Bildirim: ${message}`);
}
