// wormhole-file-transfer/src/types.ts

import { Signer } from "@wormhole-foundation/sdk";

export interface WormholeSigner extends Signer {
  chainId: () => number;
  address: () => string;
}
