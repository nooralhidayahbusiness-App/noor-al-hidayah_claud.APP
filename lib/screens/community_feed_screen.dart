import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../models/post.dart';
import '../services/community_service.dart';
import '../widgets/animated_entry.dart';
import '../widgets/islamic_empty_state.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';
import 'user_profile_screen.dart';

class CommunityFeedScreen extends StatefulWidget {
  final String uid;
  final String userName;
  final String userEmail;
  final String userAvatar;
  final bool userVerified;
  final String userVerifiedType;
  final List<String> userBadges;

  const CommunityFeedScreen({
    super.key,
    required this.uid,
    required this.userName,
    required this.userEmail,
    required this.userAvatar,
    required this.userVerified,
    this.userVerifiedType = 'none',
    this.userBadges = const [],
  });

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _softGold = Color(0xFFF1DC9A);
  static const Color _deepGreen = Color(0xFF041F18);
  static const Color _green = Color(0xFF0B3D2E);
  static const Color _emerald = Color(0xFF14664C);
  static const Color _cream = Color(0xFFFFF8E7);

  final CommunityService _service = CommunityService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Directionality(
          textDirection: appState.direction,
          child: Stack(
            children: [
              Positioned.fill(child: _buildFeed(context)),
              Positioned(
                bottom: R.s(context, 16),
                left: R.s(context, 16),
                child: _buildFab(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeed(BuildContext context) {
    return StreamBuilder<List<Post>>(
      stream: _service.postsStream(),
      builder: (context, snapshot) {
        return StreamBuilder<Post?>(
          stream: _service.globalPinnedStream(),
          builder: (context, pinSnap) {
            final welcomePost = pinSnap.data;

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _buildLoading(context);
            }
            if (snapshot.hasError) {
              return _buildError(context, snapshot.error.toString());
            }
            final posts = snapshot.data ?? [];

            if (posts.isEmpty && welcomePost == null) {
              return IslamicEmptyState(
                icon: Icons.forum_outlined,
                title: appState.tr('cNoPostsYet'),
                message: appState.tr('cBeFirstPost'),
                buttonLabel: appState.tr('cCreatePost'),
                onButtonTap: _openCreatePost,
              );
            }

            final all = <Widget>[];

            // ===== منشور الترحيب =====
            if (welcomePost != null) {
              all.add(
                AnimatedEntry(
                  child: _buildWelcomeLabel(context),
                ),
              );
              all.add(PostCard(
                key: ValueKey('welcome_${welcomePost.id}'),
                post: welcomePost,
                currentUid: widget.uid,
                animationIndex: 0,
                onTap: () => _openPostDetail(welcomePost),
                onLike: () => _onLike(welcomePost),
                onComment: () => _openPostDetail(welcomePost),
                onRepost: () => _onRepost(welcomePost),
                onMore: () => _showMoreMenu(welcomePost),
                onAuthorTap: () => _onAuthorTap(welcomePost),
              ));
              if (posts.isNotEmpty) {
                all.add(
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 100),
                    child: _buildDividerLabel(context),
                  ),
                );
              }
            }

            // ===== المنشورات =====
            for (int i = 0; i < posts.length; i++) {
              final post = posts[i];
              all.add(PostCard(
                key: ValueKey('post_${post.id}'),
                post: post,
                currentUid: widget.uid,
                animationIndex: welcomePost != null ? i + 1 : i,
                onTap: () => _openPostDetail(post),
                onLike: () => _onLike(post),
                onComment: () => _openPostDetail(post),
                onRepost: () => _onRepost(post),
                onMore: () => _showMoreMenu(post),
                onAuthorTap: () => _onAuthorTap(post),
              ));
            }

            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 300));
              },
              color: _gold,
              backgroundColor: _green,
              child: ListView(
                padding: EdgeInsets.only(
                  top: R.s(context, 8),
                  bottom: R.s(context, 90),
                ),
                children: all,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeLabel(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        R.s(context, 16),
        R.s(context, 10),
        R.s(context, 16),
        R.s(context, 6),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(R.s(context, 6)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold.withValues(alpha: 0.15),
              border: Border.all(
                color: _gold.withValues(alpha: 0.6),
              ),
            ),
            child: Icon(
              Icons.waving_hand_rounded,
              color: _gold,
              size: R.s(context, 14),
            ),
          ),
          SizedBox(width: R.s(context, 8)),
          Text(
            appState.tr('cWelcomePost'),
            style: TextStyle(
              color: _gold,
              fontSize: R.f(context, 12.5),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: R.s(context, 8)),
          Expanded(
            child: Container(
              height: 1,
              color: _gold.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDividerLabel(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.s(context, 16),
        vertical: R.s(context, 14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: _gold.withValues(alpha: 0.25)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: R.s(context, 10)),
            child: Text(
              appState.tr('cCommunityPosts'),
              style: TextStyle(
                fontSize: R.f(context, 11),
                color: _cream.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: _gold.withValues(alpha: 0.25)),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: _openCreatePost,
      backgroundColor: _gold,
      foregroundColor: _deepGreen,
      elevation: 6,
      child: const Icon(Icons.edit, size: 24),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: _gold),
          SizedBox(height: R.s(context, 14)),
          Text(
            appState.tr('cLoading'),
            style: TextStyle(
              color: _cream.withValues(alpha: 0.7),
              fontSize: R.f(context, 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.s(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: R.s(context, 42),
              color: Colors.redAccent,
            ),
            SizedBox(height: R.s(context, 12)),
            Text(
              appState.tr('cLoadPostsError'),
              style: TextStyle(
                color: _softGold,
                fontSize: R.f(context, 14),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: R.s(context, 6)),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _cream.withValues(alpha: 0.55),
                fontSize: R.f(context, 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onLike(Post post) async {
    try {
      await _service.toggleLike(postId: post.id, uid: widget.uid);
    } catch (e) {
      _showSnack('${appState.tr('cLikeFailed')}: $e');
    }
  }

  Future<void> _openCreatePost() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(
          uid: widget.uid,
          userName: widget.userName,
          userAvatar: widget.userAvatar,
          userVerified: widget.userVerified,
          userVerifiedType: widget.userVerifiedType,
          userBadges: widget.userBadges,
        ),
      ),
    );
    if (result == true && mounted) {
      _showSnack(appState.tr('cPublishSuccess'));
    }
  }

  Future<void> _onRepost(Post post) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(
          uid: widget.uid,
          userName: widget.userName,
          userAvatar: widget.userAvatar,
          userVerified: widget.userVerified,
          userVerifiedType: widget.userVerifiedType,
          userBadges: widget.userBadges,
          repostOf: post.id,
          originalAuthorUid: post.uid,
          originalAuthorName: post.userName,
          originalAuthorAvatar: post.userAvatar,
          repostPreviewText: post.text,
        ),
      ),
    );
    if (result == true && mounted) {
      _showSnack(appState.tr('cRepostSuccess'));
    }
  }

  void _openPostDetail(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
          currentUid: widget.uid,
          currentUserName: widget.userName,
          currentUserAvatar: widget.userAvatar,
          currentUserVerified: widget.userVerified,
          currentUserVerifiedType: widget.userVerifiedType,
          currentUserBadges: widget.userBadges,
        ),
      ),
    );
  }

  void _onAuthorTap(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(profileUid: post.uid),
      ),
    );
  }

  Future<void> _showMoreMenu(Post post) async {
    final isOwner = post.uid == widget.uid;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _green,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: appState.direction,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _menuHandle(),
                if (isOwner) ...[
                  _menuItem(
                    context: sheetContext,
                    icon: Icons.edit_outlined,
                    label: appState.tr('cEditPost'),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _showEditDialog(post);
                    },
                  ),
                  _menuItem(
                    context: sheetContext,
                    icon: post.isPinned
                        ? Icons.push_pin_outlined
                        : Icons.push_pin,
                    label: post.isPinned
                        ? appState.tr('cUnpinPost')
                        : appState.tr('cPinPost'),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _togglePin(post);
                    },
                  ),
                ],
                _menuItem(
                  context: sheetContext,
                  icon: Icons.copy_outlined,
                  label: appState.tr('cCopyText'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Clipboard.setData(ClipboardData(text: post.text));
                    _showSnack(appState.tr('cTextCopied'));
                  },
                ),
                if (isOwner)
                  _menuItem(
                    context: sheetContext,
                    icon: Icons.delete_outline,
                    label: appState.tr('cDeletePost'),
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _confirmDelete(post);
                    },
                  ),
                SizedBox(height: R.s(context, 8)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuHandle() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: R.s(context, 10)),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _menuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? _cream;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 20),
          vertical: R.s(context, 14),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: R.s(context, 20)),
            SizedBox(width: R.s(context, 14)),
            Text(
              label,
              style: TextStyle(
                color: c,
                fontSize: R.f(context, 14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(Post post) async {
    final controller = TextEditingController(text: post.text);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: appState.direction,
          child: AlertDialog(
            backgroundColor: _green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: _gold.withValues(alpha: 0.4)),
            ),
            title: Text(
              appState.tr('cEditPost'),
              style: TextStyle(color: _softGold, fontSize: R.f(context, 15)),
            ),
            content: TextField(
              controller: controller,
              maxLines: null,
              minLines: 4,
              maxLength: 1000,
              autofocus: true,
              style: TextStyle(
                color: _cream,
                fontSize: R.f(context, 14),
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: appState.tr('cPostHint'),
                hintStyle: TextStyle(
                  color: _cream.withValues(alpha: 0.4),
                  fontSize: R.f(context, 13),
                ),
                counterStyle: TextStyle(
                  color: _cream.withValues(alpha: 0.55),
                  fontSize: R.f(context, 11),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _gold.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _gold, width: 1.5),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  appState.tr('cancel'),
                  style: TextStyle(
                    color: _cream.withValues(alpha: 0.7),
                    fontSize: R.f(context, 13),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final txt = controller.text.trim();
                  if (txt.isEmpty) return;
                  Navigator.of(dialogContext).pop(txt);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: _deepGreen,
                ),
                child: Text(
                  appState.tr('save'),
                  style: TextStyle(
                    fontSize: R.f(context, 13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();

    if (result == null || result.isEmpty) return;
    if (result == post.text) return;

    try {
      await _service.editPost(
        postId: post.id,
        uid: widget.uid,
        newText: result,
      );
      if (mounted) _showSnack(appState.tr('cPostEdited'));
    } catch (e) {
      _showSnack('${appState.tr('cOperationFailed')}: $e');
    }
  }

  Future<void> _confirmDelete(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: appState.direction,
          child: AlertDialog(
            backgroundColor: _green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: _gold.withValues(alpha: 0.4)),
            ),
            title: Text(
              appState.tr('cDeletePost'),
              style: TextStyle(color: _softGold, fontSize: R.f(context, 15)),
            ),
            content: Text(
              appState.tr('cDeletePostConfirm'),
              style: TextStyle(color: _cream, fontSize: R.f(context, 13)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  appState.tr('cancel'),
                  style: TextStyle(
                    color: _cream.withValues(alpha: 0.7),
                    fontSize: R.f(context, 13),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  appState.tr('cDeletePost'),
                  style: TextStyle(
                    fontSize: R.f(context, 13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _service.deletePost(postId: post.id, uid: widget.uid);
      if (mounted) _showSnack(appState.tr('cPostDeleted'));
    } catch (e) {
      _showSnack('${appState.tr('cOperationFailed')}: $e');
    }
  }

  Future<void> _togglePin(Post post) async {
    try {
      await _service.togglePin(postId: post.id, uid: widget.uid);
      if (mounted) {
        _showSnack(post.isPinned
            ? appState.tr('cUnpinSuccess')
            : appState.tr('cPinSuccess'));
      }
    } catch (e) {
      _showSnack('${appState.tr('cOperationFailed')}: $e');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _emerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
