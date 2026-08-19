import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.surface,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.surface,
      ),
      textTheme: TextTheme(
        bodyLarge: AppTextStyles.sans(fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: AppTextStyles.sans(fontSize: 14, color: AppColors.textSecondary),
        bodySmall: AppTextStyles.sans(fontSize: 12, color: AppColors.textMuted),
        titleLarge: AppTextStyles.sans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleMedium: AppTextStyles.sans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    );
  }
}
