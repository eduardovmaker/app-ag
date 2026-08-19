import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mp_button.dart';

class AddExtraBottomSheet extends StatefulWidget {
  final Function(String descricao, int quantidade) onSave;

  const AddExtraBottomSheet({
    super.key,
    required this.onSave,
  });

  @override
  State<AddExtraBottomSheet> createState() => _AddExtraBottomSheetState();
}

class _AddExtraBottomSheetState extends State<AddExtraBottomSheet> {
  final _descController = TextEditingController();
  final _qtdController = TextEditingController(text: '1');

  @override
  void dispose() {
    _descController.dispose();
    _qtdController.dispose();
    super.dispose();
  }

  void _submit() {
    final desc = _descController.text.trim();
    final qtd = int.tryParse(_qtdController.text.trim()) ?? 1;

    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a descrição do item extra.')),
      );
      return;
    }

    widget.onSave(desc, qtd);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registrar Item Extra',
            style: AppTextStyles.sans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Descrição do Ativo',
              hintText: 'Ex: Projetor Adicional Epson',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _qtdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantidade',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          MpButton(
            text: 'Salvar Item Extra',
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
