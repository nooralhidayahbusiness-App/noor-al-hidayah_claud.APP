
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../models/chat.dart';
import '../models/message_request.dart';
import '../models/user_brief.dart';
import '../services/chat_service.dart';
import '../services/follow_service.dart';
import 'chat_screen.dart';

// ============ ترجمات ============
const Map<String, Map<String, String>> _clTr = {
  'ar': {
    'title': 'المحادثات',
    'empty': 'لا توجد محادثات بعد',
    'emptyDesc': 'ابدأ محادثة من صفحة أي مستخدم',
    'requests': 'طلبات الرسائل',
    'accept': 'قبول',
    'reject': 'رفض',
    'noMessages': 'لا رسائل',
    'userNotFound': 'مستخدم',
    'pending': 'طلب مرسل',
  },
  'en': {
    'title': 'Chats',
    'empty': 'No chats yet',
    'emptyDesc': 'Start a chat from any user profile',
    'requests': 'Message Requests',
    'accept': 'Accept',
    'reject': 'Reject',
    'noMessages': 'No messages',
    'userNotFound': 'User',
    'pending': 'Request sent',
  },
  'fr': {
    'title': 'Discussions',
    'empty': 'Aucune discussion',
    'emptyDesc': "Démarrez depuis le profil d'un utilisateur",
    'requests': 'Demandes de messages',
    'accept': 'Accepter',
    'reject': 'Refuser',
    'noMessages': 'Aucun message',
    'userNotFound': 'Utilisateur',
    'pending': 'Demande envoyée',
  },
  'ur': {
    'title': 'چیٹس',
    'empty': 'ابھی کوئی چیٹ نہیں',
    'emptyDesc': 'کسٹم صارف کی پروفائل سے شروع کریں',
    'requests': 'پیغام کی درخواستیں',
    'accept': 'قبول',
    'reject': 'مسترد',
    'noMessages': 'کوئی پیغام نہیں',
    'userNotFound': 'صارف',
    'pending': 'درخواست بھیجی',
  },
  'ne': {
    'title': 'च्याटहरू',
    'empty': 'अझै कुनै च्याट छैन',
    'emptyDesc': 'कुनै प्रयोगकर्ताको प्रोफाइलबाट सुरु गर्नुहोस्',
    'requests': 'सन्देश अनुरोधहरू',
    'accept': 'स्वीकार',
    'reject': 'अस्वीकार',
    'noMessages': 'कुनै सन्देश छैन',
    'userNotFound': 'प्रयोगकर्ता',
    'pending': 'अनुरोध पठाइयो',
  },
  'id': {
    'title': 'Obrolan',
    'empty': 'Belum ada obrolan',
    'emptyDesc': 'Mulai dari profil pengguna mana pun',
    'requests': 'Permintaan Pesan',
    'accept': 'Terima',
    'reject': 'Tolak',
    'noMessages': 'Tidak ada pesan',
    'userNotFound': 'Pengguna',
    'pending': 'Permintaan terkirim',
  },
  'ms': {
    'title': 'Sembang',
    'empty': 'Belum ada sembang',
    'emptyDesc': 'Mulakan dari profil mana-mana pengguna',
    'requests': 'Permintaan Mesej',
    'accept': 'Terima',
    'reject': 'Tolak',
    'noMessages': 'Tiada mesej',
    'userNotFound': 'Pengguna',
    'pending': 'Permintaan dihantar',
  },
};

