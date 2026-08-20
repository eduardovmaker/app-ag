import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mp_badge.dart';
import '../../../core/widgets/mp_card.dart';
import '../../../core/widgets/mp_kpi_card.dart';
import '../../audit/providers/audit_provider.dart';

class SchoolListScreen extends StatelessWidget {
  const SchoolListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auditProvider = Provider.of<AuditProvider>(context);
    final schools = auditProvider.schools;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            // User Avatar
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.lightPrimary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'DM',
                  style: AppTextStyles.sans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // User Greeting
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bom dia,',
                  style: AppTextStyles.sans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  'Daniela M.',
                  style: AppTextStyles.sans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // KPI Card
            const MpKpiCard(
              value: '3 / 12',
              label: 'escolas visitadas',
              progress: 3 / 12,
            ),
            const SizedBox(height: 20),

            // Section Label
            Text(
              'PRÓXIMAS VISITAS',
              style: AppTextStyles.mono(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),

            // School Cards List
            ...List.generate(schools.length, (index) {
              final school = schools[index];
              Color? leftBorderColor;
              MpBadgeType badgeType;
              String badgeLabel;

              if (school.status == 'scheduled') {
                leftBorderColor = AppColors.warning;
                badgeType = MpBadgeType.warn;
                badgeLabel = 'Agendada Hoje';
              } else if (school.status == 'completed') {
                leftBorderColor = null;
                badgeType = MpBadgeType.ok;
                badgeLabel = 'Concluída';
              } else {
                leftBorderColor = null;
                badgeType = MpBadgeType.pend;
                badgeLabel = 'Pendente';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: MpCard(
                  leftBorderColor: leftBorderColor,
                  onTap: () {
                    auditProvider.selectSchool(index);
                    context.push('/checklist');
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // School Name
                      Text(
                        school.name,
                        style: AppTextStyles.sans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Location & Distance Line
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${school.city} · ${school.distance}',
                            style: AppTextStyles.sans(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Status Badge & Assets Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MpBadge(
                            label: badgeLabel,
                            type: badgeType,
                          ),
                          Text(
                            '${school.visitedAssets}/${school.totalAssets} ativos',
                            style: AppTextStyles.mono(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
