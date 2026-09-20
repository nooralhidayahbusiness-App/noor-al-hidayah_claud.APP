import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The chosen profile picture ('man' or 'woman'), saved on the device.
class ProfileState extends ChangeNotifier {
  static const _key = 'profile_avatar';

  String? avatar;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    avatar = prefs.getString(_key);
    notifyListeners();
  }

  Future<void> setAvatar(String value) async {
    avatar = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value);
  }
}

final ProfileState profileState = ProfileState();
