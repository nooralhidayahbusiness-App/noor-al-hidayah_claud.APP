import 'package:cloud_firestore/cloud_firestore.dart';

class MessageRequest {
  final String chatId;
  final String fromUid;
  final String toUid;
  final String status; // pending / accepted / rejected
  final DateTime createdAt;

  const MessageRequest({
    required this.chatId,
    required this.fromUid,
    required this.toUid,
    required this.status,
    required this.createdAt,
  });

  factory MessageRequest.fromMap(String id, Map<String, dynamic> m) {
    return MessageRequest(
      chatId: id,
      fromUid: (m['fromUid'] as String?) ?? '',
      toUid: (m['toUid'] as String?) ?? '',
      status: (m['status'] as String?) ?? 'pending',
      createdAt:
          (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUid': fromUid,
      'toUid': toUid,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
