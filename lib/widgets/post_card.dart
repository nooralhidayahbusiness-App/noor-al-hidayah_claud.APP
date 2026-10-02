import 'package:flutter/material.dart';
import '../models/post.dart';
import '../core/responsive.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String currentUid;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onMore;
  final VoidCallback? onAuthorTap;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUid,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onRepost,
    this.onMore,
    this.onAuthorTap,
  });

  // ===== ألوان النظام =====
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _softGold = Color(0xFFF1DC9A);
  static const Color _deepGreen = Color(0xFF041F18);
  static const Color _green = Color(0xFF0B3D2E);
  static const Color _emerald = Color(0xFF14664C);
  static const Color _cream = Color(0xFFFFF8E7);

  bool get _isOwner => post.uid == currentUid;
  bool get _isLiked => post.isLikedBy(currentUid);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.s(context, 12),
        vertical: R.s(context, 6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(R.s(context, 16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(R.s(context, 16)),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  _green.withValues(alpha: 0.85),
                  _deepGreen.withValues(alpha: 0.92),
                ],
              ),
              border: Border.all(
                color: _gold.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(R.s(context, 12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.isPinned) _buildPinnedBanner(context),
                  if (post.isRepost) _buildRepostBanner(context),
                  _buildHeader(context),
                  SizedBox(height: R.s(context, 10)),
                  _buildBody(context),
                  SizedBox(height: R.s(context, 10)),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // شريط "مثبت"
  // ============================================================
  Widget _buildPinnedBanner(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.s(context, 6)),
      child: Row(
        children: [
          Icon(Icons.push_pin, size: R.s(context, 13), color: _gold),
          SizedBox(width: R.s(context, 5)),
          Text(
            'منشور مثبّت',
            style: TextStyle(
              color: _gold,
              fontSize: R.f(context, 11),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // شريط "إعادة نشر"
  // ============================================================
  Widget _buildRepostBanner(BuildContext context) {
    final name = post.originalAuthorName ?? 'مستخدم';
    return Padding(
      padding: EdgeInsets.only(bottom: R.s(context, 6)),
      child: Row(
        children: [
          Icon(Icons.repeat, size: R.s(context, 13), color: _softGold),
          SizedBox(width: R.s(context, 5)),
          Expanded(
            child: Text(
              'أعاد نشر منشور $name',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _softGold.withValues(alpha: 0.85),
                fontSize: R.f(context, 11),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // الهيدر: الصورة + الاسم + الشعار + الوقت + زر المزيد
  // ============================================================
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(context),
        SizedBox(width: R.s(context, 10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: onAuthorTap,
                      child: Text(
                        post.userName.isEmpty ? 'مستخدم' : post.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _cream,
                          fontSize: R.f(context, 14),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (post.userVerified) ...[
                    SizedBox(width: R.s(context, 4)),
                    Icon(
                      Icons.verified,
                      size: R.s(context, 15),
                      color: _gold,
                    ),
                  ],
                ],
              ),
              SizedBox(height: R.s(context, 2)),
              Row(
                children: [
                  Text(
                    _formatTime(post.createdAt),
                    style: TextStyle(
                      color: _cream.withValues(alpha: 0.55),
                      fontSize: R.f(context, 11),
                    ),
                  ),
                  if (post.isEdited) ...[
                    Text(
                      ' · ',
                      style: TextStyle(
                        color: _cream.withValues(alpha: 0.55),
                        fontSize: R.f(context, 11),
                      ),
                    ),
                    Text(
                      'تم التعديل',
                      style: TextStyle(
                        color: _cream.withValues(alpha: 0.55),
                        fontSize: R.f(context, 11),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (onMore != null)
          IconButton(
            onPressed: onMore,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.more_horiz,
              color: _cream.withValues(alpha: 0.7),
              size: R.s(context, 22),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // الأفاتار (حلقة ذهبية + أول حرف كبديل)
  // ============================================================
  Widget _buildAvatar(BuildContext context) {
    final size = R.s(context, 42);
    final initial = post.userName.isNotEmpty
        ? post.userName.characters.first.toUpperCase()
        : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_emerald, _deepGreen],
        ),
        border: Border.all(color: _gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.25),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: _gold,
            fontSize: R.f(context, 16),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // نص المنشور
  // ============================================================
  Widget _buildBody(BuildContext context) {
    return Text(
      post.text,
      style: TextStyle(
        color: _cream,
        fontSize: R.f(context, 14),
        height: 1.5,
      ),
    );
  }

  // ============================================================
  // شريط الأزرار: إعجاب / تعليق / إعادة نشر
  // ============================================================
  Widget _buildActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: R.s(context, 8)),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: _gold.withValues(alpha: 0.18),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildActionButton(
            context,
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? const Color(0xFFE84E6A) : _cream.withValues(alpha: 0.7),
            label: _formatCount(post.likesCount),
            onTap: onLike,
          ),
          SizedBox(width: R.s(context, 18)),
          _buildActionButton(
            context,
            icon: Icons.chat_bubble_outline,
            color: _cream.withValues(alpha: 0.7),
            label: _formatCount(post.commentsCount),
            onTap: onComment,
          ),
          SizedBox(width: R.s(context, 18)),
          _buildActionButton(
            context,
            icon: Icons.repeat,
            color: _cream.withValues(alpha: 0.7),
            label: _formatCount(post.repostsCount),
            onTap: onRepost,
          ),
          const Spacer(),
          if (_isOwner)
            Padding(
              padding: EdgeInsets.only(right: R.s(context, 4)),
              child: Icon(
                Icons.person_outline,
                size: R.s(context, 14),
                color: _gold.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R.s(context, 8)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 4),
          vertical: R.s(context, 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: R.s(context, 17), color: color),
            if (label.isNotEmpty) ...[
              SizedBox(width: R.s(context, 4)),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: R.f(context, 12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Helpers
  // ============================================================

  /// تنسيق الوقت بالعربية
  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) {
      return 'قبل ${diff.inMinutes} دقيقة';
    }
    if (diff.inHours < 24) {
      return 'قبل ${diff.inHours} ساعة';
    }
    if (diff.inDays < 7) {
      return 'قبل ${diff.inDays} يوم';
    }
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return 'قبل $weeks أسبوع';
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return 'قبل $months شهر';
    }
    final years = (diff.inDays / 365).floor();
    return 'قبل $years سنة';
  }

  /// تنسيق الأعداد (1.2K, 3.4M)
  static String _formatCount(int count) {
    if (count <= 0) return '';
    if (count < 1000) return count.toString();
    if (count < 1000000) {
      final k = count / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
    }
    final m = count / 1000000;
    return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
  }
}
