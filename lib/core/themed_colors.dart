import 'package:flutter/material.dart';

import 'theme_state.dart';

/// ألوان الثيم الحالية.
/// تُقرأ من themeState.palette في كل مرة — لذا تتغير فوراً مع الثيم.
class ThemedColors {
  ThemedColors._();

  static Color get accent => themeState.palette.accent;
  static Color get accentDark => themeState.palette.accentDark;
  static Color get accentLight => themeState.palette.accentLight;
  static Color get gold => themeState.palette.gold;
  static Color get softGold => themeState.palette.softGold;
  static Color get cream => themeState.palette.cream;
}
