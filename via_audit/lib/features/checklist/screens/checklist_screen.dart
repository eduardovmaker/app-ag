import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mp_button.dart';
import '../../../core/widgets/mp_checklist_item.dart';
import '../../../core/widgets/mp_progress_bar.dart';
import '../../audit/providers/audit_provider.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auditProvider = Provider.of<AuditProvider>(context);
    final school = auditProvider.currentSchool;
    final items = auditProvider.checklistItems;
    final totalChecked = auditProvider.totalChecked;
    final totalItems = items.length;
    final double progress = totalItems > 0 ? totalChecked / totalItems : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar & Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 10,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Voltar',
                            style: AppTextStyles.sans(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // School Title
                  Text(
                    school.name,
                    style: AppTextStyles.sans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Subtitle
                  Text(
                    '${school.city} · Cód. #48920',
                    style: AppTextStyles.sans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // KPI "5 / 9 itens conferidos" with progress bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$totalChecked / $totalItems itens conferidos',
                              style: AppTextStyles.mono(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '${(progress * 100).round()}%',
                              style: AppTextStyles.mono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        MpProgressBar(progress: progress, height: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ListView of Checklist items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  MpChecklistStatus itemStatus;

                  if (index == auditProvider.selectedItemIndex) {
                    itemStatus = MpChecklistStatus.active;
                  } else if (item.status == 'done') {
                    itemStatus = MpChecklistStatus.done;
                  } else if (item.status == 'miss') {
                    itemStatus = MpChecklistStatus.miss;
                  } else {
                    itemStatus = MpChecklistStatus.pending;
                  }

                  return MpChecklistItem(
                    title: item.name,
                    meta: '${item.unitNumber} un · ${item.docNumber}',
                    status: itemStatus,
                    onTap: () {
                      auditProvider.selectItem(index);
                      context.push('/item-register');
                    },
                  );
                },
              ),
            ),

            // Footer with 2 buttons
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: MpButton(
                      label: '+ Extra',
                      variant: MpButtonVariant.ghost,
                      onPressed: () {
                        context.push('/item-register');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: MpButton(
                      label: 'Continuar →',
                      variant: MpButtonVariant.primary,
                      onPressed: () {
                        if (totalChecked >= totalItems) {
                          context.push('/visit-summary');
                        } else {
                          context.push('/item-register');
                        }
                      },
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
}
