import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/channel_video_data.dart';

class YouTubeService {
  YouTubeService._();
  static final YouTubeService instance = YouTubeService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _videos =>
      _db.collection('channel_videos');

  // ============================================================
  // استخراج ID الفيديو من رابط YouTube
  // ============================================================
  static String? extractVideoId(String url) {
    if (url.isEmpty) return null;
    final patterns = [
      RegExp(r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/|youtube\.com/shorts/)([A-Za-z0-9_-]{11})'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(url);
      if (m != null && m.groupCount >= 1) {
        return m.group(1);
      }
    }
    // لو الرابط مباشر ID (11 حرف)
    if (RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(url)) {
      return url;
    }
    return null;
  }

  static String thumbnailFor(String videoId) =>
      'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

  // ============================================================
  // Stream — كل الفيديوهات (الأحدث أولاً)
  // ============================================================
  Stream<List<ChannelVideoData>> stream() {
    return _videos.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => ChannelVideoData.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ============================================================
  // إضافة فيديو
  // ============================================================
  Future<String> addVideo({
    required String title,
    required String url,
    String? thumbnailUrl,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedUrl = url.trim();
    if (trimmedTitle.isEmpty) throw ArgumentError('العنوان مطلوب');
    if (trimmedUrl.isEmpty) throw ArgumentError('الرابط مطلوب');

    final videoId = extractVideoId(trimmedUrl);
    if (videoId == null) {
      throw ArgumentError('رابط YouTube غير صالح');
    }

    final finalUrl = 'https://www.youtube.com/watch?v=$videoId';
    final thumb = (thumbnailUrl != null && thumbnailUrl.trim().isNotEmpty)
        ? thumbnailUrl.trim()
        : thumbnailFor(videoId);

    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final ref = _videos.doc();
    await ref.set({
      'title': trimmedTitle,
      'url': finalUrl,
      'thumbnailUrl': thumb,
      'videoId': videoId,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'addedBy': email,
    });

    return ref.id;
  }

  // ============================================================
  // حذف فيديو
  // ============================================================
  Future<void> deleteVideo(String id) async {
    try {
      await _videos.doc(id).delete();
    } catch (e) {
      debugPrint('deleteVideo error: $e');
      rethrow;
    }
  }

  // ============================================================
  // عدّاد
  // ============================================================
  Future<int> count() async {
    try {
      final snap = await _videos.get();
      return snap.docs.length;
    } catch (_) {
      return 0;
    }
  }
}

final youtubeService = YouTubeService.instance;
