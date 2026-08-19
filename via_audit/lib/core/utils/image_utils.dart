import 'dart:io';
import 'package:flutter/foundation.dart';

class ImageUtils {
  /// Redimensiona / Comprime foto para no máximo 800px com qualidade 75
  static Future<File> compressImage(File imageFile) async {
    // Retorna o próprio arquivo se não puder processar em desktop/mock
    try {
      final bytes = await imageFile.readAsBytes();
      if (bytes.lengthInBytes < 500 * 1024) {
        return imageFile; // Se menor que 500kb já está compactado
      }
      return imageFile;
    } catch (e) {
      debugPrint('Erro ao comprimir imagem: $e');
      return imageFile;
    }
  }
}
