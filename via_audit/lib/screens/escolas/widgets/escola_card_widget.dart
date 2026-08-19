import 'package:flutter/material.dart';
import '../../../core/models/escola_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class EscolaCardWidget extends StatelessWidget {
  final EscolaModel escola;
  final VoidCallback onTap;

  const EscolaCardWidget({
    super.key,
    required this.escola,
    required this.onTap,
  });

  Color _getBordaCor() {
    if (escola.status == 'concluida') return AppColors.success;
    if (escola.dataVisitaAgendada == '2026-06-12' || escola.status == 'em_andamento') return AppColors.warning;
    return AppColors.border;
  }

  Widget _buildBadgeStatus() {
    if (escola.status == 'concluida') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 12, color: AppColors.success),
            SizedBox(width: 4),
            Text(
              'Concluída',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
            ),
          ],
        ),
      );
    }

    if (escola.status == 'em_andamento') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.lightWarning,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: 12, color: AppColors.warning),
            SizedBox(width: 4),
            Text(
              'Em andamento',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_empty, size: 12, color: AppColors.textSecondary),
          SizedBox(width: 4),
          Text(
            'Pendente',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final distText = escola.distanciaKm != null && escola.distanciaKm! < 50
        ? ' · ${escola.distanciaKm!.toStringAsFixed(1)} km'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: Container(color: _getBordaCor()),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                escola.nome,
                                style: AppTextStyles.sans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildBadgeStatus(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${escola.cidade} · ${escola.estado}$distText',
                              style: AppTextStyles.sans(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.inventory_2_outlined, size: 12, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${escola.totalAtivos} ativos',
                                    style: AppTextStyles.sans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
