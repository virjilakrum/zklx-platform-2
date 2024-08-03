import { uploadFileToIPFS } from "./uploadToIPFS";
import SolanaSigner from "./solanaSigner";
import EVMSigner from "./evmSigner";
import * as readline from "readline";
import * as path from "path";
import dotenv from "dotenv"; // .env dosyası için

dotenv.config(); // .env dosyasını yükle

// Kullanıcı girdileri için readline arayüzünü oluştur
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

// Ana işlev
async function main() {
  try {
    // Kullanıcıdan dosya yolunu alın
    const filePath = await askQuestion(
      "Göndermek istediğiniz dosyanın yolunu girin: ",
    );
    const absoluteFilePath = path.resolve(__dirname, "..", "files", filePath);

    // Dosyayı IPFS'e yükleyin
    const fileUrl = await uploadFileToIPFS(absoluteFilePath);
    console.log(`Dosya IPFS'e yüklendi: ${fileUrl}`);

    // Kullanıcıdan alıcı adresini ve blockchain tipini alın
    const recipientAddress = await askQuestion("Alıcının adresini girin: ");
    const blockchainType = await askQuestion(
      "Blockchain tipini seçin (solana, evm): ",
    );

    // İmzalayıcıyı oluştur
    const signer = getSigner(blockchainType);

    // Dosya linkini gönderin
    const transactionHash = await sendFileLink(
      signer,
      fileUrl,
      recipientAddress,
    );
    console.log(`İşlem tamamlandı. İşlem hash'i: ${transactionHash}`);
  } catch (error) {
    console.error("Bir hata oluştu:", error);
  } finally {
    rl.close();
  }
}

// Kullanıcıdan soru soran yardımcı fonksiyon
async function askQuestion(question) {
  return new Promise((resolve) => {
    rl.question(question, resolve);
  });
}

// İmzalayıcı oluşturma fonksiyonu
function getSigner(blockchainType) {
  switch (blockchainType) {
    case "solana":
      const solanaSecretKey = Uint8Array.from(
        process.env.SOLANA_SECRET_KEY.split(",").map((s) => parseInt(s, 10)),
      );
      return new SolanaSigner(solanaSecretKey);
    case "evm":
      const evmPrivateKey = process.env.EVM_PRIVATE_KEY;
      return new EVMSigner(evmPrivateKey);
    default:
      throw new Error("Geçersiz blockchain tipi");
  }
}

main();
