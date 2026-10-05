import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String chatId;
  final String senderUid;
  final String text;
  final DateTime createdAt;
  final List<String> readBy;
  final bool isDeleted;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderUid,
    required this.text,
    required this.createdAt,
    this.readBy = const [],
    this.isDeleted = false,
  });

  factory ChatMessage.fromMap(String id, String chatId, Map<String, dynamic> m) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      senderUid: (m['senderUid'] as String?) ?? '',
      text: (m['text'] as String?) ?? '',
      createdAt:
          (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(m['readBy'] ?? const []),
      isDeleted: (m['isDeleted'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'readBy': readBy,
      'isDeleted': isDeleted,
    };
  }

  bool isReadBy(String uid) => readBy.contains(uid);
  bool isMine(String uid) => senderUid == uid;
}
