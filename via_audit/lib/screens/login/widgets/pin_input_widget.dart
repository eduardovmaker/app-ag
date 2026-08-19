import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PinInputWidget extends StatelessWidget {
  final String pin;
  final int maxLength;

  const PinInputWidget({
    super.key,
    required this.pin,
    this.maxLength = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (index) {
        final isFilled = index < pin.length;
        final digit = isFilled ? pin[index] : '';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 48,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFilled ? AppColors.primary : AppColors.border,
              width: isFilled ? 2.0 : 1.0,
            ),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              digit,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );
      }),
    );
  }
}
