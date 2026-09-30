import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../data/ai_teacher_data.dart';
import '../services/auth_service.dart';
import '../services/gemini_service.dart';
import '../services/user_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

class AiTeacherScreen extends StatefulWidget {
  const AiTeacherScreen({super.key});

  @override
  State<AiTeacherScreen> createState() => _AiTeacherScreenState();
}

class _AiTeacherScreenState extends State<AiTeacherScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _thinking = false;
  bool _started = false;
  int _sessionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    try {
      final p = await userService.loadProgress('aiTeacher');
      final sessions = (p['sessions'] as num?)?.toInt() ?? 0;
      final history = (p['history'] as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _sessionCount = sessions;
        if (history.isNotEmpty) {
          _messages.addAll(history
              .map((e) => ChatMessage.fromMap(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList());
          _started = true;
        }
      });
      _scrollToEnd();
    } catch (_) {}
  }

  Future<void> _saveProgress() async {
    if (authService.currentUser == null) return;
    try {
      await userService.saveProgress('aiTeacher', {
        'sessions': _sessionCount,
        'history': _messages
            .map((m) => m.toMap())
            .toList()
            .take(50)
            .toList(),
        'lastUpdate': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  Future<void> _send({String? preset}) async {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty || _thinking) return;

    _input.clear();
    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      time: DateTime.now(),
    );
    setState(() {
      _messages.add(userMsg);
      _thinking = true;
      _started = true;
      _sessionCount++;
    });
    _scrollToEnd();

    try {
      final response = await geminiService.ask(
        message: text,
        history: _messages.sublist(
          0,
          _messages.length - 1,
        ),
        systemPrompt: appState.isArabic
            ? kTeacherSystemPromptAr
            : kTeacherSystemPromptEn,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          time: DateTime.now(),
        ));
        _thinking = false;
      });
      _scrollToEnd();
      _saveProgress();
    } on GeminiException catch (e) {
      if (!mounted) return;
      setState(() => _thinking = false);
      _showError(_mapError(e.key));
    } catch (e) {
      if (!mounted) return;
      setState(() => _thinking = false);
      _showError(appState.tr('teacherErrorGeneric'));
    }
  }

  String _mapError(String key) {
    switch (key) {
      case 'geminiQuota':
        return appState.tr('teacherErrorQuota');
      case 'geminiAuth':
        return appState.tr('teacherErrorAuth');
      case 'geminiTimeout':
        return appState.tr('teacherErrorTimeout');
      case 'geminiBlocked':
        return appState.tr('teacherErrorBlocked');
      default:
        return appState.tr('teacherErrorGeneric');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF5C1F1F),
          content: Text(
            msg,
            style: const TextStyle(color: AppColors.cream),
          ),
        ),
      );
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _clearChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Text(
          appState.tr('teacherClearTitle'),
          style: const TextStyle(color: AppColors.softGold),
        ),
        content: Text(
          appState.tr('teacherClearBody'),
          style: const TextStyle(color: AppColors.cream),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(appState.tr('cancel'),
                style: const TextStyle(color: AppColors.softGold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(appState.tr('reset'),
                style: const TextStyle(color: Color(0xFFFF8A80))),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() {
      _messages.clear();
      _started = false;
    });
    await _saveProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ThemedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _started
                    ? _buildChat()
                    : _buildCategories(),
              ),
              _buildInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        R.s(context, 6),
        R.s(context, 6),
        R.s(context, 16),
        0,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            color: AppColors.softGold,
            iconSize: R.s(context, 22),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                appState.tr('teacherTitle'),
                style: TextStyle(
                  fontSize: R.f(context, 15),
                  fontWeight: FontWeight.w700,
                  color: AppColors.softGold,
                ),
              ),
              SizedBox(width: R.s(context, 6)),
              _BetaBadge(),
            ],
          ),
          SizedBox(width: R.s(context, 6)),
          if (_started)
            IconButton(
              onPressed: _clearChat,
              tooltip: appState.tr('teacherClearTitle'),
              icon: Icon(
                Icons.refresh_rounded,
                color: AppColors.softGold.withValues(alpha: 0.85),
                size: R.s(context, 20),
              ),
            )
          else
            SizedBox(width: R.s(context, 40)),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        R.s(context, 16),
        R.s(context, 8),
        R.s(context, 16),
        R.s(context, 16),
      ),
      children: [
        GlassCard(
          ornament: false,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(R.s(context, 8)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: AppColors.gold,
                      size: R.s(context, 22),
                    ),
                  ),
                  SizedBox(width: R.s(context, 10)),
                  Expanded(
                    child: Text(
                      appState.tr('teacherWelcome'),
                      style: TextStyle(
                        fontSize: R.f(context, 13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.s(context, 8)),
              Text(
                appState.tr('teacherWelcomeDesc'),
                style: TextStyle(
                  fontSize: R.f(context, 11.5),
                  height: 1.6,
                  color: AppColors.cream.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: R.s(context, 14)),
        Text(
          appState.tr('teacherCategories'),
          style: TextStyle(
            fontSize: R.f(context, 13),
            fontWeight: FontWeight.w700,
            color: AppColors.softGold,
          ),
        ),
        SizedBox(height: R.s(context, 8)),
        ...kTeacherCategories.map((cat) => Padding(
              padding: EdgeInsets.only(bottom: R.s(context, 8)),
              child: _CategoryTile(
                category: cat,
                onTap: () => _send(
                  preset: appState.isArabic
                      ? cat.promptAr
                      : cat.promptEn,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildChat() {
    return ListView.builder(
      controller: _scroll,
      padding: EdgeInsets.fromLTRB(
        R.s(context, 12),
        R.s(context, 8),
        R.s(context, 12),
        R.s(context, 16),
      ),
      itemCount: _messages.length + (_thinking ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _messages.length && _thinking) {
          return _TypingBubble();
        }
        return _MessageBubble(message: _messages[i]);
      },
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        R.s(context, 12),
        R.s(context, 8),
        R.s(context, 12),
        R.s(context, 12),
      ),
      decoration: BoxDecoration(
        color: AppColors.deepGreen.withValues(alpha: 0.7),
        border: Border(
          top: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_started && _messages.isEmpty)
            SizedBox(height: R.s(context, 2)),
          if (_started)
            SizedBox(
              height: R.s(context, 34),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: kTeacherSuggestions
                    .map((s) => Padding(
                          padding: EdgeInsets.only(
                              right: R.s(context, 6)),
                          child: ActionChip(
                            label: Text(
                              appState.isArabic ? s.textAr : s.textEn,
                              style: TextStyle(
                                fontSize: R.f(context, 10),
                                color: AppColors.cream,
                              ),
                            ),
                            onPressed: _thinking
                                ? null
                                : () => _send(
                                      preset: appState.isArabic
                                          ? s.fullPromptAr
                                          : s.fullPromptEn,
                                    ),
                            backgroundColor: Colors.black
                                .withValues(alpha: 0.25),
                            side: BorderSide(
                              color: AppColors.gold
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          if (_started) SizedBox(height: R.s(context, 6)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  style: TextStyle(
                    color: AppColors.cream,
                    fontSize: R.f(context, 13),
                  ),
                  decoration: InputDecoration(
                    hintText: appState.tr('teacherHint'),
                    hintStyle: TextStyle(
                      color: AppColors.cream.withValues(alpha: 0.5),
                      fontSize: R.f(context, 12),
                    ),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.25),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: R.s(context, 12),
                      vertical: R.s(context, 10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: AppColors.gold,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: R.s(context, 8)),
              GestureDetector(
                onTap: _thinking ? null : () => _send(),
                child: Container(
                  width: R.s(context, 42),
                  height: R.s(context, 42),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _thinking
                        ? AppColors.gold.withValues(alpha: 0.4)
                        : AppColors.gold,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: _thinking
                      ? const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.deepGreen,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: AppColors.deepGreen,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== Beta Badge ====================
class _BetaBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: R.s(context, 6),
        vertical: R.s(context, 2),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA000).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFFA000),
          width: 1,
        ),
      ),
      child: Text(
        'BETA',
        style: TextStyle(
          fontSize: R.f(context, 8),
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          color: const Color(0xFFFFA000),
        ),
      ),
    );
  }
}

// ==================== Category Tile ====================
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
  });

  final TeacherCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name =
        appState.isArabic ? category.nameAr : category.nameEn;
    final desc =
        appState.isArabic ? category.descAr : category.descEn;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        ornament: false,
        child: Row(
          children: [
            Container(
              width: R.s(context, 44),
              height: R.s(context, 44),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                category.icon,
                color: AppColors.gold,
                size: R.s(context, 20),
              ),
            ),
            SizedBox(width: R.s(context, 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: R.f(context, 13),
                      fontWeight: FontWeight.w700,
                      color: AppColors.softGold,
                    ),
                  ),
                  SizedBox(height: R.s(context, 2)),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: R.f(context, 10.5),
                      color: AppColors.cream.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.gold.withValues(alpha: 0.7),
              size: R.s(context, 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Message Bubble ====================
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: R.s(context, 8)),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: R.s(context, 28),
              height: R.s(context, 28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.deepGreen,
                border: Border.all(
                  color: AppColors.gold,
                  width: 1.4,
                ),
              ),
              child: Icon(
                Icons.school_rounded,
                color: AppColors.gold,
                size: R.s(context, 14),
              ),
            ),
            SizedBox(width: R.s(context, 6)),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(
                    ClipboardData(text: message.text));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.deepGreen,
                      content: Text(
                        appState.tr('copied'),
                        style:
                            const TextStyle(color: AppColors.cream),
                      ),
                    ),
                  );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: R.s(context, 12),
                  vertical: R.s(context, 10),
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isUser
                        ? AppColors.gold.withValues(alpha: 0.5)
                        : AppColors.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    fontSize: R.f(context, 12.5),
                    height: 1.7,
                    color: AppColors.cream,
                    fontWeight: isUser
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          if (isUser) SizedBox(width: R.s(context, 4)),
        ],
      ),
    );
  }
}

// ==================== Typing Bubble ====================
class _TypingBubble extends StatefulWidget {
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.s(context, 8)),
      child: Row(
        children: [
          Container(
            width: R.s(context, 28),
            height: R.s(context, 28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.deepGreen,
              border:
                  Border.all(color: AppColors.gold, width: 1.4),
            ),
            child: Icon(
              Icons.school_rounded,
              color: AppColors.gold,
              size: R.s(context, 14),
            ),
          ),
          SizedBox(width: R.s(context, 6)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: R.s(context, 14),
              vertical: R.s(context, 12),
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
              ),
            ),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                return Row(
                  children: List.generate(3, (i) {
                    final t = (_anim.value + i / 3) % 1.0;
                    final op = 0.3 + 0.7 * (1 - (t - 0.5).abs() * 2);
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.s(context, 2)),
                      child: Opacity(
                        opacity: op.clamp(0.2, 1.0),
                        child: Container(
                          width: R.s(context, 6),
                          height: R.s(context, 6),
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
