import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // OneSignal App ID (public — safe to hardcode)
  // ============================================================
  static const String _oneSignalAppId = '4e7862a1-4191-4788-a703-72a3fea3d12d';

  bool _initialized = false;

  // ============================================================
  // التهيئة (تُستدعى مرة واحدة من main.dart)
  // ============================================================
  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) return; // OneSignal على الويب يحتاج VAPID — مؤجل
    _initialized = true;

    try {
      // 1) إعداد مستوى تسجيل الأخطاء
      OneSignal.Debug.setLogLevel(OSLogLevel.warn);

      // 2) تهيئة OneSignal
      OneSignal.initialize(_oneSignalAppId);

      // 3) طلب إذن الإشعارات
      await OneSignal.Notifications.requestPermission(true);

      // 4) عند تسجيل الدخول، اربط المستخدم بـ OneSignal
      OneSignal.login(FirebaseAuth.instance.currentUser?.uid ?? 'guest');

      // 5) راقب تغيّر subscription ID (يُستخدم لحفظ التوكن في Firestore)
      OneSignal.User.pushSubscription.addObserver((state) {
        final subId = OneSignal.User.pushSubscription.id;
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (subId != null && uid != null) {
          _saveSubscription(uid, subId);
        }
      });

      // 6) راقب الإشعارات المستلمة أثناء فتح التطبيق
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        debugPrint('OneSignal foreground: ${event.notification.title}');
      });

      // 7) عند الضغط على إشعار فتح التطبيق
      OneSignal.Notifications.addClickListener((event) {
        debugPrint('OneSignal clicked: ${event.notification.additionalData}');
      });
    } catch (e) {
      debugPrint('pushService.init error: $e');
    }
  }

  // ============================================================
  // ربط المستخدم الحالي بـ OneSignal (يُستدعى بعد تسجيل الدخول)
  // ============================================================
  Future<void> saveTokenForCurrentUser() async {
    if (kIsWeb) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      // ربط المستخدم في OneSignal
      OneSignal.login(uid);

      // حفظ subscription ID في Firestore
      final subId = OneSignal.User.pushSubscription.id;
      if (subId != null) {
        await _saveSubscription(uid, subId);
      }
    } catch (e) {
      debugPrint('saveTokenForCurrentUser error: $e');
    }
  }

  Future<void> _saveSubscription(String uid, String subId) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('onesignalSubs')
          .doc(subId)
          .set({
        'subId': subId,
        'platform': defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('saveSubscription error: $e');
    }
  }

  // ============================================================
  // فصل المستخدم (يُستدعى قبل signOut)
  // ============================================================
  Future<void> removeCurrentToken() async {
    if (kIsWeb) return;
    try {
      OneSignal.logout();
    } catch (e) {
      debugPrint('removeToken error: $e');
    }
  }
}

final pushService = PushService.instance;
