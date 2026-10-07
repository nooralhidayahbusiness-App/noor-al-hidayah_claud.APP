import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// ============================================================
// معالج الرسائل في الخلفية
// لازم يكون top-level function + @pragma('vm:entry-point')
// ============================================================
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background: ${message.messageId}');
}

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _initialized = false;

  // ============================================================
  // التهيئة (تُستدعى مرة واحدة من main.dart)
  // ============================================================
  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) return; // FCM على الويب يحتاج VAPID key — مؤجل
    _initialized = true;

    try {
      // 1) سجّل معالج الخلفية
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 2) اطلب الإذن (iOS + Android 13+)
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('FCM permission denied');
        return;
      }

      // 3) راقب تجديد التوكن
      _fcm.onTokenRefresh.listen(_saveToken);

      // 4) رسائل الاستقبال أثناء فتح التطبيق
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('FCM foreground: ${message.notification?.title}');
        // التطبيق يعرض الإشعارات الاجتماعية مباشرة عبر Firestore
      });

      // 5) عند الضغط على إشعار فتح التطبيق
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('FCM opened: ${message.data}');
      });
    } catch (e) {
      debugPrint('pushService.init error: $e');
    }
  }

  // ============================================================
  // حفظ التوكن للمستخدم الحالي (يُستدعى بعد تسجيل الدخول)
  // ============================================================
  Future<void> saveTokenForCurrentUser() async {
    if (kIsWeb) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      await _saveTokenToUid(uid, token);
    } catch (e) {
      debugPrint('saveTokenForCurrentUser error: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _saveTokenToUid(uid, token);
  }

  Future<void> _saveTokenToUid(String uid, String token) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('fcmTokens')
          .doc(token)
          .set({
        'token': token,
        'platform': defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('saveToken error: $e');
    }
  }

  // ============================================================
  // إزالة التوكن (يُستدعى قبل signOut)
  // ============================================================
  Future<void> removeCurrentToken() async {
    if (kIsWeb) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      await _db
          .collection('users')
          .doc(uid)
          .collection('fcmTokens')
          .doc(token)
          .delete();
    } catch (e) {
      debugPrint('removeToken error: $e');
    }
  }
}

final pushService = PushService.instance;
