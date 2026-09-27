import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

/// الحالة العامة للتطبيق: الخلفية، القارئ، المؤذن، الثيم.
/// تُحفظ محلياً + في Firestore.
class ThemeState extends ChangeNotifier {
  static const _bgKey = 'active_background';
  static const _voiceKey = 'active_voice';
  static const _adhanKey = 'active_adhan';
  static const _themeKey = 'active_theme';

  String backgroundId = 'default';
  String reciterId = 'default';
  String adhanId = 'default';
  String themeId = 'default';
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    // 1) من Firestore
    try {
      if (authService.isSignedIn) {
        final data = await authService.loadUserData();
        final inventory = (data?['inventory'] as Map?) ?? {};
        backgroundId =
            (inventory['activeBackground'] as String?) ?? 'default';
        reciterId = (inventory['activeVoice'] as String?) ?? 'default';
        adhanId = (inventory['activeAdhan'] as String?) ?? 'default';
        themeId = (inventory['activeTheme'] as String?) ?? 'default';
        await _saveLocal();
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('ThemeState.load remote error: $e');
    }

    // 2) من الجهاز
    final prefs = await SharedPreferences.getInstance();
    backgroundId = prefs.getString(_bgKey) ?? 'default';
    reciterId = prefs.getString(_voiceKey) ?? 'default';
    adhanId = prefs.getString(_adhanKey) ?? 'default';
    themeId = prefs.getString(_themeKey) ?? 'default';
    notifyListeners();
  }

  Future<void> setBackground(String id) async {
    backgroundId = id;
    notifyListeners();
    await _saveLocal();
    await _saveRemote('activeBackground', id);
  }

  Future<void> setReciter(String id) async {
    reciterId = id;
    notifyListeners();
    await _saveLocal();
    await _saveRemote('activeVoice', id);
  }

  Future<void> setAdhan(String id) async {
    adhanId = id;
    notifyListeners();
    await _saveLocal();
    await _saveRemote('activeAdhan', id);
  }

  Future<void> setTheme(String id) async {
    themeId = id;
    notifyListeners();
    await _saveLocal();
    await _saveRemote('activeTheme', id);
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bgKey, backgroundId);
    await prefs.setString(_voiceKey, reciterId);
    await prefs.setString(_adhanKey, adhanId);
    await prefs.setString(_themeKey, themeId);
  }

  Future<void> _saveRemote(String key, String value) async {
    try {
      await authService.saveUserData({
        'inventory': {key: value}
      });
    } catch (e) {
      debugPrint('ThemeState.saveRemote error: $e');
    }
  }
}

final ThemeState themeState = ThemeState();
