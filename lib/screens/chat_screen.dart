
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../models/chat_message.dart';
import '../models/user_brief.dart';
import '../services/chat_service.dart';
import '../services/follow_service.dart';
import '../widgets/animated_entry.dart';
import '../widgets/islamic_empty_state.dart';

// ============ ترجمات ============
const Map<String, Map<String, String>> _chatTr = {
  'ar': {
    'title': 'محادثة',
    'hint': 'اكتب رسالة...',
    'empty': 'ابدأ المحادثة بأول رسالة',
    'today': 'اليوم',
    'yesterday': 'أمس',
    'sendFailed': 'فشل إرسال الرسالة',
    'userNotFound': 'مستخدم',
  },
  'en': {
    'title': 'Chat',
    'hint': 'Type a message...',
    'empty': 'Start the conversation',
    'today': 'Today',
    'yesterday': 'Yesterday',
    'sendFailed': 'Failed to send',
    'userNotFound': 'User',
  },
  'fr': {
    'title': 'Discussion',
    'hint': 'Écrire un message...',
    'empty': 'Démarrez la conversation',
    'today': "Aujourd'hui",
    'yesterday': 'Hier',
    'sendFailed': "Échec de l'envoi",
    'userNotFound': 'Utilisateur',
  },
  'ur': {
    'title': 'چیٹ',
    'hint': 'پیغام لکھیں...',
    'empty': 'گفتگو شروع کریں',
    'today': 'آج',
    'yesterday': 'کل',
    'sendFailed': 'بھیجنے میں ناکام',
    'userNotFound': 'صارف',
  },
  'ne': {
    'title': 'च्याट',
    'hint': 'सन्देश लेख्नुहोस्...',
    'empty': 'कुराकानी सुरु गर्नुहोस्',
    'today': 'आज',
    'yesterday': 'हिजो',
    'sendFailed': 'पठाउन असफल',
    'userNotFound': 'प्रयोगकर्ता',
  },
  'id': {
    'title': 'Obrolan',
    'hint': 'Ketik pesan...',
    'empty': 'Mulai percakapan',
    'today': 'Hari ini',
    'yesterday': 'Kemarin',
    'sendFailed': 'Gagal mengirim',
    'userNotFound': 'Pengguna',
  },
  'ms': {
    'title': 'Sembang',
    'hint': 'Taip mesej...',
    'empty': 'Mulakan perbualan',
    'today': 'Hari ini',
    'yesterday': 'Semalam',
    'sendFailed': 'Gagal menghantar',
    'userNotFound': 'Pengguna',
  },
};

