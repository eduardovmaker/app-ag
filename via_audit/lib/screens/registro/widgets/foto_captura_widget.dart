import 'dart:io';
import 'package:flutter/material.dart';

class FotoCapturaWidget extends StatelessWidget {
  final File? foto;
  final bool hasGps;
  final VoidCallback onTirarFoto;

  const FotoCapturaWidget({
    super.key,
    this.foto,
    this.hasGps = false,
    required this.onTirarFoto,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTirarFoto,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          image: foto != null
              ? DecorationImage(
                  image: FileImage(foto!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            if (foto == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tirar foto do item (obrigatório)',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

            // Indicator GPS overlay
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: hasGps ? Colors.greenAccent : Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasGps ? 'GPS ●' : 'Sem GPS',
                      style: TextStyle(
                        color: hasGps ? Colors.greenAccent : Colors.redAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (foto != null)
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: onTirarFoto,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
