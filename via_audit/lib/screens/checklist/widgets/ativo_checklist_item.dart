import 'package:flutter/material.dart';
import '../../../core/models/ativo_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AtivoChecklistItem extends StatelessWidget {
  final AtivoModel ativo;
  final bool isFocused;
  final VoidCallback onTap;

  const AtivoChecklistItem({
    super.key,
    required this.ativo,
    this.isFocused = false,
    required this.onTap,
  });

  Widget _buildStatusIcon() {
    switch (ativo.statusChecklist) {
      case 'conferido':
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
          child: const Center(
            child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
          ),
        );
      case 'divergente':
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: AppColors.lightError, shape: BoxShape.circle),
          child: const Center(
            child: Icon(Icons.error_rounded, color: AppColors.error, size: 22),
          ),
        );
      case 'em_andamento':
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: AppColors.lightWarning, shape: BoxShape.circle),
          child: const Center(
            child: Icon(Icons.pending_rounded, color: AppColors.warning, size: 20),
          ),
        );
      default:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: const Center(
            child: Icon(Icons.radio_button_unchecked_rounded, color: AppColors.textMuted, size: 18),
          ),
        );
    }
  }

  Widget _buildBadge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasBreakdown = ativo.qtdOk > 0 || ativo.qtdAvariado > 0 || ativo.qtdNaoEncontrado > 0 || ativo.qtdExtra > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isFocused ? AppColors.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? AppColors.primary : AppColors.border,
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: _buildStatusIcon(),
        title: Text(
          ativo.descricao,
          style: AppTextStyles.sans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${ativo.quantidade} un · NF ${ativo.nf ?? "S/N"} · (${ativo.unidadesRegistradas}/${ativo.quantidade} auditadas)',
                style: AppTextStyles.sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              if (hasBreakdown) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (ativo.qtdOk > 0)
                      _buildBadge('🟢 ${ativo.qtdOk} OK', Colors.green.shade50, Colors.green.shade800),
                    if (ativo.qtdAvariado > 0)
                      _buildBadge('⚠️ ${ativo.qtdAvariado} avariado(s)', Colors.orange.shade50, Colors.orange.shade800),
                    if (ativo.qtdNaoEncontrado > 0)
                      _buildBadge('❌ ${ativo.qtdNaoEncontrado} não enc.', Colors.red.shade50, Colors.red.shade800),
                    if (ativo.qtdExtra > 0)
                      _buildBadge('➕ ${ativo.qtdExtra} extra', Colors.blue.shade50, Colors.blue.shade800),
                  ],
                ),
              ],
            ],
          ),
        ),
        trailing: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
        ),
      ),
    );
  }
}