String _ct(String key) {
  final m = _chatTr[appState.languageCode] ?? _chatTr['ar']!;
  return m[key] ?? key;
}

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String myUid;
  final String otherUid;
  final String otherName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.myUid,
    required this.otherUid,
    required this.otherName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatService.markAsRead(chatId: widget.chatId, myUid: widget.myUid);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await chatService.sendMessage(
        chatId: widget.chatId,
        senderUid: widget.myUid,
        text: text,
      );
      _ctrl.clear();
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_ct('sendFailed')}: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
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
            backgroundColor: AppColors.deepGreen,
            appBar: _buildAppBar(context),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(child: _buildMessages(context)),
                  _buildInput(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.green,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.cream),
      title: _buildAppBarTitle(context),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return StreamBuilder<UserBrief?>(
      stream: FollowService().userBriefStream(widget.otherUid),
      builder: (context, snap) {
        final user = snap.data;
        final name = user?.name ?? widget.otherName;
        final avatar = user?.avatar ?? 'man';

        return Row(
          children: [
            _MiniAvatar(avatar: avatar, photoBytes: user?.photoBytes),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name.isEmpty ? _ct('userNotFound') : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.softGold,
                      fontSize: R.f(context, 15),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessages(BuildContext context) {
    return StreamBuilder<List<ChatMessage>>(
      stream: chatService.messagesStream(widget.chatId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting &&
            !snap.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        final messages = snap.data ?? [];
        if (messages.isEmpty) {
          return IslamicEmptyState(
            icon: Icons.chat_bubble_outline,
            title: _ct('empty'),
            message: '',
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          chatService.markAsRead(
            chatId: widget.chatId,
            myUid: widget.myUid,
          );
        });

        return ListView.builder(
          controller: _scrollCtrl,
          padding: EdgeInsets.symmetric(
            horizontal: R.s(context, 12),
            vertical: R.s(context, 10),
          ),
          itemCount: messages.length,
          itemBuilder: (context, i) {
            final m = messages[i];
            final isMine = m.isMine(widget.myUid);

            final prev = i > 0 ? messages[i - 1] : null;
            final showDate = _shouldShowDate(prev, m);

            return Column(
              children: [
                if (showDate) _DateLabel(date: m.createdAt),
                AnimatedEntry(
                  duration: const Duration(milliseconds: 250),
                  slideOffset: 8,
                  child: _MessageBubble(
                    message: m,
                    isMine: isMine,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.s(context, 10)),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: R.s(context, 14),
                vertical: R.s(context, 6),
              ),
              decoration: BoxDecoration(
                color: AppColors.deepGreen.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(R.s(context, 22)),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                maxLines: 5,
                minLines: 1,
                maxLength: 2000,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  color: AppColors.cream,
                  fontSize: R.f(context, 14),
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: _ct('hint'),
                  hintStyle: TextStyle(
                    color: AppColors.cream.withValues(alpha: 0.4),
                    fontSize: R.f(context, 13),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  counterText: '',
                ),
              ),
            ),
          ),
          SizedBox(width: R.s(context, 8)),
          InkWell(
            onTap: _sending ? null : _send,
            borderRadius: BorderRadius.circular(R.s(context, 24)),
            child: Container(
              width: R.s(context, 46),
              height: R.s(context, 46),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.softGold],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.45),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: _sending
                  ? Padding(
                      padding: EdgeInsets.all(R.s(context, 13)),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.deepGreen,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: AppColors.deepGreen,
                      size: R.s(context, 20),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static bool _shouldShowDate(ChatMessage? prev, ChatMessage curr) {
    if (prev == null) return true;
    final pd = DateTime(
        prev.createdAt.year, prev.createdAt.month, prev.createdAt.day);
    final cd = DateTime(
        curr.createdAt.year, curr.createdAt.month, curr.createdAt.day);
    return pd != cd;
  }
}

// ============================================================
// _MessageBubble — فقاعة أنيقة مع tail
// ============================================================
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: R.s(context, 3)),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: R.s(context, 14),
                vertical: R.s(context, 10),
              ),
              decoration: BoxDecoration(
                gradient: isMine
                    ? const LinearGradient(
                        colors: [AppColors.gold, AppColors.softGold],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      )
                    : null,
                color: isMine
                    ? null
                    : AppColors.green.withValues(alpha: 0.85),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(R.s(context, 18)),
                  topRight: Radius.circular(R.s(context, 18)),
                  bottomLeft: Radius.circular(
                    isMine ? R.s(context, 18) : R.s(context, 4),
                  ),
                  bottomRight: Radius.circular(
                    isMine ? R.s(context, 4) : R.s(context, 18),
                  ),
                ),
                border: isMine
                    ? null
                    : Border.all(
                        color: AppColors.gold.withValues(alpha: 0.25),
                      ),
                boxShadow: isMine
                    ? [
                        BoxShadow(
                          color:
                              AppColors.gold.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color:
                      isMine ? AppColors.deepGreen : AppColors.cream,
                  fontSize: R.f(context, 14),
                  height: 1.45,
                  fontWeight:
                      isMine ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// _DateLabel — فاصل التاريخ
// ============================================================
class _DateLabel extends StatelessWidget {
  final DateTime date;

  const _DateLabel({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);

    String label;
    if (d == today) {
      label = _ct('today');
    } else if (d == today.subtract(const Duration(days: 1))) {
      label = _ct('yesterday');
    } else {
      label = '${d.day}/${d.month}/${d.year}';
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: R.s(context, 12)),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.gold.withValues(alpha: 0.2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: R.s(context, 10)),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: R.s(context, 12),
                vertical: R.s(context, 4),
              ),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(R.s(context, 12)),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.softGold.withValues(alpha: 0.9),
                  fontSize: R.f(context, 11),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.gold.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// _MiniAvatar
// ============================================================
class _MiniAvatar extends StatelessWidget {
  final String avatar;
  final Uint8List? photoBytes;

  const _MiniAvatar({required this.avatar, this.photoBytes});

  @override
  Widget build(BuildContext context) {
    final size = R.s(context, 40);
    final fallback = avatar == 'woman'
        ? 'assets/images/hijab.png'
        : 'assets/images/arabian.png';

    Widget child;
    if (photoBytes != null && photoBytes!.isNotEmpty) {
      child = Image.memory(
        photoBytes!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => Image.asset(
          fallback,
          fit: BoxFit.cover,
        ),
      );
    } else {
      child = Image.asset(
        fallback,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.person,
          color: AppColors.gold,
          size: size * 0.5,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipOval(child: child),
    );
  }
}
