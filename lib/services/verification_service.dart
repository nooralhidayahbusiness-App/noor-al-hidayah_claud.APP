import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class VerificationRequest {
  final String uid;
  final String email;
  final String name;
  final String gender;
  final String photoBase64;
  final int requestedAt;
  final String status;

  const VerificationRequest({
    required this.uid,
    required this.email,
    required this.name,
    required this.gender,
    required this.photoBase64,
    required this.requestedAt,
    required this.status,
  });

  factory VerificationRequest.fromMap(Map<String, dynamic> m) {
    return VerificationRequest(
      uid: (m['uid'] as String?) ?? '',
      email: (m['email'] as String?) ?? '',
      name: (m['name'] as String?) ?? '',
      gender: (m['gender'] as String?) ?? '',
      photoBase64: (m['photoBase64'] as String?) ?? '',
      requestedAt: (m['requestedAt'] as num?)?.toInt() ?? 0,
      status: (m['status'] as String?) ?? 'pending',
    );
  }

  DateTime get requestedDate =>
      DateTime.fromMillisecondsSinceEpoch(requestedAt);
}

class VerificationService {
  VerificationService._();
  static final VerificationService instance = VerificationService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> submitRequest({
    required String photoBase64,
    required String name,
    required String gender,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('not signed in');
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    await _db.collection('verification_requests').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'gender': gender,
      'photoBase64': photoBase64,
      'requestedAt': DateTime.now().millisecondsSinceEpoch,
      'status': 'pending',
    });
  }

  Future<bool> hasPendingRequest() async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      final snap =
          await _db.collection('verification_requests').doc(uid).get();
      if (!snap.exists) return false;
      final status = snap.data()?['status'] as String?;
      return status == 'pending';
    } catch (_) {
      return false;
    }
  }

  Future<List<VerificationRequest>> loadPendingRequests() async {
    try {
      final snap = await _db
          .collection('verification_requests')
          .where('status', isEqualTo: 'pending')
          .get();

      final list = snap.docs
          .map((d) => VerificationRequest.fromMap(d.data()))
          .toList();

      list.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      return list;
    } catch (e) {
      debugPrint('loadPendingRequests error: $e');
      return [];
    }
  }

  Future<int> pendingCount() async {
    try {
      final snap = await _db
          .collection('verification_requests')
          .where('status', isEqualTo: 'pending')
          .get();
      return snap.docs.length;
    } catch (_) {
      return 0;
    }
  }

  /// الموافقة — ينسخ الصورة أيضاً إلى ملف المستخدم.
  Future<void> approve({
    required String targetUid,
    required String type,
  }) async {
    final myEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    // 1) اجلب صورة الطلب
    String photoBase64 = '';
    try {
      final reqSnap = await _db
          .collection('verification_requests')
          .doc(targetUid)
          .get();
      photoBase64 = (reqSnap.data()?['photoBase64'] as String?) ?? '';
    } catch (_) {}

    // 2) حدّث ملف المستخدم (verifiedType + الصورة)
    final Map<String, dynamic> profileData = {
      'verified': true,
      'verifiedType': type,
      'verifiedAt': DateTime.now().millisecondsSinceEpoch,
      'verifiedBy': myEmail,
    };
    if (photoBase64.isNotEmpty) {
      profileData['photoBase64'] = photoBase64;
    }

    await _db.collection('users').doc(targetUid).set({
      'profile': profileData,
    }, SetOptions(merge: true));

    // 3) حدّث الطلب
    await _db
        .collection('verification_requests')
        .doc(targetUid)
        .set({
      'status': type == 'me' ? 'approved_me' : 'approved_user',
      'reviewedAt': DateTime.now().millisecondsSinceEpoch,
      'reviewedBy': myEmail,
    }, SetOptions(merge: true));
  }

  Future<void> reject({required String targetUid}) async {
    final myEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    await _db
        .collection('verification_requests')
        .doc(targetUid)
        .set({
      'status': 'rejected',
      'reviewedAt': DateTime.now().millisecondsSinceEpoch,
      'reviewedBy': myEmail,
    }, SetOptions(merge: true));
  }

  Future<void> revoke({required String targetUid}) async {
    await _db.collection('users').doc(targetUid).set({
      'profile': {
        'verified': false,
        'verifiedType': 'none',
        'photoBase64': FieldValue.delete(),
      }
    }, SetOptions(merge: true));

    await _db
        .collection('verification_requests')
        .doc(targetUid)
        .set({
      'status': 'rejected',
      'reviewedAt': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }
}

final verificationService = VerificationService.instance;
