import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum MpButtonVariant { primary, secondary, ghost, success }

class MpButton extends StatelessWidget {
  final String? label;
  final String? text;
  final VoidCallback? onPressed;
  final MpButtonVariant variant;
  final Widget? icon;
  final double? width;
  final double height;
  final bool isLoading;

  const MpButton({
    super.key,
    this.label,
    this.text,
    this.onPressed,
    this.variant = MpButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 48.0,
    this.isLoading = false,
  });

  String get displayText => text ?? label ?? '';

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;
    List<BoxShadow>? shadow;

    switch (variant) {
      case MpButtonVariant.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        shadow = const [
          BoxShadow(
            color: Color(0x3B0284C7),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ];
        break;
      case MpButtonVariant.secondary:
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        border = Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5);
        shadow = null;
        break;
      case MpButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.textSecondary;
        border = Border.all(color: AppColors.border, width: 1.5);
        shadow = null;
        break;
      case MpButtonVariant.success:
        bg = AppColors.success;
        fg = Colors.white;
        shadow = const [
          BoxShadow(
            color: Color(0x3B10B981),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ];
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: onPressed == null ? bg.withValues(alpha: 0.5) : bg,
        borderRadius: BorderRadius.circular(14),
        border: border,
        boxShadow: shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayText,
                        style: AppTextStyles.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: fg,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        icon!,
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
