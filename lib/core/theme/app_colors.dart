import 'package:flutter/material.dart';

/// Defines the central color palette extracted from the design system.
abstract class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF1A1D3B); // #1A1D3B
  static const Color primaryLight = Color(0xFF2A2E54);
  static const Color primaryDark = Color(0xFF0F1123);

  // Secondary Palette
  static const Color secondary = Color(0xFF2563EB); // #2563EB
  static const Color secondaryLight = Color(0xFF60A5FA);
  static const Color secondaryDark = Color(0xFF1D4ED8);

  // Tertiary / Accent Palette
  static const Color tertiary = Color(0xFF10B981); // #10B981
  static const Color tertiaryLight = Color(0xFF34D399);
  static const Color tertiaryDark = Color(0xFF059669);

  // Neutral / Slate Palette
  static const Color neutral = Color(0xFF64748B); // #64748B
  static const Color neutralLight = Color(0xFF94A3B8);
  static const Color neutralDark = Color(0xFF334155);

  // Surface & Background Colors
  static const Color background = Color(0xFFE8EEF9); // Light blue-tinted canvas
  static const Color surface = Color(0xFFEDF2FA);    // Card container background
  static const Color card = Color(0xFFFFFFFF);       // White card background
  static const Color inputBackground = Color(0xFFE0E8F6);

  // Semantic Action Colors (e.g., Delete/Error)
  static const Color error = Color(0xFFDC2626);
}