import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/comment.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('posts');

  // ============================================================
  // POSTS
  // ============================================================

  /// Stream كل المنشورات (الأحدث أولاً)
  Stream<List<Post>> postsStream({int limit = 100}) {
    return _posts
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Post.fromMap(d.id, d.data()))
            .where((p) => !p.isDeleted)
            .toList());
  }

  /// Stream منشورات مستخدم معيّن (لصفحة البروفايل)
  Stream<List<Post>> userPostsStream(String uid, {int limit = 100}) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Post.fromMap(d.id, d.data()))
            .where((p) => !p.isDeleted)
            .toList());
  }

  /// Stream منشور واحد
  Stream<Post?> postStream(String postId) {
    return _posts.doc(postId).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return Post.fromMap(snap.id, data);
    });
  }

  /// إنشاء منشور جديد — يرجّع postId
  Future<String> createPost({
    required String uid,
    required String userName,
    required String userAvatar,
    required bool userVerified,
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
    if (trimmed.length > 500) {
      throw ArgumentError('نص المنشور يتجاوز 500 حرف');
    }

    final mentions = Post.extractMentions(trimmed);
    final hashtags = Post.extractHashtags(trimmed);

    final ref = _posts.doc();
    final post = Post(
      id: ref.id,
      uid: uid,
      userName: userName,
      userAvatar: userAvatar,
      userVerified: userVerified,
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

    // إذا إعادة نشر — نزيد العدّاد عند المنشور الأصلي
    if (repostOf != null) {
      await _posts.doc(repostOf).update({
        'repostsCount': FieldValue.increment(1),
      });
    }

    return ref.id;
  }

  /// تعديل منشور (النص فقط)
  Future<void> editPost({
    required String postId,
    required String uid,
    required String newText,
  }) async {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('نص المنشور فارغ');
    }
    if (trimmed.length > 500) {
      throw ArgumentError('نص المنشور يتجاوز 500 حرف');
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

  /// حذف ناعم للمنشور
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

  /// toggle إعجاب (like/unlike)
  Future<void> toggleLike({
    required String postId,
    required String uid,
  }) async {
    final ref = _posts.doc(postId);
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
    });
  }

  /// تثبيت / إلغاء تثبيت منشور — منشور واحد فقط مثبّت لكل مستخدم
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

    // لو المنشور مثبّت → إلغاء التثبيت فقط
    if (currentlyPinned) {
      await ref.update({'isPinned': false});
      return;
    }

    // إلغاء تثبيت أي منشور آخر لنفس المستخدم ثم تثبيت هذا
    final pinned = await _posts
        .where('uid', isEqualTo: uid)
        .where('isPinned', isEqualTo: true)
        .get();

    final batch = _db.batch();
    for (final doc in pinned.docs) {
      batch.update(doc.reference, {'isPinned': false});
    }
    batch.update(ref, {'isPinned': true});
    await batch.commit();
  }

  /// إعادة نشر
  Future<String> repost({
    required String originalPostId,
    required String uid,
    required String userName,
    required String userAvatar,
    required bool userVerified,
    String? comment,
  }) async {
    final originalSnap = await _posts.doc(originalPostId).get();
    if (!originalSnap.exists) throw Exception('المنشور الأصلي غير موجود');
    final original = originalSnap.data() ?? {};

    return createPost(
      uid: uid,
      userName: userName,
      userAvatar: userAvatar,
      userVerified: userVerified,
      text: (comment == null || comment.trim().isEmpty)
          ? (original['text'] ?? '')
          : comment.trim(),
      repostOf: originalPostId,
      originalAuthorUid: original['uid'],
      originalAuthorName: original['userName'],
      originalAuthorAvatar: original['userAvatar'],
    );
  }

  // ============================================================
  // COMMENTS
  // ============================================================

  Stream<List<Comment>> commentsStream(String postId) {
    return _posts
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Comment.fromMap(d.id, d.data()))
            .where((c) => !c.isDeleted)
            .toList());
  }

  Future<String> addComment({
    required String postId,
    required String uid,
    required String userName,
    required String userAvatar,
    required bool userVerified,
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
      userVerified: userVerified,
      text: trimmed,
      createdAt: DateTime.now(),
    );

    final batch = _db.batch();
    batch.set(commentRef, comment.toMap());
    batch.update(postRef, {'commentsCount': FieldValue.increment(1)});
    await batch.commit();

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
