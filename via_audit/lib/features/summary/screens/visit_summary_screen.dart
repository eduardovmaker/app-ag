import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mp_button.dart';
import '../../audit/providers/audit_provider.dart';

class VisitSummaryScreen extends StatefulWidget {
  const VisitSummaryScreen({super.key});

  @override
  State<VisitSummaryScreen> createState() => _VisitSummaryScreenState();
}

class _VisitSummaryScreenState extends State<VisitSummaryScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: AppColors.textPrimary,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  void _openSignatureDialog(AuditProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Assinatura do Diretor',
            style: AppTextStyles.sans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Signature(
                    controller: _signatureController,
                    backgroundColor: AppColors.bgLight,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _signatureController.clear();
                  },
                  child: Text(
                    'Limpar',
                    style: AppTextStyles.sans(
                      fontSize: 11,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: AppTextStyles.sans(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final bytes = await _signatureController.toPngBytes();
                if (bytes != null) {
                  provider.setSignature(bytes);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Salvar Assinatura',
                style: AppTextStyles.sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _finishVisit(AuditProvider provider) {
    provider.completeVisit();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              'Sucesso!',
              style: AppTextStyles.sans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Visita finalizada e sincronizada com sucesso.',
          style: AppTextStyles.sans(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.go('/schools');
            },
            child: Text(
              'OK',
              style: AppTextStyles.sans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auditProvider = Provider.of<AuditProvider>(context);
    final school = auditProvider.currentSchool;
    final done = auditProvider.completedCount;
    final damaged = auditProvider.damagedCount;
    final missing = auditProvider.missingCount;
    final extra = auditProvider.extraCount;
    final total = auditProvider.checklistItems.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Resumo da Visita',
          style: AppTextStyles.sans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Header Banner
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.lightSuccess,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visita concluída',
                            style: AppTextStyles.sans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Resumo antes de enviar',
                            style: AppTextStyles.sans(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.lightSuccess,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                school.name,
                                style: AppTextStyles.sans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                            Text(
                              '$done/$total',
                              style: AppTextStyles.mono(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Conferidos: $done · Divergências: ${damaged + missing} · Itens extras: $extra',
                          style: AppTextStyles.sans(
                            fontSize: 10,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Breakdown Section
                  Text(
                    'RESUMO DE ITENS',
                    style: AppTextStyles.mono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('✓ Encontrados', done.toString(), AppColors.success),
                        const Divider(height: 1, color: AppColors.border),
                        _buildSummaryRow('⚠ Avariados', damaged.toString(), const Color(0xFFA37500)),
                        const Divider(height: 1, color: AppColors.border),
                        _buildSummaryRow('✕ Não encontrados', missing.toString(), const Color(0xFFB94532)),
                        const Divider(height: 1, color: AppColors.border),
                        _buildSummaryRow('+ Extras', extra.toString(), AppColors.textMuted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Signature Section
                  Text(
                    'ASSINATURA DO DIREITOR',
                    style: AppTextStyles.mono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _openSignatureDialog(auditProvider),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Center(
                        child: auditProvider.signatureBytes != null
                            ? Image.memory(
                                auditProvider.signatureBytes!,
                                height: 40,
                              )
                            : Text(
                                'Toque para coletar assinatura',
                                style: AppTextStyles.sans(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer Button & Sync Note
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  MpButton(
                    label: 'Finalizar e sincronizar',
                    variant: MpButtonVariant.success,
                    onPressed: () => _finishVisit(auditProvider),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Os dados serão enviados quando houver conexão',
                    style: AppTextStyles.sans(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.sans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.mono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
