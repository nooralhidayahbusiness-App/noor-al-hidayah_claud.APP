import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../models/post.dart';
import '../services/auth_service.dart';
import '../services/premium_service.dart';
import 'profile_avatar.dart';
import 'verified_badge.dart';
import 'user_badges.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onRepost,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);
    final uid = AuthService.currentUid;
    final isOwn = uid == post.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: uid != null
          ? FirebaseFirestore.instance.collection('users').doc(post.uid).snapshots()
          : const Stream.empty(),
      builder: (context, snap) {
        final data = snap.data?.data() as Map<String, dynamic>?;
        final premium = (data?['profile']?['premium'] ?? {}) as Map<String, dynamic>;
        final isPremium = premium['active'] == true;

        final nameColor = isPremium ? AppColors.gold : AppColors.cream;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: R.s(context, 12),
              vertical: R.s(context, 6),
            ),
            padding: EdgeInsets.all(R.s(context, 14)),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.25),
              borderRadius: BorderRadius.circular(R.s(context, 16)),
              border: Border.all(
                color: isPremium ? AppColors.gold.withOpacity(0.4) : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ProfileAvatar(
                      avatar: post.userAvatar,
                      photoBase64: post.userPhotoBase64,
                      size: R.s(context, 44),
                      showCrown: isPremium,
                    ),
                    SizedBox(width: R.s(context, 10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  post.userName,
                                  style: TextStyle(
                                    color: nameColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: R.f(context, 14),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (post.userVerified) ...[
                                SizedBox(width: R.s(context, 4)),
                                VerifiedBadge(type: post.userVerifiedType, size: R.s(context, 16)),
                              ],
                            ],
                          ),
                          if (post.createdAt != null)
                            Text(
                              _timeAgo(post.createdAt!),
                              style: TextStyle(color: AppColors.cream.withOpacity(0.5), fontSize: R.f(context, 11)),
                            ),
                        ],
                      ),
                    ),
                    if (post.isPinned)
                      Icon(Icons.push_pin, color: AppColors.gold, size: R.s(context, 16)),
                    if (post.isGlobalPin)
                      Icon(Icons.public, color: AppColors.gold, size: R.s(context, 16)),
                  ],
                ),
                SizedBox(height: R.s(context, 10)),
                Text(
                  post.text,
                  style: TextStyle(color: AppColors.cream, fontSize: R.f(context, 14), height: 1.4),
                ),
                if (post.userBadges.isNotEmpty) ...[
                  SizedBox(height: R.s(context, 8)),
                  UserBadges(badges: post.userBadges, size: R.s(context, 20)),
                ],
                SizedBox(height: R.s(context, 10)),
                Row(
                  children: [
                    _actionIcon(
                      context,
                      Icons.favorite,
                      post.likes.contains(uid) ? AppColors.gold : AppColors.cream.withOpacity(0.6),
                      post.likesCount,
                      onLike,
                    ),
                    SizedBox(width: R.s(context, 16)),
                    _actionIcon(
                      context,
                      Icons.comment,
                      AppColors.cream.withOpacity(0.6),
                      post.commentsCount,
                      onComment,
                    ),
                    SizedBox(width: R.s(context, 16)),
                    _actionIcon(
                      context,
                      Icons.repeat,
                      AppColors.cream.withOpacity(0.6),
                      post.repostsCount,
                      onRepost,
                    ),
                    const Spacer(),
                    if (isOwn)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red.withOpacity(0.6), size: R.s(context, 20)),
                        onPressed: () {
                          // حذف
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionIcon(BuildContext context, IconData icon, Color color, int count, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: R.s(context, 18)),
          if (count > 0) ...[
            SizedBox(width: R.s(context, 4)),
            Text('$count', style: TextStyle(color: color, fontSize: R.f(context, 12))),
          ],
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return '${diff.inMinutes} د';
    if (diff.inDays < 1) return '${diff.inHours} س';
    return '${diff.inDays} ي';
  }
}
