// wormhole-file-transfer/src/utils.ts

import { TokenId, ChainAddress } from "@wormhole-foundation/sdk";

// Adresi evrensel formata dönüştürme
export function toUniversalAddress(
  chain: string,
  address: string,
): ChainAddress {
  return {
    chain,
    address,
  };
}

// Token kimliğini oluşturma
export function createTokenId(chainId: number, address: string): TokenId {
  return { chainId, address };
}
