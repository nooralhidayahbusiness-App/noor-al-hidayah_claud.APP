import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_brief.dart';
import 'community_notification_service.dart';

class FollowService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CommunityNotificationService _notifService =
      CommunityNotificationService();

  CollectionReference<Map<String, dynamic>> get _follows =>
      _db.collection('follows');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  String _docId(String followerUid, String followingUid) =>
      '${followerUid}_$followingUid';

  Future<void> follow({
    required String followerUid,
    required String followingUid,
  }) async {
    if (followerUid == followingUid) {
      throw ArgumentError('لا يمكن متابعة نفسك');
    }
    final ref = _follows.doc(_docId(followerUid, followingUid));
    await ref.set({
      'followerUid': followerUid,
      'followingUid': followingUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    try {
      final me = await getUserBrief(followerUid);
      if (me != null) {
        await _notifService.create(
          toUid: followingUid,
          type: 'follow',
          fromUid: followerUid,
          fromName: me.name,
          fromAvatar: me.avatar,
          fromVerified: me.verified,
          fromVerifiedType: me.verifiedType,
        );
      }
    } catch (_) {}
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

  Future<bool> checkIsFollowing({
    required String followerUid,
    required String followingUid,
  }) async {
    final snap =
        await _follows.doc(_docId(followerUid, followingUid)).get();
    return snap.exists;
  }

  Stream<bool> isFollowingStream({
    required String followerUid,
    required String followingUid,
  }) {
    return _follows
        .doc(_docId(followerUid, followingUid))
        .snapshots()
        .map((snap) => snap.exists);
  }

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

  Future<List<UserBrief>> _fetchUsers(List<String> uids) async {
    if (uids.isEmpty) return const [];

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

  Future<UserBrief?> getUserBrief(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserBrief.fromMap(uid, snap.data()!);
  }

  Stream<UserBrief?> userBriefStream(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserBrief.fromMap(uid, snap.data()!);
    });
  }
}
