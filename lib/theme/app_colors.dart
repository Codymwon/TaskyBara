import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Light palette ───────────────────────────────────────

  // Primary Background — Warm Off-White / Cream
  static const Color background = Color(0xFFF7F3EE);

  // Primary Accent — Capybara Fur (soft brown)
  static const Color primary = Color(0xFFB08968);

  // Secondary Accent — Capybara Nose / Shadow (muted dark brown)
  static const Color secondary = Color(0xFF7F5539);

  // Text colors
  static const Color textPrimary = Color(0xFF5C4033);
  static const Color textSecondary = Color(0xFF8B7355);
  static const Color textLight = Color(0xFFB8A99A);

  // ─── Dark palette ────────────────────────────────────────

  static const Color darkBackground = Color(0xFF1E1B18);
  static const Color darkPrimary = Color(0xFFC9A882);
  static const Color darkSecondary = Color(0xFFD4A574);
  static const Color darkTextPrimary = Color(0xFFE8DDD0);
  static const Color darkTextSecondary = Color(0xFFB8A99A);
  static const Color darkTextLight = Color(0xFF6B5E52);

  // ─── Shared accents (same in both modes) ─────────────────

  // Success / Completed — Warm Tea Green
  static const Color success = Color(0xFFA3B18A);

  // Info / In Progress — Soft Sky Blue
  static const Color info = Color(0xFFB7D3DF);

  // Danger / Delete — Dusty Coral
  static const Color danger = Color(0xFFD77A61);

  // ─── Priority colors ─────────────────────────────────────

  static const Color priorityLow = Color(0xFFA3B18A);    // green
  static const Color priorityMedium = Color(0xFFD4A574);  // amber
  static const Color priorityHigh = Color(0xFFD77A61);    // coral
}
