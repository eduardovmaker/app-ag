import 'dart:io';
import 'package:flutter/material.dart';

class FotoCapturaWidget extends StatelessWidget {
  final File? foto1;
  final File? foto2;
  final File? foto3;
  final bool hasGps;
  final Function(int slot) onTirarFotoSlot;

  const FotoCapturaWidget({
    super.key,
    this.foto1,
    this.foto2,
    this.foto3,
    this.hasGps = false,
    required this.onTirarFotoSlot,
  });

  Widget _buildPhotoSlot({
    required int slotNumber,
    required String label,
    required bool isMandatory,
    required File? foto,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTirarFotoSlot(slotNumber),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isMandatory
                  ? (foto != null ? Colors.green.shade400 : Colors.blue.shade400)
                  : Colors.grey.shade700,
              width: 1.5,
            ),
            image: foto != null
                ? DecorationImage(
                    image: FileImage(foto),
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
                      Icon(
                        Icons.camera_alt_outlined,
                        color: isMandatory ? Colors.white : Colors.white70,
                        size: 26,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isMandatory ? Colors.white : Colors.white70,
                          fontSize: 11,
                          fontWeight: isMandatory ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      Text(
                        isMandatory ? '(Obrigatória)' : '(Opcional)',
                        style: TextStyle(
                          color: isMandatory ? Colors.amberAccent : Colors.grey.shade400,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              if (foto != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.refresh, color: Colors.white, size: 14),
                  ),
                ),

              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Foto $slotNumber',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fotos de Evidência da Auditoria (até 3 fotos)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: hasGps ? Colors.greenAccent : Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  hasGps ? 'GPS OK' : 'Sem GPS',
                  style: TextStyle(
                    color: hasGps ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPhotoSlot(slotNumber: 1, label: 'Principal', isMandatory: true, foto: foto1),
            const SizedBox(width: 8),
            _buildPhotoSlot(slotNumber: 2, label: 'Etiqueta / SN', isMandatory: false, foto: foto2),
            const SizedBox(width: 8),
            _buildPhotoSlot(slotNumber: 3, label: 'Vista Geral', isMandatory: false, foto: foto3),
          ],
        ),
      ],
    );
  }
}
