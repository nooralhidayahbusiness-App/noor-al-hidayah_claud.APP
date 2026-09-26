import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

/// The chosen profile picture ('man' or 'woman').
/// Saved locally AND synced to Firestore.
class ProfileState extends ChangeNotifier {
  static const _key = 'profile_avatar';

  String? avatar;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    // 1) نحاول نقرأ من Firestore أولاً (المصدر الأساسي)
    try {
      if (authService.isSignedIn) {
        final data = await authService.loadUserData();
        final remoteAvatar = data?['avatar'] as String?;
        if (remoteAvatar != null && remoteAvatar.isNotEmpty) {
          avatar = remoteAvatar;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_key, remoteAvatar);
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      debugPrint('ProfileState.load remote error: $e');
    }

    // 2) ما فيه شي في Firestore؟ نرجع للنسخة المحلية
    final prefs = await SharedPreferences.getInstance();
    avatar = prefs.getString(_key);
    notifyListeners();
  }

  Future<void> setAvatar(String value) async {
    avatar = value;
    notifyListeners();

    // 1) حفظ محلي
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value);

    // 2) حفظ في Firestore (مزامنة)
    try {
      await authService.saveUserData({'avatar': value});
    } catch (e) {
      debugPrint('ProfileState.setAvatar remote error: $e');
    }
  }
}

final ProfileState profileState = ProfileState();
