import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/community_notification.dart';

class CommunityNotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _db.collection('notifications').doc(uid).collection('items');

  /// Stream إشعارات المستخدم (الأحدث أولاً)
  Stream<List<CommunityNotification>> stream(String uid) {
    return _items(uid).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => CommunityNotification.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// عدد الإشعارات غير المقروءة
  Stream<int> unreadCountStream(String uid) {
    return _items(uid).snapshots().map((snap) {
      return snap.docs
          .where((d) => d.data()['isRead'] != true)
          .length;
    });
  }

  /// إنشاء إشعار (يُستخدم من follow_service وغيره)
  Future<void> create({
    required String toUid,
    required String type,
    required String fromUid,
    required String fromName,
    required String fromAvatar,
    required bool fromVerified,
    String? targetId,
  }) async {
    // لا ترسل إشعاراً لنفسك
    if (toUid == fromUid) return;

    final ref = _items(toUid).doc();
    await ref.set({
      'type': type,
      'fromUid': fromUid,
      'fromName': fromName,
      'fromAvatar': fromAvatar,
      'fromVerified': fromVerified,
      'targetId': targetId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// تحديد الكل كمقروء
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

  /// حذف إشعار واحد
  Future<void> deleteOne({
    required String uid,
    required String notifId,
  }) async {
    await _items(uid).doc(notifId).delete();
  }

  /// حذف كل الإشعارات
  Future<void> clearAll(String uid) async {
    final snap = await _items(uid).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
