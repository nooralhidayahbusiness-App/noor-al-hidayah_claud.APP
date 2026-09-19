import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color deepGreen = Color(0xFF041F18);
  static const Color green = Color(0xFF0B3D2E);
  static const Color emerald = Color(0xFF14664C);
  static const Color gold = Color(0xFFD4AF37);
  static const Color softGold = Color(0xFFF1DC9A);
  static const Color cream = Color(0xFFFFF8E7);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.emerald,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.gold,
    onPrimary: AppColors.deepGreen,
    surface: AppColors.deepGreen,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.deepGreen,
  );
}
