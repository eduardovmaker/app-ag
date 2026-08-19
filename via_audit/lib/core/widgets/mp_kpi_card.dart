import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'mp_progress_bar.dart';

class MpKpiCard extends StatelessWidget {
  final String value;
  final String label;
  final String subtext;
  final double progress;

  const MpKpiCard({
    super.key,
    required this.value,
    required this.label,
    required this.subtext,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Value & Label
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTextStyles.mono(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.sans(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          // Right Progress Bar & Subtext
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              MpProgressBar(
                progress: progress,
                width: 60,
                height: 6,
              ),
              const SizedBox(height: 4),
              Text(
                subtext,
                style: AppTextStyles.sans(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
