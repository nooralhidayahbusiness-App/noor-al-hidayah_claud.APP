import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/responsive.dart';
import '../core/theme.dart';
import '../models/post.dart';
import '../models/user_brief.dart';
import '../services/community_service.dart';
import '../services/follow_service.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/post_card.dart';
import '../widgets/profile_avatar.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String profileUid;

  const UserProfileScreen({super.key, required this.profileUid});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FollowService _followService = FollowService();
  final CommunityService _communityService = CommunityService();

  String? _currentUid;
  UserBrief? _currentUser;

  bool get _isOwnProfile => _currentUid == widget.profileUid;

  @override
  void initState() {
    super.initState();
    _currentUid = FirebaseAuth.instance.currentUser?.uid;
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    if (_currentUid == null) return;
    final data = await _followService.getUserBrief(_currentUid!);
    if (mounted) setState(() => _currentUser = data);
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.deepGreen,
        appBar: _buildAppBar(),
        body: StreamBuilder<UserBrief?>(
          stream: _followService.userBriefStream(widget.profileUid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting &&
                !snap.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }
            if (snap.hasError) {
              return _buildError('تعذّر تحميل البروفايل');
            }
            final user = snap.data;
            if (user == null) {
              return _buildError('المستخدم غير موجود');
            }
            return _buildContent(context, user);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.green,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.cream),
      centerTitle: true,
      title: Text(
        _isOwnProfile ? 'حسابي' : 'البروفايل',
        style: TextStyle(
          color: AppColors.softGold,
          fontSize: R.f(context, 16),
          fontWeight: FontWeight.bold,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // ============================================================
  // Content
  // ============================================================
  Widget _buildContent(BuildContext context, UserBrief user) {
    return ListView(
      padding: EdgeInsets.only(bottom: R.s(context, 24)),
      children: [
        SizedBox(height: R.s(context, 18)),
        _buildAvatarSection(context, user),
        SizedBox(height: R.s(context, 12)),
        _buildNameSection(context, user),
        if (user.bio.trim().isNotEmpty) ...[
          SizedBox(height: R.s(context, 8)),
          _buildBioSection(context, user.bio.trim()),
        ],
        SizedBox(height: R.s(context, 14)),
        _buildActionButton(context, user),
        SizedBox(height: R.s(context, 16)),
        _buildCountsRow(context, user),
        SizedBox(height: R.s(context, 20)),
        _buildDivider(context),
        _buildPostsHeader(context),
        _buildPostsList(context, user),
      ],
    );
  }

  // ============================================================
  // Avatar
  // ============================================================
  Widget _buildAvatarSection(BuildContext context, UserBrief user) {
    return Center(
      child: GestureDetector(
        onTap: _isOwnProfile ? () => showAvatarPicker(context) : null,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            ProfileAvatar(
              email: user.email,
              avatar: user.avatar,
              size: R.s(context, 100),
              photoBytes: user.photoBytes,
            ),
            if (_isOwnProfile)
              Container(
                margin: EdgeInsets.all(R.s(context, 6)),
                padding: EdgeInsets.all(R.s(context, 6)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold,
                  border: Border.all(
                    color: AppColors.deepGreen,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.deepGreen,
                  size: R.s(context, 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Name + Verified Badge
  // ============================================================
  Widget _buildNameSection(BuildContext context, UserBrief user) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.s(context, 24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              user.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.cream,
                fontSize: R.f(context, 19),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (user.verified) ...[
            SizedBox(width: R.s(context, 6)),
            Icon(
              Icons.verified,
              color: AppColors.gold,
              size: R.s(context, 21),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // Bio
  // ============================================================
  Widget _buildBioSection(BuildContext context, String bio) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.s(context, 32)),
      child: Text(
        bio,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.cream.withValues(alpha: 0.75),
          fontSize: R.f(context, 13),
          height: 1.4,
        ),
      ),
    );
  }

  // ============================================================
  // Action Button: "وثّق الآن" (own) أو "متابعة/متابَع" (others)
  // ============================================================
  Widget _buildActionButton(BuildContext context, UserBrief user) {
    if (_isOwnProfile) {
      // صاحب الحساب:
      // - لو موثّق → ما نعرض شي (الشارة جنب الاسم)
      // - لو غير موثّق → زر "وثّق الآن"
      if (user.verified) return const SizedBox.shrink();
      return Center(
        child: OutlinedButton.icon(
          onPressed: () => _openVerificationScreen(),
          icon: Icon(
            Icons.verified_outlined,
            size: R.s(context, 18),
          ),
          label: Text(
            'وثّق الآن',
            style: TextStyle(
              fontSize: R.f(context, 14),
              fontWeight: FontWeight.bold,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            side: const BorderSide(color: AppColors.gold, width: 1.5),
            padding: EdgeInsets.symmetric(
              horizontal: R.s(context, 22),
              vertical: R.s(context, 10),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(R.s(context, 24)),
            ),
          ),
        ),
      );
    }

    // بروفايل شخص آخر → زر المتابعة
    if (_currentUid == null) return const SizedBox.shrink();
    return Center(
      child: StreamBuilder<bool>(
        stream: _followService.isFollowingStream(
          followerUid: _currentUid!,
          followingUid: user.uid,
        ),
        builder: (context, snap) {
          final isFollowing = snap.data ?? false;
          return _buildFollowButton(context, isFollowing);
        },
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, bool isFollowing) {
    return ElevatedButton.icon(
      onPressed: _toggleFollow,
      icon: Icon(
        isFollowing ? Icons.check : Icons.person_add_alt_1,
        size: R.s(context, 18),
      ),
      label: Text(
        isFollowing ? 'متابَع' : 'متابعة',
        style: TextStyle(
          fontSize: R.f(context, 14),
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? AppColors.emerald : AppColors.gold,
        foregroundColor:
            isFollowing ? AppColors.cream : AppColors.deepGreen,
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 24),
          vertical: R.s(context, 10),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.s(context, 24)),
          side: isFollowing
              ? BorderSide(color: AppColors.gold.withValues(alpha: 0.5))
              : BorderSide.none,
        ),
        elevation: isFollowing ? 0 : 4,
      ),
    );
  }

  Future<void> _toggleFollow() async {
    if (_currentUid == null) return;
    try {
      await _followService.toggleFollow(
        followerUid: _currentUid!,
        followingUid: widget.profileUid,
      );
    } catch (e) {
      _showSnack('فشل العملية: $e');
    }
  }

  // ============================================================
  // Counts: Followers (right) | Following (left) — RTL
  // ============================================================
  Widget _buildCountsRow(BuildContext context, UserBrief user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // RTL: children[0] = يظهر على اليمين = المتابعون (followers)
        _CountTile(
          label: 'المتابعون',
          stream: _followService.followersCountStream(user.uid),
          onTap: () => _showSnack('قائمة المتابعين — قريباً'),
        ),
        Container(
          width: 1,
          height: R.s(context, 34),
          margin: EdgeInsets.symmetric(horizontal: R.s(context, 18)),
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
        // children[1] = يظهر على اليسار = المتابَعون (following)
        _CountTile(
          label: 'يتابعهم',
          stream: _followService.followingCountStream(user.uid),
          onTap: () => _showSnack('قائمة المتابَعين — قريباً'),
        ),
      ],
    );
  }

  // ============================================================
  // Divider
  // ============================================================
  Widget _buildDivider(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: R.s(context, 16)),
      height: 1,
      color: AppColors.gold.withValues(alpha: 0.25),
    );
  }

  // ============================================================
  // Posts Header
  // ============================================================
  Widget _buildPostsHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        R.s(context, 18),
        R.s(context, 14),
        R.s(context, 18),
        R.s(context, 6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.article_outlined,
            color: AppColors.gold,
            size: R.s(context, 16),
          ),
          SizedBox(width: R.s(context, 6)),
          Text(
            _isOwnProfile ? 'منشوراتي' : 'المنشورات',
            style: TextStyle(
              color: AppColors.softGold,
              fontSize: R.f(context, 14),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Posts List
  // ============================================================
  Widget _buildPostsList(BuildContext context, UserBrief user) {
    return StreamBuilder<List<Post>>(
      stream: _communityService.userPostsStream(user.uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting &&
            !snap.hasData) {
          return Padding(
            padding: EdgeInsets.all(R.s(context, 24)),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.gold,
                strokeWidth: 2,
              ),
            ),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: EdgeInsets.all(R.s(context, 20)),
            child: Center(
              child: Text(
                'تعذّر تحميل المنشورات',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: R.f(context, 12),
                ),
              ),
            ),
          );
        }
        final posts = snap.data ?? [];
        if (posts.isEmpty) {
          return _buildEmptyPosts(context);
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, i) {
            final post = posts[i];
            return PostCard(
              post: post,
              currentUid: _currentUid ?? '',
              onTap: () => _openPostDetail(post),
              onLike: () => _onLike(post),
              onComment: () => _openPostDetail(post),
              onRepost: () => _onRepost(post),
              onMore: () => _openPostDetail(post),
              onAuthorTap: () => _onAuthorTap(post),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyPosts(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: R.s(context, 24)),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.article_outlined,
              color: AppColors.cream.withValues(alpha: 0.35),
              size: R.s(context, 34),
            ),
            SizedBox(height: R.s(context, 8)),
            Text(
              _isOwnProfile
                  ? 'لم تنشر شيئاً بعد'
                  : 'لا توجد منشورات بعد',
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.6),
                fontSize: R.f(context, 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Error state
  // ============================================================
  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.softGold,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Actions
  // ============================================================
  void _openVerificationScreen() {
    // ⏳ لو الـ VerificationRequestScreen يحتاج بارامترات
    //    راح يطلع خطأ في flutter analyze — ارجع لي فيه.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const VerificationRequestScreen(),
      ),
    );
  }

  Future<void> _onLike(Post post) async {
    if (_currentUid == null) return;
    try {
      await _communityService.toggleLike(
        postId: post.id,
        uid: _currentUid!,
      );
    } catch (e) {
      _showSnack('فشل الإعجاب: $e');
    }
  }

  Future<void> _onRepost(Post post) async {
    if (_currentUser == null || _currentUid == null) return;
    final result = await Navigator.of(context).push<bool(
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(
          uid: _currentUid!,
          userName: _currentUser!.name,
          userAvatar: _currentUser!.avatar,
          userVerified: _currentUser!.verified,
          repostOf: post.id,
          originalAuthorUid: post.uid,
          originalAuthorName: post.userName,
          originalAuthorAvatar: post.userAvatar,
          repostPreviewText: post.text,
        ),
      ),
    );
    if (result == true && mounted) {
      _showSnack('تمت إعادة النشر');
    }
  }

  void _openPostDetail(Post post) {
    if (_currentUid == null || _currentUser == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
          currentUid: _currentUid!,
          currentUserName: _currentUser!.name,
          currentUserAvatar: _currentUser!.avatar,
          currentUserVerified: _currentUser!.verified,
        ),
      ),
    );
  }

  void _onAuthorTap(Post post) {
    if (post.uid == widget.profileUid) return; // نفس الشخص — ما نسوي شي
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(profileUid: post.uid),
      ),
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.emerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ============================================================
// _CountTile
// ============================================================
class _CountTile extends StatelessWidget {
  final String label;
  final Stream<int> stream;
  final VoidCallback onTap;

  const _CountTile({
    required this.label,
    required this.stream,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R.s(context, 12)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 12),
          vertical: R.s(context, 6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<int>(
              stream: stream,
              builder: (context, snap) {
                final count = snap.data ?? 0;
                return Text(
                  _formatCount(count),
                  style: TextStyle(
                    color: AppColors.cream,
                    fontSize: R.f(context, 17),
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            SizedBox(height: R.s(context, 2)),
            Text(
              label,
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.65),
                fontSize: R.f(context, 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCount(int c) {
    if (c < 1000) return c.toString();
    if (c < 1000000) {
      final k = c / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
    }
    final m = c / 1000000;
    return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
  }
}
