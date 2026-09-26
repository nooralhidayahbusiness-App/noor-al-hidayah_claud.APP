import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';

/// حالة الملف الشخصي: الصورة، الاسم، النبذة، خصوصية الحساب.
/// تُحفظ محلياً + في Firestore.
class ProfileState extends ChangeNotifier {
  static const _keyAvatar = 'profile_avatar';
  static const _keyName = 'profile_name';
  static const _keyBio = 'profile_bio';
  static const _keyPublic = 'profile_is_public';

  String? avatar;
  String name = '';
  String bio = '';
  bool isPublic = true;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    // 1) من Firestore
    try {
      if (authService.isSignedIn) {
        final data = await authService.loadUserData();
        if (data != null) {
          // الصورة قد تكون في الجذر (توافق للخلف) أو داخل profile
          avatar = (data['avatar'] as String?) ??
              ((data['profile'] as Map?)?['avatar'] as String?);
          final p = (data['profile'] as Map?) ?? {};
          name = (p['name'] as String?) ?? '';
          bio = (p['bio'] as String?) ?? '';
          isPublic = (p['isPublic'] as bool?) ?? true;

          final prefs = await SharedPreferences.getInstance();
          if (avatar != null) await prefs.setString(_keyAvatar, avatar!);
          await prefs.setString(_keyName, name);
          await prefs.setString(_keyBio, bio);
          await prefs.setBool(_keyPublic, isPublic);
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      debugPrint('ProfileState.load remote error: $e');
    }

    // 2) من الجهاز (خطة بديلة)
    final prefs = await SharedPreferences.getInstance();
    avatar = prefs.getString(_keyAvatar);
    name = prefs.getString(_keyName) ?? '';
    bio = prefs.getString(_keyBio) ?? '';
    isPublic = prefs.getBool(_keyPublic) ?? true;
    notifyListeners();
  }

  Future<void> setAvatar(String value) async {
    avatar = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatar, value);

    try {
      // نحفظها في الجذر وفي profile (توافق + بنية جديدة)
      await authService.saveUserData({'avatar': value});
      await userService.saveProfile();
    } catch (e) {
      debugPrint('ProfileState.setAvatar remote error: $e');
    }
  }

  Future<void> updateProfile({
    String? newName,
    String? newBio,
    bool? newPublic,
  }) async {
    if (newName != null) name = newName;
    if (newBio != null) bio = newBio;
    if (newPublic != null) isPublic = newPublic;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyBio, bio);
    await prefs.setBool(_keyPublic, isPublic);

    try {
      await userService.saveProfile(
        name: name,
        bio: bio,
        isPublic: isPublic,
      );
    } catch (e) {
      debugPrint('ProfileState.updateProfile remote error: $e');
    }
  }
}

final ProfileState profileState = ProfileState();
