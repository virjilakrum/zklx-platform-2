import Arweave from "arweave";
import { readFileSync } from "fs";
import { JWKInterface } from "arweave/node/lib/wallet";

// Arweave yapılandırması (ortam değişkenlerinden veya bir konfigürasyon dosyasından alınabilir)
const ARWEAVE_HOST = process.env.ARWEAVE_HOST || "arweave.net";
const ARWEAVE_PORT = parseInt(process.env.ARWEAVE_PORT || "443");
const ARWEAVE_PROTOCOL = process.env.ARWEAVE_PROTOCOL || "https";

// Arweave bağlantısı
const arweave = Arweave.init({
  host: ARWEAVE_HOST,
  port: ARWEAVE_PORT,
  protocol: ARWEAVE_PROTOCOL,
});

// Dosya yükleme fonksiyonu
export async function uploadFile(
  filePath: string,
  wallet?: JWKInterface,
): Promise<string> {
  const data = readFileSync(filePath);

  const transaction = await arweave.createTransaction({ data });

  // Eğer cüzdan bilgisi verilmişse, işlemi imzala
  if (wallet) {
    await arweave.transactions.sign(transaction, wallet);
  }

  // İşlemi Arweave ağına gönder
  const response = await arweave.transactions.post(transaction);

  // İşlemin başarılı olduğundan emin ol
  if (response.status !== 200) {
    throw new Error(`Dosya yüklenemedi. Arweave hata kodu: ${response.status}`);
  }

  return transaction.id;
}

// Dosya indirme fonksiyonu
export async function getFile(transactionId: string): Promise<Uint8Array> {
  const transaction = await arweave.transactions.get(transactionId);

  // İşlemin doğrulanmış olduğundan emin ol
  if (!transaction.confirmed) {
    throw new Error("İşlem henüz doğrulanmadı.");
  }

  return transaction.get("data", { decode: true, string: false }); // Binary veri olarak al
}
