import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../models/post.dart';
import '../services/premium_service.dart';
import 'animated_entry.dart';
import 'verified_badge.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String currentUid;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onMore;
  final VoidCallback? onAuthorTap;

  /// لتأخير الظهور حسب ترتيب المنشور
  final int animationIndex;

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
    this.animationIndex = 0,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with TickerProviderStateMixin {
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _softGold = Color(0xFFF1DC9A);
  static const Color _deepGreen = Color(0xFF041F18);
  static const Color _green = Color(0xFF0B3D2E);
  static const Color _emerald = Color(0xFF14664C);
  static const Color _cream = Color(0xFFFFF8E7);

  // نبضة للقلب عند الإعجاب
  late final AnimationController _likePulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  late final Animation<double> _likeScale = Tween<double>(
    begin: 1.0,
    end: 1.4,
  ).animate(CurvedAnimation(
    parent: _likePulse,
    curve: Curves.elasticOut,
  ));

  Post get post => widget.post;
  String get currentUid => widget.currentUid;

  bool get _isOwner => post.uid == currentUid;
  bool get _isLiked => post.isLikedBy(currentUid);

  @override
  void dispose() {
    _likePulse.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لو الإعجاب تغير → شغّل النبضة
    final wasLiked = oldWidget.post.isLikedBy(currentUid);
    if (!wasLiked && _isLiked) {
      _likePulse.forward(from: 0);
    }
  }

  void _handleLike() {
    widget.onLike?.call();
  }

  @override
  Widget build(BuildContext context) {
    // تأخير بسيط حسب ترتيب المنشور (يظهر واحد تلو الآخر)
    final delay = Duration(
      milliseconds: (widget.animationIndex * 60).clamp(0, 400),
    );

    return Directionality(
      textDirection: appState.direction,
      child: AnimatedEntry(
        delay: delay,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: R.s(context, 12),
            vertical: R.s(context, 6),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(R.s(context, 16)),
              child: _buildCard(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Stack(
      children: [
        // ===== البطاقة الرئيسية =====
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(R.s(context, 16)),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                _green.withValues(alpha: 0.92),
                _deepGreen.withValues(alpha: 0.98),
              ],
            ),
            border: Border.all(
              color: _gold.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: _gold.withValues(alpha: 0.08),
                blurRadius: 8,
                spreadRadius: 0,
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

        // ===== نجمة ثمانية - زاوية يمين أعلى =====
        Positioned(
          top: 0,
          right: 0,
          child: _OrnamentStar(
            size: R.s(context, 30),
            color: _gold,
          ),
        ),

        // ===== نجمة ثمانية - زاوية يسار أسفل =====
        Positioned(
          bottom: 0,
          left: 0,
          child: _OrnamentStar(
            size: R.s(context, 22),
            color: _gold.withValues(alpha: 0.6),
          ),
        ),

        // ===== المعين الذهبي المتوهج في الأسفل-الوسط =====
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.translate(
              offset: Offset(0, R.s(context, 5)),
              child: Container(
                width: R.s(context, 10),
                height: R.s(context, 10),
                decoration: BoxDecoration(
                  color: _gold,
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.7),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                transform: Matrix4.rotationZ(0.785398),
                transformAlignment: Alignment.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinnedBanner(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.s(context, 6)),
      child: Row(
        children: [
          Icon(Icons.push_pin, size: R.s(context, 13), color: _gold),
          SizedBox(width: R.s(context, 5)),
          Text(
            appState.tr('cPinnedPost'),
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

  Widget _buildRepostBanner(BuildContext context) {
    final name = post.originalAuthorName ?? appState.tr('cUserNotFound');
    return Padding(
      padding: EdgeInsets.only(bottom: R.s(context, 6)),
      child: Row(
        children: [
          Icon(Icons.repeat, size: R.s(context, 13), color: _softGold),
          SizedBox(width: R.s(context, 5)),
          Expanded(
            child: Text(
              '${appState.tr('cRepostFrom')} $name',
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
                    // ✅ StreamBuilder لفحص Premium الناشر
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(post.uid)
                          .snapshots(),
                      builder: (context, snap) {
                        // ✅ إصلاح: cast أولاً إلى Map
                        final docData =
                            snap.data?.data() as Map<String, dynamic>?;
                        final profile = (docData?['profile'] as Map?)
                            ?.cast<String, dynamic>();
                        final isPremium =
                            PremiumService.isUserPremium(profile);

                        return GestureDetector(
                          onTap: widget.onAuthorTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // تاج صغير قبل الاسم لـ Premium
                              if (isPremium) ...[
                                Icon(
                                  Icons.workspace_premium_rounded,
                                  color: _gold,
                                  size: R.s(context, 14),
                                ),
                                SizedBox(width: R.s(context, 3)),
                              ],
                              Flexible(
                                child: Text(
                                  post.userName.isEmpty
                                      ? appState.tr('cUserNotFound')
                                      : post.userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    // لون ذهبي لـ Premium
                                    color: isPremium ? _gold : _cream,
                                    fontSize: R.f(context, 14),
                                    fontWeight: FontWeight.bold,
                                    shadows: isPremium
                                        ? [
                                            Shadow(
                                              color: _gold.withValues(
                                                  alpha: 0.6),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (post.badges.isNotEmpty) ...[
                    SizedBox(width: R.s(context, 5)),
                    for (int i = 0; i < post.badges.length; i++) ...[
                      if (i > 0) SizedBox(width: R.s(context, 2)),
                      VerifiedBadge(
                        type: post.badges[i],
                        size: R.s(context, 16),
                      ),
                    ],
                  ],
                ],
              ),
              SizedBox(height: R.s(context, 2)),
              Row(
                children: [
                  Text(
                    _formatTime(context, post.createdAt),
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
                      appState.tr('cEdited'),
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
        if (widget.onMore != null)
          IconButton(
            onPressed: widget.onMore,
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

  Widget _buildAvatar(BuildContext context) {
    final size = R.s(context, 44);

    Uint8List? bytes;
    if (post.userPhotoBase64.isNotEmpty) {
      try {
        bytes = base64Decode(post.userPhotoBase64);
      } catch (_) {}
    }

    Widget child;
    if (bytes != null && bytes.isNotEmpty) {
      child = Image.memory(
        bytes,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _buildSymbolFallback(context),
      );
    } else {
      child = _buildSymbolFallback(context);
    }

    return GestureDetector(
      onTap: widget.onAuthorTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _gold, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.35),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipOval(child: child),
      ),
    );
  }

  Widget _buildSymbolFallback(BuildContext context) {
    final path = post.userAvatar == 'woman'
        ? 'assets/images/hijab.png'
        : 'assets/images/arabian.png';
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: _emerald,
        child: Center(
          child: Text(
            post.userName.isNotEmpty
                ? post.userName.characters.first.toUpperCase()
                : '?',
            style: TextStyle(
              color: _gold,
              fontSize: R.f(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Text(
      post.text,
      style: TextStyle(
        color: _cream,
        fontSize: R.f(context, 14),
        height: 1.55,
      ),
    );
  }

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
          // ===== إعجاب مع نبضة =====
          InkWell(
            onTap: _handleLike,
            borderRadius: BorderRadius.circular(R.s(context, 8)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: R.s(context, 4),
                vertical: R.s(context, 2),
              ),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: _likeScale,
                    child: Icon(
                      _isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: R.s(context, 18),
                      color: _isLiked
                          ? const Color(0xFFE84E6A)
                          : _cream.withValues(alpha: 0.7),
                    ),
                  ),
                  if (_formatCount(post.likesCount).isNotEmpty) ...[
                    SizedBox(width: R.s(context, 4)),
                    Text(
                      _formatCount(post.likesCount),
                      style: TextStyle(
                        color: _isLiked
                            ? const Color(0xFFE84E6A)
                            : _cream.withValues(alpha: 0.7),
                        fontSize: R.f(context, 12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(width: R.s(context, 18)),
          _buildActionButton(
            context,
            icon: Icons.chat_bubble_outline,
            color: _cream.withValues(alpha: 0.7),
            label: _formatCount(post.commentsCount),
            onTap: widget.onComment,
          ),
          SizedBox(width: R.s(context, 18)),
          _buildActionButton(
            context,
            icon: Icons.repeat,
            color: _cream.withValues(alpha: 0.7),
            label: _formatCount(post.repostsCount),
            onTap: widget.onRepost,
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

  static String _formatTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return appState.tr('cTimeNow');
    if (diff.inMinutes < 60) {
      return appState.trn('cTimeMinutesAgo', diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return appState.trn('cTimeHoursAgo', diff.inHours);
    }
    if (diff.inDays < 7) {
      return appState.trn('cTimeDaysAgo', diff.inDays);
    }
    if (diff.inDays < 30) {
      return appState.trn('cTimeWeeksAgo', (diff.inDays / 7).floor());
    }
    if (diff.inDays < 365) {
      return appState.trn('cTimeMonthsAgo', (diff.inDays / 30).floor());
    }
    return appState.trn('cTimeYearsAgo', (diff.inDays / 365).floor());
  }

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

// ============================================================
// _OrnamentStar — نجمة ثمانية إسلامية
// ============================================================
class _OrnamentStar extends StatelessWidget {
  final double size;
  final Color color;

  const _OrnamentStar({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _StarPainter(color: color),
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;

  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.42;

    final path = Path();
    for (int i = 0; i < 16; i++) {
      final angle = (i * 3.14159265) / 8 - 1.5708;
      final r = i.isEven ? outerR : innerR;
      final x = cx + r * _cos(angle);
      final y = cy + r * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  double _cos(double x) => _sin(x + 1.57079632);

  double _sin(double x) {
    x = x % (2 * 3.14159265);
    double term = x;
    double sum = x;
    for (int i = 1; i < 8; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      sum += term;
    }
    return sum;
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => false;
}
