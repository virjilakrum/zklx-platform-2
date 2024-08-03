import { create } from "ipfs-http-client";
import * as fs from "fs/promises";
import * as path from "path";

const ipfs = create({
  host: "ipfs.infura.io",
  port: 5001,
  protocol: "https",
});

export async function uploadFileToIPFS(filePath: string): Promise<string> {
  try {
    // Resolve the complete file path (optional, depending on your usage)
    const fullPath = path.resolve(filePath);

    // Read the file content
    const fileContent = await fs.readFile(fullPath);

    // Upload the file to IPFS
    const result = await ipfs.add(fileContent);

    // Create the file URL
    const fileUrl = `https://ipfs.infura.io/ipfs/${result.path}`;

    // Control Point Allowed Extensions
    const allowedExtensions = [".txt", ".jpg", ".png"];
    const ext = path.extname(filePath).toLowerCase();
    if (!allowedExtensions.includes(ext)) {
      throw new Error("Geçersiz dosya uzantısı");
    }

    console.log(`Dosya IPFS'e yüklendi: ${fileUrl}`);
    return fileUrl;
  } catch (error) {
    console.error("Dosya yükleme hatası:", error);
    throw error; // Re-throw for further handling (optional)
  }
}
