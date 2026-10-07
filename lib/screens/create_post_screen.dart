import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/profile_state.dart';
import '../core/responsive.dart';
import '../services/community_service.dart';
import '../services/premium_service.dart';

class CreatePostScreen extends StatefulWidget {
  final String uid;
  final String userName;
  final String userAvatar;
  final bool userVerified;
  final String userVerifiedType;
  final List<String> userBadges;

  final String? repostOf;
  final String? originalAuthorUid;
  final String? originalAuthorName;
  final String? originalAuthorAvatar;
  final String? repostPreviewText;

  const CreatePostScreen({
    super.key,
    required this.uid,
    required this.userName,
    required this.userAvatar,
    required this.userVerified,
    this.userVerifiedType = 'none',
    this.userBadges = const [],
    this.repostOf,
    this.originalAuthorUid,
    this.originalAuthorName,
    this.originalAuthorAvatar,
    this.repostPreviewText,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _softGold = Color(0xFFF1DC9A);
  static const Color _deepGreen = Color(0xFF041F18);
  static const Color _green = Color(0xFF0B3D2E);
  static const Color _emerald = Color(0xFF14664C);
  static const Color _cream = Color(0xFFFFF8E7);

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  final CommunityService _service = CommunityService();

  bool _isPosting = false;
  bool _isPremium = false; // ✅ جديد
  int _charCount = 0;

  // ✅ جديد: الحد يتغير حسب Premium (1000 للمميز، 500 للعادي)
  int get _maxChars => _isPremium ? 1000 : 500;

  bool get _isRepost => widget.repostOf != null;
  bool get _isValid =>
      _charCount > 0 && _charCount <= _maxChars && !_isPosting;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    if (_isRepost && widget.repostPreviewText != null) {
      _controller.text = widget.repostPreviewText!;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
    _loadPremium(); // ✅ جديد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  // ✅ جديد
  Future<void> _loadPremium() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final isPremium = await PremiumService.fetchIsUserPremium(uid);
    if (mounted) setState(() => _isPremium = isPremium);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final len = _controller.text.trim().length;
    if (len != _charCount) {
      setState(() => _charCount = len);
    }
  }

  Future<void> _submit() async {
    if (!_isValid) return;
    setState(() => _isPosting = true);

    try {
      await _service.createPost(
        uid: widget.uid,
        userName: widget.userName,
        userAvatar: widget.userAvatar,
        userPhotoBase64: profileState.photoBase64,
        userVerified: widget.userVerified,
        userVerifiedType: widget.userVerifiedType,
        userBadges: widget.userBadges,
        text: _controller.text,
        repostOf: widget.repostOf,
        originalAuthorUid: widget.originalAuthorUid,
        originalAuthorName: widget.originalAuthorName,
        originalAuthorAvatar: widget.originalAuthorAvatar,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${appState.tr('cCommentFailed')}: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Directionality(
          textDirection: appState.direction,
          child: Scaffold(
            backgroundColor: _deepGreen,
            appBar: _buildAppBar(),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(R.s(context, 14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAuthorRow(context),
                          SizedBox(height: R.s(context, 14)),
                          _buildTextField(context),
                          if (_isRepost) ...[
                            SizedBox(height: R.s(context, 14)),
                            _buildRepostNote(context),
                          ],
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _green,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: _cream),
        onPressed: () => Navigator.of(context).pop(false),
      ),
      title: Text(
        _isRepost ? appState.tr('cRepostTitle') : appState.tr('cCreatePost'),
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

  Widget _buildAuthorRow(BuildContext context) {
    final photoBytes = profileState.photoBytes;
    final fallbackPath = widget.userAvatar == 'woman'
        ? 'assets/images/hijab.png'
        : 'assets/images/arabian.png';
    final size = R.s(context, 44);

    return Row(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _gold, width: 1.5),
          ),
          child: ClipOval(
            child: photoBytes != null && photoBytes.isNotEmpty
                ? Image.memory(
                    photoBytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) => Image.asset(
                      fallbackPath,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    fallbackPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.person,
                      color: _gold,
                      size: R.s(context, 22),
                    ),
                  ),
          ),
        ),
        SizedBox(width: R.s(context, 10)),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  widget.userName.isEmpty
                      ? appState.tr('cUserNotFound')
                      : widget.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    // ✅ لون ذهبي إذا Premium
                    color: _isPremium ? _gold : _cream,
                    fontSize: R.f(context, 14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.userVerified) ...[
                SizedBox(width: R.s(context, 4)),
                Icon(Icons.verified, size: R.s(context, 15), color: _gold),
              ],
              // ✅ شارة Premium صغيرة
              if (_isPremium) ...[
                SizedBox(width: R.s(context, 6)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.s(context, 6),
                    vertical: R.s(context, 2),
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    ),
                    borderRadius: BorderRadius.circular(R.s(context, 8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: _deepGreen,
                        size: R.s(context, 11),
                      ),
                      SizedBox(width: R.s(context, 3)),
                      Text(
                        '1000',
                        style: TextStyle(
                          color: _deepGreen,
                          fontSize: R.f(context, 10),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.s(context, 12)),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(R.s(context, 14)),
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        maxLines: null,
        minLines: 6,
        maxLength: _maxChars, // ✅ يعتمد على Premium
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        style: TextStyle(
          color: _cream,
          fontSize: R.f(context, 14),
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: _isRepost
              ? appState.tr('cRepostHint')
              : appState.tr('cPostHint'),
          hintStyle: TextStyle(
            color: _cream.withValues(alpha: 0.4),
            fontSize: R.f(context, 13),
          ),
          border: InputBorder.none,
          counterStyle: TextStyle(
            color: _charCount > _maxChars
                ? Colors.redAccent
                : _cream.withValues(alpha: 0.55),
            fontSize: R.f(context, 11),
          ),
        ),
      ),
    );
  }

  Widget _buildRepostNote(BuildContext context) {
    final name = widget.originalAuthorName ?? appState.tr('cUserNotFound');
    return Container(
      padding: EdgeInsets.all(R.s(context, 10)),
      decoration: BoxDecoration(
        color: _emerald.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(R.s(context, 12)),
        border: Border.all(color: _softGold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.repeat, color: _softGold, size: R.s(context, 16)),
          SizedBox(width: R.s(context, 8)),
          Expanded(
            child: Text(
              '${appState.tr('cRepostFrom')} $name',
              style: TextStyle(
                color: _softGold,
                fontSize: R.f(context, 12),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.s(context, 12)),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.85),
        border: Border(
          top: BorderSide(color: _gold.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isPremium ? Icons.workspace_premium_rounded : Icons.text_fields,
            color: _charCount > _maxChars
                ? Colors.redAccent
                : (_isPremium
                    ? _gold
                    : _cream.withValues(alpha: 0.5)),
            size: R.s(context, 18),
          ),
          SizedBox(width: R.s(context, 6)),
          Text(
            '$_charCount / $_maxChars',
            style: TextStyle(
              color: _charCount > _maxChars
                  ? Colors.redAccent
                  : (_isPremium
                      ? _gold
                      : _cream.withValues(alpha: 0.6)),
              fontSize: R.f(context, 12),
              fontWeight: _isPremium ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _isValid ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isValid ? _gold : _gold.withValues(alpha: 0.3),
              foregroundColor: _deepGreen,
              padding: EdgeInsets.symmetric(
                horizontal: R.s(context, 18),
                vertical: R.s(context, 10),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R.s(context, 22)),
              ),
              elevation: _isValid ? 4 : 0,
            ),
            icon: _isPosting
                ? SizedBox(
                    width: R.s(context, 16),
                    height: R.s(context, 16),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _deepGreen,
                    ),
                  )
                : Icon(
                    _isRepost ? Icons.repeat : Icons.send,
                    size: R.s(context, 16),
                  ),
            label: Text(
              _isPosting
                  ? appState.tr('cPublishing')
                  : (_isRepost
                      ? appState.tr('cRepostAction')
                      : appState.tr('cPublish')),
              style: TextStyle(
                fontSize: R.f(context, 13),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
