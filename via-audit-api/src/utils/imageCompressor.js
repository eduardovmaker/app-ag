const sharp = require('sharp');
const fs = require('fs');

/**
 * Comprime e redimensiona imagem no backend para garantir o menor tamanho de arquivo (máx ~50KB-100KB)
 * ideal para salvar espaço e tráfego na Cloudflare R2.
 */
async function compressImageFile(filePath) {
  try {
    if (!fs.existsSync(filePath)) return filePath;

    const buffer = await fs.promises.readFile(filePath);
    const compressedBuffer = await sharp(buffer)
      .resize(800, 800, {
        fit: 'inside',
        withoutEnlargement: true
      })
      .jpeg({ quality: 65, progressive: true })
      .toBuffer();

    await fs.promises.writeFile(filePath, compressedBuffer);
    console.log(`⚡ [Backend Compress] Foto ${filePath} comprimida com sucesso para ${compressedBuffer.length} bytes!`);
    return filePath;
  } catch (err) {
    console.error('Erro ao comprimir imagem com sharp:', err);
    return filePath;
  }
}

/**
 * Converte string Base64 em arquivo de imagem JPEG altamente compactado
 */
async function saveAndCompressBase64(base64String, targetPath) {
  try {
    const base64Data = base64String.replace(/^data:image\/\w+;base64,/, '');
    const rawBuffer = Buffer.from(base64Data, 'base64');

    const compressedBuffer = await sharp(rawBuffer)
      .resize(800, 800, {
        fit: 'inside',
        withoutEnlargement: true
      })
      .jpeg({ quality: 65, progressive: true })
      .toBuffer();

    await fs.promises.writeFile(targetPath, compressedBuffer);
    return true;
  } catch (err) {
    console.error('Erro ao comprimir Base64 com sharp:', err);
    const base64Data = base64String.replace(/^data:image\/\w+;base64,/, '');
    await fs.promises.writeFile(targetPath, Buffer.from(base64Data, 'base64'));
    return false;
  }
}

module.exports = {
  compressImageFile,
  saveAndCompressBase64
};
