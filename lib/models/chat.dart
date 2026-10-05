import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String lastMessageSenderUid;
  final Map<String, int> unread;
  final DateTime createdAt;

  const Chat({
    required this.id,
    required this.participants,
    required this.lastMessage,
    this.lastMessageAt,
    required this.lastMessageSenderUid,
    this.unread = const {},
    required this.createdAt,
  });

  factory Chat.fromMap(String id, Map<String, dynamic> m) {
    return Chat(
      id: id,
      participants: List<String>.from(m['participants'] ?? const []),
      lastMessage: (m['lastMessage'] as String?) ?? '',
      lastMessageAt: (m['lastMessageAt'] as Timestamp?)?.toDate(),
      lastMessageSenderUid: (m['lastMessageSenderUid'] as String?) ?? '',
      unread: _parseUnread(m['unread']),
      createdAt:
          (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, int> _parseUnread(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    }
    return {};
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageAt':
          lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'lastMessageSenderUid': lastMessageSenderUid,
      'unread': unread,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// الـ uid الآخر
  String otherUid(String myUid) {
    return participants.firstWhere(
      (p) => p != myUid,
      orElse: () => '',
    );
  }

  int unreadFor(String uid) => unread[uid] ?? 0;
}
