import 'package:flutter/material.dart';

/// Palette derived directly from the EBS Essential Bio Crop Science logo:
/// - Deep Foliage Green: Main leaf & monogram accents (#1B5E20 / #2E7D32)
/// - Crimson / Maroon Red: Stylized "E" & "S" letterforms and title (#B71C1C / #C62828)
/// - Turban Amber / Harvest Orange: Farmer turban highlight (#E65100 / #F57C00)
/// - Warm Natural Neutrals: Clean agronomy card surfaces and backgrounds
class AppColors {
  // Brand Primary (Green)
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color primaryGreenLight = Color(0xFF2E7D32);
  static const Color forestDark = Color(0xFF0F3E16);
  static const Color leafAccent = Color(0xFF4CAF50);
  static const Color paleGreen = Color(0xFFE8F5E9);

  // Brand Secondary (Crimson Red)
  static const Color brandRed = Color(0xFFB71C1C);
  static const Color brandRedLight = Color(0xFFD32F2F);
  static const Color redSurface = Color(0xFFFFEBEE);

  // Brand Tertiary (Harvest Amber / Orange)
  static const Color harvestAmber = Color(0xFFE65100);
  static const Color harvestAmberLight = Color(0xFFFFA000);
  static const Color amberSurface = Color(0xFFFFF3E0);

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAF8);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F1);

  // Borders & Dividers
  static const Color border = Color(0xFFE0E6E0);
  static const Color borderSubtle = Color(0xFFECEFEC);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Utility & Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color discountBadge = Color(0xFFC62828);
}
