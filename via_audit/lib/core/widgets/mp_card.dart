import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MpCard extends StatelessWidget {
  final Widget child;
  final Color? leftBorderColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const MpCard({
    super.key,
    required this.child,
    this.leftBorderColor,
    this.onTap,
    this.padding = const EdgeInsets.all(12.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A2553B9),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (leftBorderColor != null)
                    Container(
                      width: 4,
                      color: leftBorderColor,
                    ),
                  Expanded(
                    child: Padding(
                      padding: padding,
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
