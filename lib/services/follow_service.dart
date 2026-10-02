import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_brief.dart';

class FollowService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _follows =>
      _db.collection('follows');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  // ============================================================
  // ID فريد لكل علاقة متابعة
  // ============================================================
  String _docId(String followerUid, String followingUid) =>
      '${followerUid}_$followingUid';

  // ============================================================
  // المتابعة
  // ============================================================
  Future<void> follow({
    required String followerUid,
    required String followingUid,
  }) async {
    if (followerUid == followingUid) {
      throw ArgumentError('لا يمكن متابعة نفسك');
    }
    final ref = _follows.doc(_docId(followerUid, followingUid));
    // set مع merge عشان ما يعمل overwrite لو موجود
    await ref.set({
      'followerUid': followerUid,
      'followingUid': followingUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unfollow({
    required String followerUid,
    required String followingUid,
  }) async {
    await _follows.doc(_docId(followerUid, followingUid)).delete();
  }

  Future<void> toggleFollow({
    required String followerUid,
    required String followingUid,
  }) async {
    final isFollowing = await checkIsFollowing(
      followerUid: followerUid,
      followingUid: followingUid,
    );
    if (isFollowing) {
      await unfollow(
        followerUid: followerUid,
        followingUid: followingUid,
      );
    } else {
      await follow(
        followerUid: followerUid,
        followingUid: followingUid,
      );
    }
  }

  // ============================================================
  // هل A يتابع B؟
  // ============================================================
  Future<bool> checkIsFollowing({
    required String followerUid,
    required String followingUid,
  }) async {
    final snap =
        await _follows.doc(_docId(followerUid, followingUid)).get();
    return snap.exists;
  }

  /// Stream — يتحدّث تلقائياً
  Stream<bool> isFollowingStream({
    required String followerUid,
    required String followingUid,
  }) {
    return _follows
        .doc(_docId(followerUid, followingUid))
        .snapshots()
        .map((snap) => snap.exists);
  }

  // ============================================================
  // قوائم المتابعين / المتابَعين (Stream<List<UserBrief>>)
  // ============================================================
  Stream<List<UserBrief>> followersStream(String uid) {
    return _follows
        .where('followingUid', isEqualTo: uid)
        .snapshots()
        .asyncMap((snap) async {
      final uids = snap.docs
          .map((d) => d.data()['followerUid'] as String?)
          .whereType<String>()
          .toList();
      return _fetchUsers(uids);
    });
  }

  Stream<List<UserBrief>> followingStream(String uid) {
    return _follows
        .where('followerUid', isEqualTo: uid)
        .snapshots()
        .asyncMap((snap) async {
      final uids = snap.docs
          .map((d) => d.data()['followingUid'] as String?)
          .whereType<String>()
          .toList();
      return _fetchUsers(uids);
    });
  }

  // ============================================================
  // العدّادات (Stream<int>)
  // ============================================================
  Stream<int> followersCountStream(String uid) {
    return _follows
        .where('followingUid', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Stream<int> followingCountStream(String uid) {
    return _follows
        .where('followerUid', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ============================================================
  // جلب دفعة users من uids
  // ============================================================
  Future<List<UserBrief>> _fetchUsers(List<String> uids) async {
    if (uids.isEmpty) return const [];

    // Firestore whereIn max 10 → نقسم
    final result = <UserBrief>[];
    const chunkSize = 10;
    for (var i = 0; i < uids.length; i += chunkSize) {
      final chunk = uids.sublist(
        i,
        i + chunkSize > uids.length ? uids.length : i + chunkSize,
      );
      final snap = await _users
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        result.add(UserBrief.fromMap(doc.id, doc.data()));
      }
    }
    return result;
  }

  /// جلب مستخدم واحد
  Future<UserBrief?> getUserBrief(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserBrief.fromMap(uid, snap.data()!);
  }

  /// Stream مستخدم واحد — لشاشة البروفايل
  Stream<UserBrief?> userBriefStream(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserBrief.fromMap(uid, snap.data()!);
    });
  }
}
