import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reciter.dart';
import 'theme_state.dart';

/// القارئ المُختار — يقرأ قيمته من [themeState] ليتزامن مع المتجر.
class ReciterPrefs extends ChangeNotifier {
  static const _idKey = 'reciter_selected';
  static const _autoKey = 'reciter_auto_advance';

  String _reciterId = kReciters.first.id;
  bool autoAdvance = true;
  bool _loaded = false;

  String get reciterId => _reciterId;

  Reciter get reciter {
    try {
      return reciterById(_reciterId);
    } catch (_) {
      return kReciters.first;
    }
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    _reciterId = prefs.getString(_idKey) ?? kReciters.first.id;
    autoAdvance = prefs.getBool(_autoKey) ?? true;

    // نستمع لـ themeState: أي تغيير للقارئ من المتجر ينعكس هنا.
    themeState.addListener(_syncFromTheme);

    notifyListeners();
  }

  void _syncFromTheme() {
    final id = themeState.reciterId;
    if (id == _reciterId) return;
    _reciterId = id;
    notifyListeners();
    SharedPreferences.getInstance().then((p) => p.setString(_idKey, id));
  }

  Future<void> setReciter(String id) async {
    _reciterId = id;
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
