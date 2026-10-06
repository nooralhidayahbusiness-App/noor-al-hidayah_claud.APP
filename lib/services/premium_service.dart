import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/premium_request.dart';

class PremiumService {
  PremiumService._();
  static final PremiumService instance = PremiumService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('premium_subscriptions');

  // ============================================================
  // PayPal.me
  // ============================================================
  static const String paypalBaseUrl = 'https://www.paypal.me/AbdelRahmen2003';

  static String paypalUrlFor(double amount) {
    final intAmount = amount.toInt();
    return '$paypalBaseUrl/$intAmount';
  }

  // ============================================================
  // إنشاء طلب Premium (من المستخدم)
  // ============================================================
  Future<void> submitRequest({
    required String name,
    required String email,
    required String paypalAccount,
    required String planId,
    required double amount,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('not signed in');

    // امنع طلب ثانٍ أثناء وجود طلب معلّق
    final existing = await _requests.doc(uid).get();
    if (existing.exists) {
      final status = existing.data()?['status'] as String?;
      if (status == 'pending') {
        throw Exception('لديك طلب قيد المراجعة');
      }
    }

    final req = PremiumRequest(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      paypalAccount: paypalAccount.trim(),
      plan: planId,
      amount: amount,
      status: 'pending',
      requestedAt: DateTime.now(),
    );

    await _requests.doc(uid).set(req.toMap());
  }

  // ============================================================
  // طلب المستخدم الحالي
  // ============================================================
  Stream<PremiumRequest?> myRequestStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _requests.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return PremiumRequest.fromMap(snap.id, snap.data()!);
    });
  }

  Future<PremiumRequest?> getMyRequest() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final snap = await _requests.doc(uid).get();
    if (!snap.exists) return null;
    return PremiumRequest.fromMap(snap.id, snap.data()!);
  }

  /// حذف الطلب (بعد الرفض — المستخدم يبدأ من جديد)
  Future<void> deleteMyRequest() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _requests.doc(uid).delete();
  }

  // ============================================================
  // للمالك: قائمة الطلبات المعلقة
  // ============================================================
  Stream<List<PremiumRequest>> pendingRequestsStream() {
    return _requests
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => PremiumRequest.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      return list;
    });
  }

  Future<int> pendingCount() async {
    try {
      final snap = await _requests
          .where('status', isEqualTo: 'pending')
          .get();
      return snap.docs.length;
    } catch (_) {
      return 0;
    }
  }

  // ============================================================
  // للمالك: الموافقة
  // ============================================================
  Future<void> approveRequest(PremiumRequest req) async {
    final myEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final now = DateTime.now();
    final expiresAt = now.add(Duration(days: req.daysForPlan));

    // 1) فعّل Premium في users/{uid}
    await _db.collection('users').doc(req.uid).set({
      'profile': {
        'premium': {
          'active': true,
          'plan': req.plan,
          'amount': req.amount,
          'startedAt': Timestamp.fromDate(now),
          'expiresAt': Timestamp.fromDate(expiresAt),
          'approvedBy': myEmail,
        }
      }
    }, SetOptions(merge: true));

    // 2) حدّث الطلب
    await _requests.doc(req.uid).update({
      'status': 'approved',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': myEmail,
    });
  }

  // ============================================================
  // للمالك: الرفض
  // ============================================================
  Future<void> rejectRequest(PremiumRequest req) async {
    final myEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    await _requests.doc(req.uid).update({
      'status': 'rejected',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': myEmail,
    });
  }

  // ============================================================
  // فحص هل Premium نشط لمستخدم
  // ============================================================
  static bool isActive({
    required bool premiumActive,
    required DateTime? expiresAt,
  }) {
    if (!premiumActive) return false;
    if (expiresAt == null) return false;
    return expiresAt.isAfter(DateTime.now());
  }

  /// الأيام المتبقية
  static int daysRemaining(DateTime? expiresAt) {
    if (expiresAt == null) return 0;
    final diff = expiresAt.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  // ============================================================
  // للمالك: تجديد/إلغاء Premium يدوياً
  // ============================================================
  Future<void> extendPremium({
    required String uid,
    required int days,
  }) async {
    final ref = _db.collection('users').doc(uid);
    final snap = await ref.get();
    final profile = (snap.data()?['profile'] as Map?) ?? {};
    final premium = (profile['premium'] as Map?) ?? {};

    final currentExpiry = (premium['expiresAt'] as Timestamp?)?.toDate();
    final now = DateTime.now();

    // ابدأ من التاريخ الأبعد (الآن أو الانتهاء الحالي)
    final base = (currentExpiry != null && currentExpiry.isAfter(now))
        ? currentExpiry
        : now;
    final newExpiry = base.add(Duration(days: days));

    await ref.set({
      'profile': {
        'premium': {
          'active': true,
          'expiresAt': Timestamp.fromDate(newExpiry),
        }
      }
    }, SetOptions(merge: true));
  }

  Future<void> cancelPremium(String uid) async {
    await _db.collection('users').doc(uid).set({
      'profile': {
        'premium': {
          'active': false,
        }
      }
    }, SetOptions(merge: true));
  }

  // ============================================================
  // Helper: بحث عن مستخدم بالإيميل (للمالك)
  // ============================================================
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      final snap = await _db
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return {'uid': doc.id, ...doc.data()};
    } catch (e) {
      debugPrint('findUserByEmail error: $e');
      return null;
    }
  }
}

final premiumService = PremiumService.instance;
