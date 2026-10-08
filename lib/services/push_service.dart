import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _oneSignalAppId = '4e7862a1-4191-4788-a703-72a3fea3d12d';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) return;
    _initialized = true;

    try {
      // 1) Logging لتشخيص المشاكل
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      // 2) تهيئة OneSignal
      OneSignal.initialize(_oneSignalAppId);
      debugPrint('OneSignal initialized with app ID');

      // 3) طلب إذن الإشعارات
      final granted = await OneSignal.Notifications.requestPermission(true);
      debugPrint('OneSignal permission granted: $granted');

      // 4) اربط المستخدم الحالي (إن وُجد)
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        OneSignal.login(uid);
        debugPrint('OneSignal logged in as $uid');
      } else {
        OneSignal.login('guest');
        debugPrint('OneSignal logged in as guest');
      }

      // 5) راقب subscription ID
      OneSignal.User.pushSubscription.addObserver((state) {
        final subId = OneSignal.User.pushSubscription.id;
        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        debugPrint('OneSignal sub changed: $subId');
        if (subId != null && currentUid != null) {
          _saveSubscription(currentUid, subId);
        }
      });

      // 6) اعرض الإشعارات حتى لو التطبيق مفتوح
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        debugPrint('OneSignal foreground: ${event.notification.title}');
        // OneSignal يعرضها تلقائياً في الإصدار 5+
      });

      // 7) عند الضغط على إشعار
      OneSignal.Notifications.addClickListener((event) {
        debugPrint('OneSignal clicked: ${event.notification.additionalData}');
      });
    } catch (e) {
      debugPrint('pushService.init error: $e');
    }
  }

  /// ربط المستخدم الحالي بـ OneSignal (يُستدعى بعد تسجيل الدخول)
  Future<void> saveTokenForCurrentUser() async {
    if (kIsWeb) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      OneSignal.login(uid);
      debugPrint('OneSignal re-logged in as $uid');

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
      debugPrint('Saved subscription $subId for user $uid');
    } catch (e) {
      debugPrint('saveSubscription error: $e');
    }
  }

  /// فصل المستخدم عند sign out
  Future<void> removeCurrentToken() async {
    if (kIsWeb) return;
    try {
      OneSignal.logout();
      debugPrint('OneSignal logged out');
    } catch (e) {
      debugPrint('removeToken error: $e');
    }
  }
}

final pushService = PushService.instance;
