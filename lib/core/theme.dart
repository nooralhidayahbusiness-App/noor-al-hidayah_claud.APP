import 'package:flutter/material.dart';

import 'theme_palette.dart';

class AppColors {
  AppColors._();

  static const Color deepGreen = Color(0xFF041F18);
  static const Color green = Color(0xFF0B3D2E);
  static const Color emerald = Color(0xFF14664C);
  static const Color gold = Color(0xFFD4AF37);
  static const Color softGold = Color(0xFFF1DC9A);
  static const Color cream = Color(0xFFFFF8E7);
}

ThemeData buildThemedAppTheme(ThemePalette palette) {
  final scheme = ColorScheme.fromSeed(
    seedColor: palette.accentLight,
    brightness: Brightness.dark,
  ).copyWith(
    primary: palette.gold,
    onPrimary: palette.accent,
    surface: palette.accent,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.accent,
    // ✅ خطوط أوضح: وزن أثقل قليلاً للنصوص التي لا تحدد وزنها صراحةً
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontWeight: FontWeight.w500),
      bodySmall: TextStyle(fontWeight: FontWeight.w500),
      titleLarge: TextStyle(fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontWeight: FontWeight.w600),
      labelLarge: TextStyle(fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontWeight: FontWeight.w600),
      labelSmall: TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}

ThemeData buildAppTheme() => buildThemedAppTheme(paletteFor('default'));
