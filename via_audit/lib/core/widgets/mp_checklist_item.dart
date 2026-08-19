import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum MpChecklistStatus { done, miss, pending, active }

class MpChecklistItem extends StatelessWidget {
  final String title;
  final String meta;
  final MpChecklistStatus status;
  final VoidCallback? onTap;

  const MpChecklistItem({
    super.key,
    required this.title,
    required this.meta,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == MpChecklistStatus.active;

    Widget statusIcon;
    switch (status) {
      case MpChecklistStatus.done:
        statusIcon = Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.check, size: 12, color: Colors.white),
        );
        break;
      case MpChecklistStatus.miss:
        statusIcon = Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.close, size: 12, color: Colors.white),
        );
        break;
      case MpChecklistStatus.active:
        statusIcon = Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.lightPrimary,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.play_arrow_rounded, size: 10, color: AppColors.primary),
          ),
        );
        break;
      case MpChecklistStatus.pending:
        statusIcon = Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border, width: 2),
          ),
        );
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.lightPrimary : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
          width: isActive ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                statusIcon,
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.sans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: AppTextStyles.sans(
                          fontSize: 9,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
