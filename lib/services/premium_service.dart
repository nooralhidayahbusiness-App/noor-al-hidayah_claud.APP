import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/premium_request.dart';

class PremiumService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// فحص سريع: هل المستخدم بريميوم نشط الآن؟
  static Future<bool> isUserPremium(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final data = doc.data();
      if (data == null) return false;
      final premium = (data['profile']?['premium'] ?? {}) as Map<String, dynamic>;
      final active = premium['active'] == true;
      if (!active) return false;
      final expiresAt = premium['expiresAt'];
      if (expiresAt is Timestamp) {
        return expiresAt.toDate().isAfter(DateTime.now());
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// جلب بيانات البريميوم كاملة (للاستخدام في الشاشات)
  static Future<Map<String, dynamic>?> getPremiumData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final data = doc.data();
      return (data?['profile']?['premium'] ?? null) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  /// إرسال طلب اشتراك جديد (pending)
  static Future<void> submitRequest({
    required String uid,
    required String name,
    required String email,
    required String paypalAccount,
    required String plan,
    required double amount,
  }) async {
    await _db.collection('premium_subscriptions').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'paypalAccount': paypalAccount,
      'plan': plan,
      'amount': amount,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

  /// للمالك: الموافقة على الطلب وتفعيل البريميوم
  static Future<void> approveRequest({
    required String uid,
    required String plan,
    required double amount,
    required String approvedBy,
  }) async {
    final now = DateTime.now();
    DateTime expiresAt;
    switch (plan) {
      case 'quarterly':
        expiresAt = DateTime(now.year, now.month + 3, now.day);
        break;
      case 'yearly':
        expiresAt = DateTime(now.year + 1, now.month, now.day);
        break;
      case 'trial':
        expiresAt = now.add(const Duration(days: 3));
        break;
      case 'monthly':
      default:
        expiresAt = DateTime(now.year, now.month + 1, now.day);
    }

    // 1) تحديث حالة الطلب
    await _db.collection('premium_subscriptions').doc(uid).update({
      'status': 'approved',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': approvedBy,
    });

    // 2) تفعيل البريميوم في users/{uid}
    await _db.collection('users').doc(uid).update({
      'profile.premium': {
        'active': true,
        'plan': plan,
        'amount': amount,
        'startedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'approvedBy': approvedBy,
      },
      // 3) إضافة 10,000 نقطة شهرياً (مرة عند الموافقة)
      'stats.points': FieldValue.increment(10000),
    });

    // 4) إرسال إشعار premium_approved
    await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .add({
      'type': 'premium_approved',
      'fromUid': approvedBy,
      'fromName': 'الإدارة',
      'fromAvatar': 'owner',
      'fromVerified': true,
      'fromVerifiedType': 'owner',
      'targetId': '',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// للمالك: رفض الطلب
  static Future<void> rejectRequest({
    required String uid,
    required String approvedBy,
  }) async {
    await _db.collection('premium_subscriptions').doc(uid).update({
      'status': 'rejected',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': approvedBy,
    });

    await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .add({
      'type': 'premium_rejected',
      'fromUid': approvedBy,
      'fromName': 'الإدارة',
      'fromAvatar': 'owner',
      'fromVerified': true,
      'fromVerifiedType': 'owner',
      'targetId': '',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// Stream لحالة الطلب (لمتابعة pending/approved/rejected)
  static Stream<PremiumRequest?> requestStream(String uid) {
    return _db
        .collection('premium_subscriptions')
        .doc(uid)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      return PremiumRequest.fromDoc(snap);
    });
  }
}
