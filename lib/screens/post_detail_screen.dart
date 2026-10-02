import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/community_service.dart';
import '../core/responsive.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  final String currentUid;
  final String currentUserName;
  final String currentUserAvatar;
  final bool currentUserVerified;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.currentUid,
    required this.currentUserName,
    required this.currentUserAvatar,
    required this.currentUserVerified,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _softGold = Color(0xFFF1DC9A);
  static const Color _deepGreen = Color(0xFF041F18);
  static const Color _green = Color(0xFF0B3D2E);
  static const Color _emerald = Color(0xFF14664C);
  static const Color _cream = Color(0xFFFFF8E7);

  final CommunityService _service = CommunityService();
  final TextEditingController _commentCtrl = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  bool _isSending = false;
  int _commentLen = 0;

  static const int _maxCommentChars = 300;

  bool get _canSend =>
      _commentLen > 0 && _commentLen <= _maxCommentChars && !_isSending;

  @override
  void initState() {
    super.initState();
    _commentCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _commentCtrl.removeListener(_onTextChanged);
    _commentCtrl.dispose();
    _commentFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final len = _commentCtrl.text.trim().length;
    if (len != _commentLen) setState(() => _commentLen = len);
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _deepGreen,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<Post?>(
                  stream: _service.postStream(widget.post.id),
                  builder: (context, postSnap) {
                    if (postSnap.hasData && postSnap.data == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) Navigator.of(context).pop();
                      });
                      return const SizedBox.shrink();
                    }
                    final post = postSnap.data ?? widget.post;
                    return _buildBody(context, post);
                  },
                ),
              ),
              _buildCommentInput(context),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AppBar
  // ============================================================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _green,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _cream),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'المنشور',
        style: TextStyle(
          color: _softGold,
          fontSize: R.f(context, 16),
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: _gold.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // ============================================================
  // Body
  // ============================================================
  Widget _buildBody(BuildContext context, Post post) {
    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding: EdgeInsets.only(bottom: R.s(context, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostCard(
            post: post,
            currentUid: widget.currentUid,
            onTap: null,
            onLike: () => _onLike(post),
            onComment: () => _commentFocus.requestFocus(),
            onRepost: () => _onRepost(post),
            onMore: () => _showMoreMenu(post),
            onAuthorTap: () => _showSnack('بروفايل ${post.userName} — قريباً'),
          ),
          Divider(
            color: _gold.withValues(alpha: 0.2),
            height: R.s(context, 24),
            thickness: 1,
          ),
          _buildCommentsHeader(context, post),
          SizedBox(height: R.s(context, 6)),
          _buildCommentsList(context, post),
        ],
      ),
    );
  }

  // ============================================================
  // Comments Header
  // ============================================================
  Widget _buildCommentsHeader(BuildContext context, Post post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.s(context, 16)),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            color: _gold,
            size: R.s(context, 16),
          ),
          SizedBox(width: R.s(context, 6)),
          Text(
            'التعليقات',
            style: TextStyle(
              color: _softGold,
              fontSize: R.f(context, 14),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (post.commentsCount > 0) ...[
            SizedBox(width: R.s(context, 6)),
            Text(
              '(${post.commentsCount})',
              style: TextStyle(
                color: _cream.withValues(alpha: 0.6),
                fontSize: R.f(context, 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // Comments List (Stream)
  // ============================================================
  Widget _buildCommentsList(BuildContext context, Post post) {
    return StreamBuilder<List<Comment>>(
      stream: _service.commentsStream(post.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.all(R.s(context, 24)),
            child: const Center(
              child: CircularProgressIndicator(color: _gold, strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.all(R.s(context, 20)),
            child: Center(
              child: Text(
                'تعذّر تحميل التعليقات',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: R.f(context, 12),
                ),
              ),
            ),
          );
        }
        final comments = snapshot.data ?? [];
        if (comments.isEmpty) {
          return _buildEmptyComments(context);
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, i) {
            final c = comments[i];
            return _CommentTile(
              comment: c,
              currentUid: widget.currentUid,
              onDelete: () => _confirmDeleteComment(c),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyComments(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.s(context, 16),
        vertical: R.s(context, 20),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.mode_comment_outlined,
              color: _cream.withValues(alpha: 0.4),
              size: R.s(context, 32),
            ),
            SizedBox(height: R.s(context, 8)),
            Text(
              'لا توجد تعليقات بعد — كن أول من يعلّق',
              style: TextStyle(
                color: _cream.withValues(alpha: 0.6),
                fontSize: R.f(context, 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Comment Input
  // ============================================================
  Widget _buildCommentInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.s(context, 10)),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: _gold.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: R.s(context, 12),
                vertical: R.s(context, 4),
              ),
              decoration: BoxDecoration(
                color: _deepGreen.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(R.s(context, 20)),
                border: Border.all(color: _gold.withValues(alpha: 0.25)),
              ),
              child: TextField(
                controller: _commentCtrl,
                focusNode: _commentFocus,
                maxLines: 4,
                minLines: 1,
                maxLength: _maxCommentChars,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  color: _cream,
                  fontSize: R.f(context, 13),
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'اكتب تعليقاً...',
                  hintStyle: TextStyle(
                    color: _cream.withValues(alpha: 0.4),
                    fontSize: R.f(context, 12),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  counterText: '',
                ),
              ),
            ),
          ),
          SizedBox(width: R.s(context, 8)),
          _buildSendButton(context),
        ],
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    final active = _canSend;
    return InkWell(
      onTap: active ? _sendComment : null,
      borderRadius: BorderRadius.circular(R.s(context, 24)),
      child: Container(
        width: R.s(context, 44),
        height: R.s(context, 44),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: active
              ? const LinearGradient(
                  colors: [_gold, _softGold],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                )
              : null,
          color: active ? null : _gold.withValues(alpha: 0.25),
        ),
        child: _isSending
            ? Padding(
                padding: EdgeInsets.all(R.s(context, 12)),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _deepGreen,
                ),
              )
            : Icon(
                Icons.send,
                color: active ? _deepGreen : _cream.withValues(alpha: 0.4),
                size: R.s(context, 20),
              ),
      ),
    );
  }

  // ============================================================
  // SEND COMMENT
  // ============================================================
  Future<void> _sendComment() async {
    if (!_canSend) return;
    setState(() => _isSending = true);

    try {
      await _service.addComment(
        postId: widget.post.id,
        uid: widget.currentUid,
        userName: widget.currentUserName,
        userAvatar: widget.currentUserAvatar,
        userVerified: widget.currentUserVerified,
        text: _commentCtrl.text,
      );
      _commentCtrl.clear();
      _commentFocus.unfocus();
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      _showSnack('فشل إرسال التعليق: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ============================================================
  // DELETE COMMENT
  // ============================================================
  Future<void> _confirmDeleteComment(Comment c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: _gold.withValues(alpha: 0.4)),
          ),
          title: Text(
            'حذف التعليق',
            style: TextStyle(color: _softGold, fontSize: R.f(context, 15)),
          ),
          content: Text(
            'هل أنت متأكد؟ لا يمكن التراجع.',
            style: TextStyle(color: _cream, fontSize: R.f(context, 13)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'إلغاء',
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
                'حذف',
                style: TextStyle(
                  fontSize: R.f(context, 13),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await _service.deleteComment(
        postId: widget.post.id,
        commentId: c.id,
        uid: widget.currentUid,
      );
    } catch (e) {
      _showSnack('فشل الحذف: $e');
    }
  }

  // ============================================================
  // ACTIONS
  // ============================================================
  Future<void> _onLike(Post post) async {
    try {
      await _service.toggleLike(postId: post.id, uid: widget.currentUid);
    } catch (e) {
      _showSnack('فشل الإعجاب: $e');
    }
  }

  Future<void> _onRepost(Post post) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(
          uid: widget.currentUid,
          userName: widget.currentUserName,
          userAvatar: widget.currentUserAvatar,
          userVerified: widget.currentUserVerified,
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

  // ============================================================
  // MORE MENU
  // ============================================================
  Future<void> _showMoreMenu(Post post) async {
    final isOwner = post.uid == widget.currentUid;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _green,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _menuHandle(),
              if (isOwner) ...[
                _menuItem(
                  context: sheetContext,
                  icon: Icons.edit_outlined,
                  label: 'تعديل المنشور',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showEditDialog(post);
                  },
                ),
                _menuItem(
                  context: sheetContext,
                  icon: post.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  label: post.isPinned ? 'إلغاء التثبيت' : 'تثبيت المنشور',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _togglePin(post);
                  },
                ),
              ],
              _menuItem(
                context: sheetContext,
                icon: Icons.copy_outlined,
                label: 'نسخ النص',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Clipboard.setData(ClipboardData(text: post.text));
                  _showSnack('تم نسخ النص');
                },
              ),
              if (isOwner)
                _menuItem(
                  context: sheetContext,
                  icon: Icons.delete_outline,
                  label: 'حذف المنشور',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _confirmDeletePost(post);
                  },
                ),
              SizedBox(height: R.s(context, 8)),
            ],
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

  // ============================================================
  // EDIT POST
  // ============================================================
  Future<void> _showEditDialog(Post post) async {
    final controller = TextEditingController(text: post.text);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: _gold.withValues(alpha: 0.4)),
          ),
          title: Text(
            'تعديل المنشور',
            style: TextStyle(color: _softGold, fontSize: R.f(context, 15)),
          ),
          content: TextField(
            controller: controller,
            maxLines: null,
            minLines: 4,
            maxLength: 500,
            autofocus: true,
            style: TextStyle(
              color: _cream,
              fontSize: R.f(context, 14),
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'نص المنشور...',
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
                'إلغاء',
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
                'حفظ',
                style: TextStyle(
                  fontSize: R.f(context, 13),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();

    if (result == null || result.isEmpty || result == post.text) return;
    try {
      await _service.editPost(
        postId: post.id,
        uid: widget.currentUid,
        newText: result,
      );
      _showSnack('تم تعديل المنشور');
    } catch (e) {
      _showSnack('فشل التعديل: $e');
    }
  }

  // ============================================================
  // DELETE POST
  // ============================================================
  Future<void> _confirmDeletePost(Post post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: _gold.withValues(alpha: 0.4)),
          ),
          title: Text(
            'حذف المنشور',
            style: TextStyle(color: _softGold, fontSize: R.f(context, 15)),
          ),
          content: Text(
            'هل أنت متأكد؟ لا يمكن التراجع.',
            style: TextStyle(color: _cream, fontSize: R.f(context, 13)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'إلغاء',
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
                'حذف',
                style: TextStyle(
                  fontSize: R.f(context, 13),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await _service.deletePost(postId: post.id, uid: widget.currentUid);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showSnack('فشل الحذف: $e');
    }
  }

  // ============================================================
  // PIN
  // ============================================================
  Future<void> _togglePin(Post post) async {
    try {
      await _service.togglePin(postId: post.id, uid: widget.currentUid);
      _showSnack(post.isPinned ? 'تم إلغاء التثبيت' : 'تم تثبيت المنشور');
    } catch (e) {
      _showSnack('فشل العملية: $e');
    }
  }

  // ============================================================
  // SNACK
  // ============================================================
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

// ============================================================
// _CommentTile
// ============================================================
class _CommentTile extends StatelessWidget {
  final Comment comment;
  final String currentUid;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.currentUid,
    required this.onDelete,
  });

  static const Color _gold = Color(0xFFD4AF37);
  static const Color _deepGreen = Color(0xFF041F18);
  static const Color _green = Color(0xFF0B3D2E);
  static const Color _emerald = Color(0xFF14664C);
  static const Color _cream = Color(0xFFFFF8E7);

  bool get _isOwner => comment.uid == currentUid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.s(context, 12),
        vertical: R.s(context, 5),
      ),
      child: Container(
        padding: EdgeInsets.all(R.s(context, 10)),
        decoration: BoxDecoration(
          color: _green.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(R.s(context, 12)),
          border: Border.all(color: _gold.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(context),
                SizedBox(width: R.s(context, 8)),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          comment.userName.isEmpty ? 'مستخدم' : comment.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _cream,
                            fontSize: R.f(context, 12),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (comment.userVerified) ...[
                        SizedBox(width: R.s(context, 3)),
                        Icon(
                          Icons.verified,
                          color: _gold,
                          size: R.s(context, 13),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  _formatTime(comment.createdAt),
                  style: TextStyle(
                    color: _cream.withValues(alpha: 0.5),
                    fontSize: R.f(context, 10),
                  ),
                ),
                if (_isOwner) ...[
                  SizedBox(width: R.s(context, 4)),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: EdgeInsets.all(R.s(context, 3)),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent.withValues(alpha: 0.7),
                        size: R.s(context, 15),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: R.s(context, 6)),
            Padding(
              padding: EdgeInsets.only(right: R.s(context, 34)),
              child: Text(
                comment.text,
                style: TextStyle(
                  color: _cream,
                  fontSize: R.f(context, 13),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final size = R.s(context, 28);
    final initial = comment.userName.isNotEmpty
        ? comment.userName.characters.first.toUpperCase()
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
        border: Border.all(color: _gold, width: 1),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: _gold,
            fontSize: R.f(context, 12),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} س';
    if (diff.inDays < 7) return 'قبل ${diff.inDays} ي';
    if (diff.inDays < 30) return 'قبل ${(diff.inDays / 7).floor()} أ';
    if (diff.inDays < 365) return 'قبل ${(diff.inDays / 30).floor()} ش';
    return 'قبل ${(diff.inDays / 365).floor()} س';
  }
}
