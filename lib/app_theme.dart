import 'package:flutter/material.dart';

/// Centralized theme and constants for the Business India Game App.
/// Update this file to change colors, fonts, and spacing globally.

class AppColors {
  static const Color primary = Color(0xFF0ED2F7);
  static const Color accent = Color(0xFFB2FEFA);
  static const Color background = Color(0xFF4A90E2);
  static const Color button = Color(0xFF00C853);
  static const Color buttonText = Colors.white;
  static const Color avatarBorder = Colors.greenAccent;
  static const Color avatarShadow = Color(0x2900C853);
  static const Color textPrimary = Color(0xFF0A2540);
  static const Color textSecondary = Color(0xFF4A90E2);
  static const Color card = Colors.white;
}

class AppTextStyles {
  static TextStyle titleLarge(double scale) => TextStyle(
        fontSize: 24 * scale,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 1.2 * scale,
      );
  static TextStyle bodyLarge(double scale) => TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
  static TextStyle button(double scale) => TextStyle(
        fontSize: 18 * scale,
        fontWeight: FontWeight.bold,
        color: AppColors.buttonText,
        letterSpacing: 1.2 * scale,
      );
}

class AppSpacing {
  static double avatarOuter(double scale, {bool selected = false}) => selected ? 26 * scale : 22 * scale;
  static double avatarInner(double scale, {bool selected = false}) => selected ? 22 * scale : 18 * scale;
  static double cardPadding(double scale) => 18 * scale;
  static double cardRadius(double scale) => 16 * scale;
  static double buttonPaddingH(double scale) => 36 * scale;
  static double buttonPaddingV(double scale) => 10 * scale;
  static double fieldRadius(double scale) => 14 * scale;
  static double buttonRadius(double scale) => 12 * scale;
}
