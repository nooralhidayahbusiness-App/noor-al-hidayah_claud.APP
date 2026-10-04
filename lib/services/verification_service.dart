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

// ============================================================
// Photo Update Request Model
// ============================================================
class PhotoUpdateRequest {
  final String uid;
  final String email;
  final String name;
  final String oldPhotoBase64;
  final String newPhotoBase64;
  final int requestedAt;
  final String status;

  const PhotoUpdateRequest({
    required this.uid,
    required this.email,
    required this.name,
    required this.oldPhotoBase64,
    required this.newPhotoBase64,
    required this.requestedAt,
    required this.status,
  });

  factory PhotoUpdateRequest.fromMap(Map<String, dynamic> m) {
    return PhotoUpdateRequest(
      uid: (m['uid'] as String?) ?? '',
      email: (m['email'] as String?) ?? '',
      name: (m['name'] as String?) ?? '',
      oldPhotoBase64: (m['oldPhotoBase64'] as String?) ?? '',
      newPhotoBase64: (m['newPhotoBase64'] as String?) ?? '',
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

  // ============================================================
  // VERIFICATION (طلب التوثيق الأصلي)
  // ============================================================
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

  Future<void> approve({
    required String targetUid,
    required String type,
  }) async {
    final myEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    String photoBase64 = '';
    try {
      final reqSnap = await _db
          .collection('verification_requests')
          .doc(targetUid)
          .get();
      photoBase64 = (reqSnap.data()?['photoBase64'] as String?) ?? '';
    } catch (_) {}

    final Map<String, dynamic> profileData = {
      'verified': true,
      'verifiedType': type,
      'verifiedAt': DateTime.now().millisecondsSinceEpoch,
      'verifiedBy': myEmail,
      'photoMode': 'custom',
    };
    if (photoBase64.isNotEmpty) {
      profileData['photoBase64'] = photoBase64;
      profileData['customPhotoBase64'] = photoBase64;
    }

    await _db.collection('users').doc(targetUid).set({
      'profile': profileData,
    }, SetOptions(merge: true));

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
        'customPhotoBase64': FieldValue.delete(),
        'photoMode': 'symbol',
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

  // ============================================================
  // PHOTO UPDATE (للموثقين فقط)
  // ============================================================
  Future<bool> hasPendingPhotoChange() async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      final snap = await _db
          .collection('photo_update_requests')
          .doc(uid)
          .get();
      if (!snap.exists) return false;
      final status = snap.data()?['status'] as String?;
      return status == 'pending';
    } catch (_) {
      return false;
    }
  }

  /// هل مرت 72 ساعة من آخر تغيير صورة؟
  Future<bool> canChangePhoto() async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      final snap = await _db.collection('users').doc(uid).get();
      final profile = (snap.data()?['profile'] as Map?) ?? {};
      final lastChange = profile['lastPhotoChangeAt'];
      if (lastChange == null) return true;
      final ts = (lastChange as dynamic).toInt() as int;
      final lastDate =
          DateTime.fromMillisecondsSinceEpoch(ts);
      final diff = DateTime.now().difference(lastDate);
      return diff.inHours >= 72;
    } catch (_) {
      return true;
    }
  }

  /// الوقت المتبقي للتغيير التالي (بالساعات)
  Future<int> hoursUntilNextPhotoChange() async {
    final uid = _uid;
    if (uid == null) return 0;
    try {
      final snap = await _db.collection('users').doc(uid).get();
      final profile = (snap.data()?['profile'] as Map?) ?? {};
      final lastChange = profile['lastPhotoChangeAt'];
      if (lastChange == null) return 0;
      final ts = (lastChange as dynamic).toInt() as int;
      final lastDate = DateTime.fromMillisecondsSinceEpoch(ts);
      final diff = DateTime.now().difference(lastDate);
      final remain = 72 - diff.inHours;
      return remain > 0 ? remain : 0;
    } catch (_) {
      return 0;
    }
  }

  /// للموثق: يرفع طلب تغيير صورة
  Future<void> submitPhotoChangeRequest({
    required String oldPhotoBase64,
    required String newPhotoBase64,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('not signed in');
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final userSnap = await _db.collection('users').doc(uid).get();
    final profile = (userSnap.data()?['profile'] as Map?) ?? {};
    final name = (profile['name'] as String?) ?? 'User';

    await _db.collection('photo_update_requests').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'oldPhotoBase64': oldPhotoBase64,
      'newPhotoBase64': newPhotoBase64,
      'requestedAt': DateTime.now().millisecondsSinceEpoch,
      'status': 'pending',
    });
  }

  Future<List<PhotoUpdateRequest>> loadPendingPhotoUpdates() async {
    try {
      final snap = await _db
          .collection('photo_update_requests')
          .where('status', isEqualTo: 'pending')
          .get();
      final list = snap.docs
          .map((d) => PhotoUpdateRequest.fromMap(d.data()))
          .toList();
      list.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      return list;
    } catch (e) {
      debugPrint('loadPendingPhotoUpdates error: $e');
      return [];
    }
  }

  Future<int> pendingPhotoUpdatesCount() async {
    try {
      final snap = await _db
          .collection('photo_update_requests')
          .where('status', isEqualTo: 'pending')
          .get();
      return snap.docs.length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> approvePhotoChange({required String targetUid}) async {
    final myEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final reqSnap = await _db
        .collection('photo_update_requests')
        .doc(targetUid)
        .get();
    if (!reqSnap.exists) throw Exception('Request not found');
    final newPhoto = (reqSnap.data()?['newPhotoBase64'] as String?) ?? '';

    await _db.collection('users').doc(targetUid).set({
      'profile': {
        'customPhotoBase64': newPhoto,
        'photoBase64': newPhoto,
        'photoMode': 'custom',
        'lastPhotoChangeAt': DateTime.now().millisecondsSinceEpoch,
      }
    }, SetOptions(merge: true));

    await _db
        .collection('photo_update_requests')
        .doc(targetUid)
        .set({
      'status': 'approved',
      'reviewedAt': DateTime.now().millisecondsSinceEpoch,
      'reviewedBy': myEmail,
    }, SetOptions(merge: true));
  }

  Future<void> rejectPhotoChange({required String targetUid}) async {
    final myEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    await _db
        .collection('photo_update_requests')
        .doc(targetUid)
        .set({
      'status': 'rejected',
      'reviewedAt': DateTime.now().millisecondsSinceEpoch,
      'reviewedBy': myEmail,
    }, SetOptions(merge: true));
  }

  // ============================================================
  // للمستخدم غير الموثق — تغيير فوري
  // ============================================================
  Future<void> applyPhotoChangeImmediate({
    required String? customPhotoBase64,
    required String photoMode,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('not signed in');

    await _db.collection('users').doc(uid).set({
      'profile': {
        'customPhotoBase64': customPhotoBase64 ?? '',
        'photoMode': photoMode,
        'lastPhotoChangeAt': DateTime.now().millisecondsSinceEpoch,
      }
    }, SetOptions(merge: true));
  }
}

final verificationService = VerificationService.instance;
