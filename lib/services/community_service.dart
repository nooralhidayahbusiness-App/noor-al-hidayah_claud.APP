import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../models/user_brief.dart';
import 'community_notification_service.dart';
import 'premium_service.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CommunityNotificationService _notif = CommunityNotificationService();

  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('posts');

  // ============================================================
  // POSTS
  // ============================================================
  // ✅ تعديل: Premium أولاً في الـ Feed
  Stream<List<Post>> postsStream({int limit = 100}) {
    return _posts.snapshots().asyncMap((snap) async {
      final list = snap.docs
          .map((d) => Post.fromMap(d.id, d.data()))
          .where((p) => !p.isDeleted && !p.isGlobalPin)
          .toList();

      // ✅ جلب حالة Premium لكل ناشر (مرة واحدة لكل uid)
      final uids = list.map((p) => p.uid).toSet().toList();
      final premiumMap = <String, bool>{};
      for (final uid in uids) {
        try {
          final userDoc = await _db.collection('users').doc(uid).get();
          final profile =
              (userDoc.data()?['profile'] as Map?)?.cast<String, dynamic>();
          premiumMap[uid] = PremiumService.isUserPremium(profile);
        } catch (_) {
          premiumMap[uid] = false;
        }
      }

      // ✅ ترتيب: Premium أولاً ثم الأحدث
      list.sort((a, b) {
        final aPremium = premiumMap[a.uid] == true;
        final bPremium = premiumMap[b.uid] == true;
        if (aPremium != bPremium) return bPremium ? 1 : -1;
        return b.createdAt.compareTo(a.createdAt);
      });

      if (list.length > limit) return list.sublist(0, limit);
      return list;
    });
  }

  /// ✅ منشور الترحيب العالمي (إن وُجد)
  Stream<Post?> globalPinnedStream() {
    return _posts
        .where('isGlobalPin', isEqualTo: true)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final d = snap.docs.first;
      return Post.fromMap(d.id, d.data());
    });
  }

  /// ✅ للمالك فقط: تعيين/إلغاء منشور الترحيب العالمي
  Future<void> toggleGlobalPin({
    required String postId,
    required String uid,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('not signed in');
    final email = (user.email ?? '').toLowerCase();
    if (!kOwnerEmails.contains(email)) {
      throw Exception('غير مصرح');
    }

    final ref = _posts.doc(postId);
    final snap = await ref.get();
    if (!snap.exists) throw Exception('المنشور غير موجود');

    final current = snap.data()?['isGlobalPin'] == true;

    if (current) {
      // إلغاء التثبيت العالمي
      await ref.update({'isGlobalPin': false});
      return;
    }

    // إلغاء التثبيت العالمي من أي منشور آخر
    final existing = await _posts
        .where('isGlobalPin', isEqualTo: true)
        .get();
    final batch = _db.batch();
    for (final doc in existing.docs) {
      batch.update(doc.reference, {'isGlobalPin': false});
    }
    batch.update(ref, {'isGlobalPin': true});
    await batch.commit();
  }

  /// Stream منشورات مستخدم معيّن (لصفحة البروفايل)
  Stream<List<Post>> userPostsStream(String uid, {int limit = 100}) {
    return _posts.where('uid', isEqualTo: uid).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => Post.fromMap(d.id, d.data()))
          .where((p) => !p.isDeleted)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (list.length > limit) return list.sublist(0, limit);
      return list;
    });
  }

  Stream<Post?> postStream(String postId) {
    return _posts.doc(postId).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return Post.fromMap(snap.id, data);
    });
  }

  Future<String> createPost({
    required String uid,
    required String userName,
    required String userAvatar,
    required String userPhotoBase64,
    required bool userVerified,
    String userVerifiedType = 'none',
    List<String> userBadges = const [],
    required String text,
    String? repostOf,
    String? originalAuthorUid,
    String? originalAuthorName,
    String? originalAuthorAvatar,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('نص المنشور فارغ');
    }
    if (trimmed.length > 1000) {
      throw ArgumentError('نص المنشور يتجاوز 1000 حرف');
    }

    final mentions = Post.extractMentions(trimmed);
    final hashtags = Post.extractHashtags(trimmed);

    final ref = _posts.doc();
    final post = Post(
      id: ref.id,
      uid: uid,
      userName: userName,
      userAvatar: userAvatar,
      userPhotoBase64: userPhotoBase64,
      userVerified: userVerified,
      userVerifiedType: userVerifiedType,
      userBadges: userBadges,
      text: trimmed,
      createdAt: DateTime.now(),
      repostOf: repostOf,
      originalAuthorUid: originalAuthorUid,
      originalAuthorName: originalAuthorName,
      originalAuthorAvatar: originalAuthorAvatar,
      mentions: mentions,
      hashtags: hashtags,
    );

    await ref.set(post.toMap());

    if (repostOf != null) {
      await _posts.doc(repostOf).update({
        'repostsCount': FieldValue.increment(1),
      });

      if (originalAuthorUid != null &&
          originalAuthorUid.isNotEmpty &&
          originalAuthorUid != uid) {
        await _notif.createFromUser(
          toUid: originalAuthorUid,
          type: 'repost',
          fromUid: uid,
          targetId: repostOf,
        );
      }
    }

    return ref.id;
  }

  Future<void> editPost({
    required String postId,
    required String uid,
    required String newText,
  }) async {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('نص المنشور فارغ');
    }
    if (trimmed.length > 1000) {
      throw ArgumentError('نص المنشور يتجاوز 1000 حرف');
    }

    final ref = _posts.doc(postId);
    final snap = await ref.get();
    if (!snap.exists) throw Exception('المنشور غير موجود');
    if (snap.data()?['uid'] != uid) {
      throw Exception('ما عندك صلاحية تعديل هذا المنشور');
    }

    await ref.update({
      'text': trimmed,
      'editedAt': Timestamp.fromDate(DateTime.now()),
      'mentions': Post.extractMentions(trimmed),
      'hashtags': Post.extractHashtags(trimmed),
    });
  }

  Future<void> deletePost({
    required String postId,
    required String uid,
  }) async {
    final ref = _posts.doc(postId);
    final snap = await ref.get();
    if (!snap.exists) return;
    if (snap.data()?['uid'] != uid) {
      throw Exception('ما عندك صلاحية حذف هذا المنشور');
    }
    await ref.update({'isDeleted': true});
  }

  Future<void> toggleLike({
    required String postId,
    required String uid,
  }) async {
    final ref = _posts.doc(postId);

    String? ownerUid;
    bool didLike = false;

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw Exception('المنشور غير موجود');
      final data = snap.data() ?? {};
      final likes = List<String>.from(data['likes'] ?? const []);
      final hasLiked = likes.contains(uid);
      final currentCount = (data['likesCount'] as int?) ?? likes.length;

      tx.update(ref, {
        'likes': hasLiked
            ? FieldValue.arrayRemove([uid])
            : FieldValue.arrayUnion([uid]),
        'likesCount': hasLiked
            ? (currentCount - 1).clamp(0, 1 << 31)
            : currentCount + 1,
      });

      ownerUid = data['uid'] as String?;
      didLike = !hasLiked;
    });

    if (didLike && ownerUid != null && ownerUid!.isNotEmpty) {
      await _notif.createFromUser(
        toUid: ownerUid!,
        type: 'like',
        fromUid: uid,
        targetId: postId,
      );
    }
  }

  // ✅ تعديل: 3 منشورات مثبتة لـ Premium (1 فقط للعادي)
  Future<void> togglePin({
    required String postId,
    required String uid,
  }) async {
    final ref = _posts.doc(postId);
    final snap = await ref.get();
    if (!snap.exists) throw Exception('المنشور غير موجود');
    final data = snap.data() ?? {};
    if (data['uid'] != uid) {
      throw Exception('ما عندك صلاحية تثبيت هذا المنشور');
    }

    final currentlyPinned = data['isPinned'] == true;

    // إلغاء التثبيت
    if (currentlyPinned) {
      await ref.update({'isPinned': false, 'pinnedAt': null});
      return;
    }

    // ✅ فحص حالة Premium
    final userDoc = await _db.collection('users').doc(uid).get();
    final profile =
        (userDoc.data()?['profile'] as Map?)?.cast<String, dynamic>();
    final isPremium = PremiumService.isUserPremium(profile);
    final maxPins = isPremium ? 3 : 1;

    // جلب المنشورات المثبتة الحالية (باستثناء المنشور الحالي)
    final userPosts = await _posts.where('uid', isEqualTo: uid).get();
    final currentlyPinnedDocs = userPosts.docs
        .where((doc) =>
            doc.id != postId && doc.data()['isPinned'] == true)
        .toList();

    final batch = _db.batch();

    // لو وصلنا الحد الأقصى → إلغاء تثبيت الأقدم
    if (currentlyPinnedDocs.length >= maxPins) {
      // ترتيب حسب pinnedAt (الأقدم أولاً)، الافتراضي سنة 2000
      currentlyPinnedDocs.sort((a, b) {
        final aAt = (a.data()['pinnedAt'] as Timestamp?)?.toDate() ??
            DateTime(2000);
        final bAt = (b.data()['pinnedAt'] as Timestamp?)?.toDate() ??
            DateTime(2000);
        return aAt.compareTo(bAt);
      });

      // إلغاء تثبيت الأقدم (عدد كافٍ)
      final toUnpinCount =
          currentlyPinnedDocs.length - maxPins + 1;
      for (int i = 0; i < toUnpinCount; i++) {
        batch.update(currentlyPinnedDocs[i].reference, {
          'isPinned': false,
          'pinnedAt': null,
        });
      }
    }

    // تثبيت المنشور الحالي + تسجيل الوقت
    batch.update(ref, {
      'isPinned': true,
      'pinnedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  // ============================================================
  // COMMENTS
  // ============================================================
  Stream<List<Comment>> commentsStream(String postId) {
    return _posts
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => Comment.fromMap(d.id, d.data()))
          .where((c) => !c.isDeleted)
          .toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  Future<String> addComment({
    required String postId,
    required String uid,
    required String userName,
    required String userAvatar,
    required String userPhotoBase64,
    required bool userVerified,
    String userVerifiedType = 'none',
    List<String> userBadges = const [],
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw ArgumentError('نص التعليق فارغ');
    if (trimmed.length > 300) throw ArgumentError('التعليق يتجاوز 300 حرف');

    final postRef = _posts.doc(postId);
    final commentRef = postRef.collection('comments').doc();

    final comment = Comment(
      id: commentRef.id,
      postId: postId,
      uid: uid,
      userName: userName,
      userAvatar: userAvatar,
      userPhotoBase64: userPhotoBase64,
      userVerified: userVerified,
      userVerifiedType: userVerifiedType,
      userBadges: userBadges,
      text: trimmed,
      createdAt: DateTime.now(),
    );

    final batch = _db.batch();
    batch.set(commentRef, comment.toMap());
    batch.update(postRef, {'commentsCount': FieldValue.increment(1)});
    await batch.commit();

    try {
      final postSnap = await postRef.get();
      final ownerUid = postSnap.data()?['uid'] as String?;
      if (ownerUid != null && ownerUid.isNotEmpty && ownerUid != uid) {
        await _notif.createFromUser(
          toUid: ownerUid,
          type: 'comment',
          fromUid: uid,
          targetId: postId,
        );
      }
    } catch (_) {}

    return commentRef.id;
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
    required String uid,
  }) async {
    final postRef = _posts.doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);

    final snap = await commentRef.get();
    if (!snap.exists) return;
    if (snap.data()?['uid'] != uid) {
      throw Exception('ما عندك صلاحية حذف هذا التعليق');
    }

    final batch = _db.batch();
    batch.update(commentRef, {'isDeleted': true});
    batch.update(postRef, {'commentsCount': FieldValue.increment(-1)});
    await batch.commit();
  }
}
