import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  /// Redimensiona e comprime a foto para ter o menor tamanho possível (alvo 50KB - 100KB)
  /// sem perder legibilidade da auditoria (largura máxima de 800px e JPEG com qualidade 65).
  static Future<File> compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      // Decodificar imagem usando o pacote 'image'
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return imageFile;

      // Se a imagem tiver dimensões maiores que 800px, redimensiona mantendo aspecto
      img.Image resizedImage = decodedImage;
      if (decodedImage.width > 800 || decodedImage.height > 800) {
        if (decodedImage.width >= decodedImage.height) {
          resizedImage = img.copyResize(decodedImage, width: 800);
        } else {
          resizedImage = img.copyResize(decodedImage, height: 800);
        }
      }

      // Codificar como JPEG com qualidade 65 (balanço perfeito entre baixo tamanho e clareza de leitura)
      final compressedBytes = img.encodeJpg(resizedImage, quality: 65);

      // Salvar em um arquivo temporário otimizado
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/opt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(compressedBytes);

      debugPrint('⚡ Imagem comprimida de ${bytes.length} bytes para ${compressedBytes.length} bytes!');
      return compressedFile;
    } catch (e) {
      debugPrint('Erro ao comprimir imagem com pacote image: $e');
      return imageFile;
    }
  }
}
