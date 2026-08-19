import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NumericKeyboard extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackPressed;

  const NumericKeyboard({
    super.key,
    required this.onDigitPressed,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) {
                return const SizedBox(width: 72, height: 56);
              }
              if (key == 'back') {
                return InkWell(
                  onTap: onBackPressed,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 72,
                    height: 56,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.backspace_outlined,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                );
              }

              return InkWell(
                onTap: () => onDigitPressed(key),
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 72,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    key,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
