import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme({bool highContrast = false}) {
    final foreground = highContrast
        ? const Color(0xFF111827)
        : AppColors.primary;
    final accent = highContrast ? const Color(0xFF0046B8) : AppColors.secondary;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: accent,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: foreground,
          error: AppColors.error,
          onError: Colors.white,
        );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      dividerColor: const Color(0xFFE2E7F0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.neutral),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: highContrast
              ? BorderSide(color: foreground.withValues(alpha: 0.45))
              : BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData darkTheme({bool highContrast = false}) {
    final foreground = highContrast
        ? const Color(0xFFFFFFFF)
        : const Color(0xFFF1F4FA);
    final surface = highContrast
        ? const Color(0xFF101522)
        : const Color(0xFF1B2333);
    final accent = highContrast
        ? const Color(0xFF9BB9FF)
        : const Color(0xFF82A7FF);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ).copyWith(
          primary: accent,
          onPrimary: const Color(0xFF101522),
          secondary: accent,
          onSecondary: const Color(0xFF101522),
          surface: surface,
          onSurface: foreground,
          error: const Color(0xFFFF8A80),
          onError: const Color(0xFF3B0909),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF111827),
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      dividerColor: const Color(0xFF343E50),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF242E40),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Color(0xFFB2BDCF)),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: highContrast
              ? BorderSide(color: foreground.withValues(alpha: 0.65))
              : BorderSide.none,
        ),
      ),
    );
  }
}
