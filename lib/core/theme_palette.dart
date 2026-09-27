import 'package:flutter/material.dart';

/// لوحة ألوان الثيم — الذهبي ثابت، لكن اللون الأساسي يتغير.
class ThemePalette {
  final String id;
  final Color accent;       // اللون الأساسي (كان deepGreen)
  final Color accentDark;   // نسخة داكنة
  final Color accentLight;  // نسخة فاتحة
  final Color gold;
  final Color softGold;
  final Color cream;

  const ThemePalette({
    required this.id,
    required this.accent,
    required this.accentDark,
    required this.accentLight,
    this.gold = const Color(0xFFD4AF37),
    this.softGold = const Color(0xFFF1DC9A),
    this.cream = const Color(0xFFFFF8E7),
  });
}

const Map<String, ThemePalette> kThemePalettes = {
  'default': ThemePalette(
    id: 'default',
    accent: Color(0xFF041F18),
    accentDark: Color(0xFF020F0C),
    accentLight: Color(0xFF0B3D2E),
  ),
  'royal': ThemePalette(
    id: 'royal',
    accent: Color(0xFF1A0533),
    accentDark: Color(0xFF0F031F),
    accentLight: Color(0xFF4A148C),
  ),
  'ocean': ThemePalette(
    id: 'ocean',
    accent: Color(0xFF0A1A3F),
    accentDark: Color(0xFF050D1F),
    accentLight: Color(0xFF0D47A1),
  ),
  'sunsetTheme': ThemePalette(
    id: 'sunsetTheme',
    accent: Color(0xFF3D1F0A),
    accentDark: Color(0xFF1F0F05),
    accentLight: Color(0xFFB85C1F),
  ),
  'rose': ThemePalette(
    id: 'rose',
    accent: Color(0xFF3D0A1F),
    accentDark: Color(0xFF1F0510),
    accentLight: Color(0xFFC2185B),
  ),
  'emerald': ThemePalette(
    id: 'emerald',
    accent: Color(0xFF042F28),
    accentDark: Color(0xFF021714),
    accentLight: Color(0xFF00695C),
  ),
};

ThemePalette paletteFor(String id) =>
    kThemePalettes[id] ?? kThemePalettes['default']!;