String _cl(String key) {
  final m = _clTr[appState.languageCode] ?? _clTr['ar']!;
  return m[key] ?? key;
}

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
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
            body: _uid == null
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  )
                : StreamBuilder<List<Chat>>(
                    stream: chatService.myChatsStream(_uid!),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting &&
                          !snap.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                          ),
                        );
                      }

                      final chats = (snap.data ?? [])
                          .where((c) => c.lastMessage.isNotEmpty)
                          .toList();

                      return StreamBuilder<List<MessageRequest>>(
                        stream: chatService.pendingRequestsStream(_uid!),
                        builder: (context, reqSnap) {
                          final requests = reqSnap.data ?? [];

                          if (chats.isEmpty && requests.isEmpty) {
                            return _buildEmpty(context);
                          }

                          return ListView(
                            padding: EdgeInsets.symmetric(
                              vertical: R.s(context, 8),
                            ),
                            children: [
                              // ===== الطلبات =====
                              if (requests.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    R.s(context, 16),
                                    R.s(context, 8),
                                    R.s(context, 16),
                                    R.s(context, 4),
                                  ),
                                  child: Text(
                                    _cl('requests'),
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontSize: R.f(context, 13),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                for (final r in requests)
                                  _RequestTile(
                                    request: r,
                                    myUid: _uid!,
                                    onAccept: () async {
                                      await chatService
                                          .acceptRequest(r.chatId);
                                      if (mounted) setState(() {});
                                    },
                                    onReject: () async {
                                      await chatService
                                          .rejectRequest(r.chatId);
                                      if (mounted) setState(() {});
                                    },
                                  ),
                                Divider(
                                  color: AppColors.gold.withValues(alpha: 0.2),
                                  height: R.s(context, 20),
                                ),
                              ],

                              // ===== المحادثات =====
                              for (final chat in chats)
                                _ChatTile(
                                  chat: chat,
                                  myUid: _uid!,
                                  onTap: () => _openChat(chat),
                                ),
                            ],
                          );
                        },
                      );
                    },
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
      centerTitle: true,
      title: Text(
        _cl('title'),
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

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.s(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(R.s(context, 18)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withValues(alpha: 0.5),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: AppColors.gold,
                size: R.s(context, 42),
              ),
            ),
            SizedBox(height: R.s(context, 14)),
            Text(
              _cl('empty'),
              style: TextStyle(
                color: AppColors.softGold,
                fontSize: R.f(context, 15),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: R.s(context, 6)),
            Text(
              _cl('emptyDesc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.6),
                fontSize: R.f(context, 12),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(Chat chat) {
    final otherUid = chat.otherUid(_uid!);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chat.id,
          myUid: _uid!,
          otherUid: otherUid,
          otherName: '',
        ),
      ),
    );
  }
}

// ============================================================
// _ChatTile
// ============================================================
class _ChatTile extends StatelessWidget {
  final Chat chat;
  final String myUid;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.myUid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final otherUid = chat.otherUid(myUid);
    final unread = chat.unreadFor(myUid);

    return StreamBuilder<UserBrief?>(
      stream: FollowService().userBriefStream(otherUid),
      builder: (context, snap) {
        final user = snap.data;
        final name = user?.name ?? _cl('userNotFound');
        final avatar = user?.avatar ?? 'man';
        final photoBytes = user?.photoBytes;

        return InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: R.s(context, 14),
              vertical: R.s(context, 10),
            ),
            child: Row(
              children: [
                _ListAvatar(avatar: avatar, photoBytes: photoBytes),
                SizedBox(width: R.s(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.cream,
                          fontSize: R.f(context, 14),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: R.s(context, 3)),
                      Text(
                        chat.lastMessage.isEmpty
                            ? _cl('noMessages')
                            : chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: unread > 0
                              ? AppColors.gold
                              : AppColors.cream.withValues(alpha: 0.6),
                          fontSize: R.f(context, 12),
                          fontWeight: unread > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.s(context, 8),
                      vertical: R.s(context, 3),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: R.f(context, 11),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// _RequestTile
// ============================================================
class _RequestTile extends StatelessWidget {
  final MessageRequest request;
  final String myUid;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestTile({
    required this.request,
    required this.myUid,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserBrief?>(
      stream: FollowService().userBriefStream(request.fromUid),
      builder: (context, snap) {
        final user = snap.data;
        final name = user?.name ?? _cl('userNotFound');
        final avatar = user?.avatar ?? 'man';
        final photoBytes = user?.photoBytes;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: R.s(context, 14),
            vertical: R.s(context, 8),
          ),
          child: Row(
            children: [
              _ListAvatar(avatar: avatar, photoBytes: photoBytes),
              SizedBox(width: R.s(context, 12)),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.cream,
                    fontSize: R.f(context, 13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _SmallBtn(
                label: _cl('accept'),
                color: AppColors.gold,
                onTap: onAccept,
              ),
              SizedBox(width: R.s(context, 6)),
              _SmallBtn(
                label: _cl('reject'),
                color: Colors.redAccent,
                onTap: onReject,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// _SmallBtn
// ============================================================
class _SmallBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SmallBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 10),
          vertical: R.s(context, 6),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(R.s(context, 10)),
          border: Border.all(color: color, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: R.f(context, 11),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// _ListAvatar
// ============================================================
class _ListAvatar extends StatelessWidget {
  final String avatar;
  final Uint8List? photoBytes;

  const _ListAvatar({required this.avatar, this.photoBytes});

  @override
  Widget build(BuildContext context) {
    final size = R.s(context, 48);
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
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: ClipOval(child: child),
    );
  }
}
