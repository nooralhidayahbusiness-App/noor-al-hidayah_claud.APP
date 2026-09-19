import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final RegExp _arabicChars = RegExp(r'[\u0600-\u06FF]');

/// Brand text style for the app name:
/// Uthmani-style Naskh (Amiri Quran) for Arabic, Cinzel for Latin text.
TextStyle brandStyle(
  String text, {
  required double fontSize,
  FontWeight? fontWeight,
  double? height,
  double? letterSpacing,
  Color? color,
  List<Shadow>? shadows,
}) {
  if (_arabicChars.hasMatch(text)) {
    return GoogleFonts.amiriQuran(
      fontSize: fontSize * 1.1,
      height: 1.7,
      color: color,
      shadows: shadows,
    );
  }
  return GoogleFonts.cinzel(
    fontSize: fontSize * 0.8,
    fontWeight: fontWeight ?? FontWeight.w600,
    height: height,
    letterSpacing: letterSpacing ?? 1.5,
    color: color,
    shadows: shadows,
  );
}
