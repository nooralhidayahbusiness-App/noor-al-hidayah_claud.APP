import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/comment.dart';

class CommunityService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream المنشورات مع أولوية Premium (ترتيب: Premium أولاً ثم الأحدث)
  static Stream<List<Post>> postsStream({int limit = 50}) {
    return _db
        .collection('posts')
        .where('isDeleted', isEqualTo: false)
        .orderBy('isGlobalPin', descending: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snap) async {
      final posts = snap.docs.map((d) => Post.fromDoc(d)).toList();

      // جلب حالة Premium لكل ناشر (مرة واحدة لكل uid)
      final uids = posts.map((p) => p.uid).toSet().toList();
      final premiumMap = <String, bool>{};
      for (final uid in uids) {
        try {
          final userDoc = await _db.collection('users').doc(uid).get();
          final data = userDoc.data();
          final premium = (data?['profile']?['premium'] ?? {}) as Map<String, dynamic>;
          premiumMap[uid] = premium['active'] == true;
        } catch (_) {
          premiumMap[uid] = false;
        }
      }

      // ترتيب: Premium أولاً (بعد isGlobalPin) ثم الأحدث
      posts.sort((a, b) {
        final aPremium = premiumMap[a.uid] == true;
        final bPremium = premiumMap[b.uid] == true;
        if (aPremium != bPremium) return bPremium ? 1 : -1;
        return b.createdAt.compareTo(a.createdAt);
      });

      return posts;
    });
  }

  /// إضافة منشور (مع دعم منشور أطول لـ Premium)
  static Future<void> createPost({
    required String uid,
    required String userName,
    required String userAvatar,
    required String? userPhotoBase64,
    required bool userVerified,
    required String userVerifiedType,
    required List<String> userBadges,
    required String text,
    bool isPremium = false,
  }) async {
    final maxLen = isPremium ? 1000 : 500;
    if (text.length > maxLen) {
      throw Exception('النص أطول من الحد المسموح ($maxLen حرف)');
    }

    await _db.collection('posts').add({
      'uid': uid,
      'userName': userName,
      'userAvatar': userAvatar,
      'userPhotoBase64': userPhotoBase64,
      'userVerified': userVerified,
      'userVerifiedType': userVerifiedType,
      'userBadges': userBadges,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'editedAt': null,
      'likes': [],
      'likesCount': 0,
      'commentsCount': 0,
      'repostsCount': 0,
      'repostOf': null,
      'originalAuthorUid': null,
      'originalAuthorName': null,
      'originalAuthorAvatar': null,
      'isPinned': false,
      'isGlobalPin': false,
      'isDeleted': false,
      'mentions': [],
      'hashtags': [],
    });
  }

  /// تثبيت منشور (مع دعم 3 منشورات لـ Premium)
  static Future<void> togglePin({
    required String postId,
    required String uid,
    required bool isPremium,
  }) async {
    final postRef = _db.collection('posts').doc(postId);
    final postDoc = await postRef.get();
    final data = postDoc.data();
    if (data == null) return;

    final currentlyPinned = data['isPinned'] == true;

    if (!currentlyPinned) {
      // عدّ المنشورات المثبتة حالياً
      final pinnedSnap = await _db
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .where('isPinned', isEqualTo: true)
          .get();

      final maxPins = isPremium ? 3 : 1;
      if (pinnedSnap.docs.length >= maxPins) {
        throw Exception('يمكنك تثبيت $maxPins منشور فقط');
      }
    }

    await postRef.update({'isPinned': !currentlyPinned});
  }

  /// إضافة تعليق
  static Future<void> addComment({
    required String postId,
    required String uid,
    required String userName,
    required String userAvatar,
    required String? userPhotoBase64,
    required bool userVerified,
    required String userVerifiedType,
    required List<String> userBadges,
    required String text,
  }) async {
    if (text.length > 300) throw Exception('التعليق طويل جداً');
    await _db.collection('posts').doc(postId).collection('comments').add({
      'uid': uid,
      'userName': userName,
      'userAvatar': userAvatar,
      'userPhotoBase64': userPhotoBase64,
      'userVerified': userVerified,
      'userVerifiedType': userVerifiedType,
      'userBadges': userBadges,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'editedAt': null,
      'likes': [],
      'likesCount': 0,
      'isDeleted': false,
    });
    await _db.collection('posts').doc(postId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  /// إعجاب / إلغاء إعجاب
  static Future<void> toggleLike({
    required String postId,
    required String uid,
  }) async {
    final ref = _db.collection('posts').doc(postId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) return;
      final likes = List<String>.from(data['likes'] ?? []);
      if (likes.contains(uid)) {
        likes.remove(uid);
      } else {
        likes.add(uid);
      }
      tx.update(ref, {
        'likes': likes,
        'likesCount': likes.length,
      });
    });
  }

  /// حذف منشور (soft delete)
  static Future<void> deletePost({
    required String postId,
    required String uid,
  }) async {
    final ref = _db.collection('posts').doc(postId);
    final doc = await ref.get();
    if (doc.data()?['uid'] != uid) return;
    await ref.update({'isDeleted': true});
  }

  /// جلب تعليقات منشور
  static Stream<List<Comment>> commentsStream(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Comment.fromDoc(d)).toList());
  }
}
