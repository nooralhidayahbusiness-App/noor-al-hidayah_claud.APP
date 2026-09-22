import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reciter.dart';

/// Chosen reciter and playback mode, saved on the device.
class ReciterPrefs extends ChangeNotifier {
  static const _idKey = 'reciter_selected';
  static const _autoKey = 'reciter_auto_advance';

  String reciterId = kReciters.first.id;

  /// true = "full surah" (keeps playing), false = "ayah by ayah" (pauses
  /// after each verse and waits).
  bool autoAdvance = true;
  bool _loaded = false;

  Reciter get reciter => reciterById(reciterId);

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    reciterId = prefs.getString(_idKey) ?? kReciters.first.id;
    autoAdvance = prefs.getBool(_autoKey) ?? true;
    notifyListeners();
  }

  Future<void> setReciter(String id) async {
    reciterId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_idKey, id);
  }

  Future<void> setAutoAdvance(bool value) async {
    autoAdvance = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoKey, value);
  }
}

final ReciterPrefs reciterPrefs = ReciterPrefs();
