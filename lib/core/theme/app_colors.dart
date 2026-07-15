import 'package:flutter/material.dart';

/// Brand palette — Dark Mode first, Material You inspired.
abstract final class AppColors {
  // Dark
  static const Color darkBackground = Color(0xFF111315);
  static const Color darkSurface = Color(0xFF1B1E22);
  static const Color darkSurfaceElevated = Color(0xFF242830);
  static const Color darkBorder = Color(0xFF2C3038);
  static const Color darkTextPrimary = Color(0xFFF5F7FA);
  static const Color darkTextSecondary = Color(0xFF9AA3B2);
  static const Color darkTextTertiary = Color(0xFF8A93A0);

  // Light
  static const Color lightBackground = Color(0xFFF4F6F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF0F2F5);
  static const Color lightBorder = Color(0xFFE2E6EC);
  static const Color lightTextPrimary = Color(0xFF111315);
  static const Color lightTextSecondary = Color(0xFF5C6570);
  static const Color lightTextTertiary = Color(0xFF8A93A0);

  // Semantic
  static const Color primary = Color(0xFF5B8DEF);
  static const Color primaryDark = Color(0xFF3D6FD6);
  static const Color accent = Color(0xFF2DD4BF);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFF44336);

  // AMOLED pure black option
  static const Color amoledBlack = Color(0xFF000000);

  static const Color dropSet = Color(0xFFFF9800);
  static const Color failBadge = Color(0xFFF44336);
  static const Color prGold = Color(0xFFFFD54F);
}
