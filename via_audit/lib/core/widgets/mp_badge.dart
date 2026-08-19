import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum MpBadgeType { ok, warn, danger, pend, extra }

class MpBadge extends StatelessWidget {
  final String label;
  final MpBadgeType type;

  const MpBadge({
    super.key,
    required this.label,
    this.type = MpBadgeType.pend,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case MpBadgeType.ok:
        bg = AppColors.lightSuccess;
        fg = AppColors.success;
        break;
      case MpBadgeType.warn:
        bg = AppColors.lightWarning;
        fg = AppColors.warning;
        break;
      case MpBadgeType.danger:
        bg = AppColors.lightError;
        fg = AppColors.error;
        break;
      case MpBadgeType.pend:
        bg = AppColors.lightPrimary;
        fg = AppColors.primary;
        break;
      case MpBadgeType.extra:
        bg = AppColors.bgLight;
        fg = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.mono(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
