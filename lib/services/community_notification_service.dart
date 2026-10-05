import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/community_notification.dart';
import '../models/user_brief.dart';

class CommunityNotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _db.collection('notifications').doc(uid).collection('items');

  Stream<List<CommunityNotification>> stream(String uid) {
    return _items(uid).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => CommunityNotification.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<int> unreadCountStream(String uid) {
    return _items(uid).snapshots().map((snap) {
      return snap.docs.where((d) => d.data()['isRead'] != true).length;
    });
  }

  Future<void> createFromUser({
    required String toUid,
    required String type,
    required String fromUid,
    String? targetId,
  }) async {
    if (toUid == fromUid || toUid.isEmpty || fromUid.isEmpty) return;

    try {
      final userSnap = await _db.collection('users').doc(fromUid).get();
      if (!userSnap.exists) return;

      final data = userSnap.data() ?? {};
      final profile =
          (data['profile'] as Map<String, dynamic>?) ?? const {};
      final rawName = (profile['name'] as String?)?.trim();
      final name = (rawName == null || rawName.isEmpty) ? 'User' : rawName;
      final avatar = (data['avatar'] as String?) ?? 'man';

      final fromEmail = (data['email'] as String?) ?? '';
      final isOwnerEmail = kOwnerEmails.contains(fromEmail.toLowerCase());

      final verified =
          isOwnerEmail || ((profile['verified'] as bool?) ?? false);
      final verifiedType = isOwnerEmail
          ? 'owner'
          : ((profile['verifiedType'] as String?) ?? 'none');

      final ref = _items(toUid).doc();
      await ref.set({
        'type': type,
        'fromUid': fromUid,
        'fromName': name,
        'fromAvatar': avatar,
        'fromVerified': verified,
        'fromVerifiedType': verifiedType,
        'targetId': targetId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (_) {}
  }

  Future<void> create({
    required String toUid,
    required String type,
    required String fromUid,
    required String fromName,
    required String fromAvatar,
    required bool fromVerified,
    String fromVerifiedType = 'none',
    String? targetId,
  }) async {
    if (toUid == fromUid || toUid.isEmpty || fromUid.isEmpty) return;
    final ref = _items(toUid).doc();
    await ref.set({
      'type': type,
      'fromUid': fromUid,
      'fromName': fromName,
      'fromAvatar': fromAvatar,
      'fromVerified': fromVerified,
      'fromVerifiedType': fromVerifiedType,
      'targetId': targetId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<void> sendFromAdmin({
    required String toUid,
    required String type,
    String? targetId,
    String customTitle = 'الإدارة',
  }) async {
    if (toUid.isEmpty) return;

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    try {
      final ref = _items(toUid).doc();
      await ref.set({
        'type': type,
        'fromUid': currentUid,
        'fromName': customTitle,
        'fromAvatar': 'man',
        'fromVerified': true,
        'fromVerifiedType': 'owner',
        'targetId': targetId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (_) {}
  }

  // ============================================================
  // ✅ إشعار "فيديو جديد" لكل متابعي المالك
  // ============================================================
  Future<void> notifyNewVideo({
    required String videoId,
    required String videoTitle,
    required bool isReel,
  }) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    try {
      // 1) اجلب كل owner UIDs (حسب الإيميلات الأربعة)
      final ownerUids = <String>{};
      for (final email in kOwnerEmails) {
        try {
          final snap = await _db
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
          if (snap.docs.isNotEmpty) {
            ownerUids.add(snap.docs.first.id);
          }
        } catch (_) {}
      }

      if (ownerUids.isEmpty) return;

      // 2) اجمع كل متابعي المالك (بدون تكرار)
      final followerUids = <String>{};
      for (final ownerUid in ownerUids) {
        try {
          final snap = await _db
              .collection('follows')
              .where('followingUid', isEqualTo: ownerUid)
              .get();
          for (final d in snap.docs) {
            final uid = d.data()['followerUid'] as String?;
            if (uid != null && uid != currentUid) {
              followerUids.add(uid);
            }
          }
        } catch (_) {}
      }

      if (followerUids.isEmpty) return;

      // 3) بيانات صاحب المنشور (المالك)
      final userSnap = await _db.collection('users').doc(currentUid).get();
      final data = userSnap.data() ?? {};
      final profile = (data['profile'] as Map?) ?? {};
      final rawName = (profile['name'] as String?)?.trim();
      final name = (rawName == null || rawName.isEmpty) ? 'Noor Al-Hidayah' : rawName;
      final avatar = (data['avatar'] as String?) ?? 'man';

      // 4) أنشئ الإشعارات (دفعات 400)
      final list = followerUids.toList();
      const batchSize = 400;
      for (var i = 0; i < list.length; i += batchSize) {
        final batch = _db.batch();
        final end = (i + batchSize > list.length) ? list.length : i + batchSize;
        for (var j = i; j < end; j++) {
          final toUid = list[j];
          final ref = _items(toUid).doc();
          batch.set(ref, {
            'type': isReel ? 'new_reel' : 'new_video',
            'fromUid': currentUid,
            'fromName': name,
            'fromAvatar': avatar,
            'fromVerified': true,
            'fromVerifiedType': 'owner',
            'targetId': videoId,
            'customTitle': videoTitle,
            'createdAt': FieldValue.serverTimestamp(),
            'isRead': false,
          });
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  Future<void> markAllRead(String uid) async {
    final snap = await _items(uid).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      if (doc.data()['isRead'] != true) {
        batch.update(doc.reference, {'isRead': true});
      }
    }
    await batch.commit();
  }

  Future<void> deleteOne({
    required String uid,
    required String notifId,
  }) async {
    await _items(uid).doc(notifId).delete();
  }

  Future<void> clearAll(String uid) async {
    final snap = await _items(uid).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
