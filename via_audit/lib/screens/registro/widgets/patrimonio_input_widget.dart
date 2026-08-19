import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/registro_service.dart';
import '../../../core/theme/app_colors.dart';

class PatrimonioInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final int ativoId;
  final Function(bool isValid) onValidationChanged;
  final VoidCallback onScanCamera;

  const PatrimonioInputWidget({
    super.key,
    required this.controller,
    required this.ativoId,
    required this.onValidationChanged,
    required this.onScanCamera,
  });

  @override
  State<PatrimonioInputWidget> createState() => _PatrimonioInputWidgetState();
}

class _PatrimonioInputWidgetState extends State<PatrimonioInputWidget> {
  final RegistroService _registroService = RegistroService();
  Timer? _debounceTimer;

  bool _isValidating = false;
  bool? _isValid;
  String? _message;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    String text = widget.controller.text.trim().toUpperCase();

    // Se o usuário digitou apenas 6 números (ex: 000026), insere o V automaticamente
    if (RegExp(r'^\d{6}$').hasMatch(text)) {
      text = 'V$text';
      widget.controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    if (text.isEmpty) {
      setState(() {
        _isValid = null;
        _message = null;
        _isValidating = false;
      });
      widget.onValidationChanged(false);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      setState(() {
        _isValidating = true;
      });

      final result = await _registroService.validarPatrimonio(text, widget.ativoId);

      if (mounted) {
        final valid = result['valido'] == true;
        setState(() {
          _isValidating = false;
          _isValid = valid;
          _message = valid ? (result['descricao'] ?? 'Patrimônio Válido (V + 6 dígitos)') : (result['motivo'] ?? 'Deve seguir o formato V seguido de 6 dígitos');
        });
        widget.onValidationChanged(valid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patrimônio Físico (V + 6 dígitos)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Ex: V000026',
                  border: const OutlineInputBorder(),
                  suffixIcon: _isValidating
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : (_isValid != null
                          ? Icon(
                              _isValid! ? Icons.check_circle : Icons.error,
                              color: _isValid! ? AppColors.success : AppColors.danger,
                            )
                          : null),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: widget.onScanCamera,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        if (_message != null) ...[
          const SizedBox(height: 6),
          Text(
            _message!,
            style: TextStyle(
              fontSize: 12,
              color: _isValid == true ? AppColors.success : AppColors.danger,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
