import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Colors (Sky / Electric Blue)
  static const Color primary = Color(0xFF0284C7);
  static const Color primaryHover = Color(0xFF0369A1);
  static const Color lightPrimary = Color(0xFFF0F9FF);
  static const Color secondary = Color(0xFF0EA5E9);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color lightSuccess = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color lightWarning = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444);
  static const Color lightError = Color(0xFFFEF2F2);

  // Neutral / Slate Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Background & Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color bgLight = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // Aliases
  static const Color primaryLight = lightPrimary;
  static const Color successLight = lightSuccess;
  static const Color warningLight = lightWarning;
  static const Color danger = error;
}
