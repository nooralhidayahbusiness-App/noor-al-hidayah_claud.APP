import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';

/// حالة الملف الشخصي: الصورة، الاسم، النبذة، خصوصية الحساب.
class ProfileState extends ChangeNotifier {
  static const _keyAvatar = 'profile_avatar';
  static const _keyName = 'profile_name';
  static const _keyBio = 'profile_bio';
  static const _keyPublic = 'profile_is_public';

  String? avatar;
  String name = '';
  String bio = '';
  bool isPublic = true;

  /// الصورة كـ String (base64) — للاستخدام في المنشورات/التعليقات
  String photoBase64 = '';

  /// الصورة كـ Uint8List — للعرض
  Uint8List? photoBytes;

  bool _loaded = false;

  ProfileState() {
    authService.addSignOutHandler(reset);
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    try {
      if (authService.isSignedIn) {
        final uid = authService.currentUser?.uid;
        if (uid == null) return;

        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get(const GetOptions(source: Source.server));

        if (snap.exists) {
          final data = snap.data() ?? {};
          final p = (data['profile'] as Map?) ?? {};

          avatar = (p['gender'] as String?) ??
              (data['avatar'] as String?) ??
              'man';

          name = (p['name'] as String?) ?? '';
          bio = (p['bio'] as String?) ?? '';
          isPublic = (p['isPublic'] as bool?) ?? true;

          // ✅ قراءة الصورة بذكاء
          photoBase64 = '';
          photoBytes = null;

          final photoMode = (p['photoMode'] as String?) ?? 'symbol';
          final customB64 = p['customPhotoBase64'] as String?;
          final verificationB64 = p['photoBase64'] as String?;

          String? chosenB64;
          if (photoMode == 'custom' &&
              customB64 != null &&
              customB64.isNotEmpty) {
            chosenB64 = customB64;
          } else if (verificationB64 != null &&
              verificationB64.isNotEmpty) {
            chosenB64 = verificationB64;
          } else if (customB64 != null && customB64.isNotEmpty) {
            chosenB64 = customB64;
          }

          if (chosenB64 != null && chosenB64.isNotEmpty) {
            photoBase64 = chosenB64;
            try {
              photoBytes = base64Decode(chosenB64);
            } catch (_) {}
          }

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

    final prefs = await SharedPreferences.getInstance();
    avatar = prefs.getString(_keyAvatar);
    name = prefs.getString(_keyName) ?? '';
    bio = prefs.getString(_keyBio) ?? '';
    isPublic = prefs.getBool(_keyPublic) ?? true;
    notifyListeners();
  }

  Future<void> reset() async {
    avatar = null;
    name = '';
    bio = '';
    isPublic = true;
    photoBase64 = '';
    photoBytes = null;
    _loaded = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAvatar);
      await prefs.remove(_keyName);
      await prefs.remove(_keyBio);
      await prefs.remove(_keyPublic);
    } catch (e) {
      debugPrint('ProfileState.reset prefs error: $e');
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

  Future<void> refresh() async {
    _loaded = false;
    await load();
  }
}

final ProfileState profileState = ProfileState();
