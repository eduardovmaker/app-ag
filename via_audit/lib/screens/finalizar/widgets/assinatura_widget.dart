import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import '../../../core/theme/app_colors.dart';

class AssinaturaWidget extends StatefulWidget {
  final Function(File? file) onSignatureCaptured;

  const AssinaturaWidget({
    super.key,
    required this.onSignatureCaptured,
  });

  @override
  State<AssinaturaWidget> createState() => _AssinaturaWidgetState();
}

class _AssinaturaWidgetState extends State<AssinaturaWidget> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    _controller.addListener(() {
      _exportPng();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _exportPng() async {
    if (_controller.isNotEmpty) {
      final pngBytes = await _controller.toPngBytes();
      if (pngBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/assinatura_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(pngBytes);
        widget.onSignatureCaptured(file);
      }
    } else {
      widget.onSignatureCaptured(null);
    }
  }

  void _limpar() {
    _controller.clear();
    widget.onSignatureCaptured(null);
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
              'Assinatura do Responsável',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            TextButton.icon(
              onPressed: _limpar,
              icon: Icon(Icons.clear, size: 16, color: AppColors.danger),
              label: Text('Limpar', style: TextStyle(color: AppColors.danger, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
