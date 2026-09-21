import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reader settings, saved on the device.
class QuranPrefs extends ChangeNotifier {
  static const _fontKey = 'quran_simple_font';
  static const _translationKey = 'quran_show_translation';

  /// false = Uthmani script (default), true = simple vowelled script.
  bool simpleFont = false;
  bool showTranslation = false;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    simpleFont = prefs.getBool(_fontKey) ?? false;
    showTranslation = prefs.getBool(_translationKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleFont() async {
    simpleFont = !simpleFont;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fontKey, simpleFont);
  }

  Future<void> toggleTranslation() async {
    showTranslation = !showTranslation;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_translationKey, showTranslation);
  }
}

final QuranPrefs quranPrefs = QuranPrefs();
