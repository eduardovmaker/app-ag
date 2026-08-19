import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum MpActionType { ok, warn, danger, extra }

class MpActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final MpActionType type;
  final bool isActive;
  final VoidCallback onTap;

  const MpActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.type,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color fg;

    if (isActive) {
      switch (type) {
        case MpActionType.ok:
          bg = AppColors.lightSuccess;
          border = AppColors.success;
          fg = AppColors.success;
          break;
        case MpActionType.warn:
          bg = AppColors.lightWarning;
          border = AppColors.warning;
          fg = AppColors.warning;
          break;
        case MpActionType.danger:
          bg = AppColors.lightError;
          border = AppColors.error;
          fg = AppColors.error;
          break;
        case MpActionType.extra:
          bg = AppColors.lightPrimary;
          border = AppColors.primary;
          fg = AppColors.primary;
          break;
      }
    } else {
      bg = AppColors.surface;
      border = AppColors.border;
      fg = AppColors.textSecondary;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: fg),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
