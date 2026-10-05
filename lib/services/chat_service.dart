import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/chat.dart';
import '../models/chat_message.dart';
import '../models/message_request.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('message_requests');

  // ============================================================
  // chatId = uid1_uid2 (مرتبين أبجدياً)
  // ============================================================
  static String chatIdFor(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // ============================================================
  // هل يمكن إرسال رسالة؟
  // (يجب أن يتابعه)
  // ============================================================
  Future<bool> canMessage({
    required String myUid,
    required String targetUid,
  }) async {
    try {
      final snap = await _db
          .collection('follows')
          .doc('${myUid}_$targetUid')
          .get();
      return snap.exists;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // الحصول على chat موجود (أو إنشاؤه)
  // ============================================================
  Future<String> getOrCreateChat({
    required String myUid,
    required String targetUid,
  }) async {
    final chatId = chatIdFor(myUid, targetUid);
    final ref = _chats.doc(chatId);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'participants': [myUid, targetUid],
        'lastMessage': '',
        'lastMessageAt': null,
        'lastMessageSenderUid': '',
        'unread': {myUid: 0, targetUid: 0},
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  // ============================================================
  // Stream — قائمة الشاتات للمستخدم
  // ============================================================
  Stream<List<Chat>> myChatsStream(String myUid) {
    return _chats
        .where('participants', arrayContains: myUid)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => Chat.fromMap(d.id, d.data()))
          .toList();
      // ترتيب: آخر رسالة أولاً
      list.sort((a, b) {
        final aT = a.lastMessageAt?.millisecondsSinceEpoch ?? 0;
        final bT = b.lastMessageAt?.millisecondsSinceEpoch ?? 0;
        return bT.compareTo(aT);
      });
      return list;
    });
  }

  // ============================================================
  // Stream — رسائل chat معيّن
  // ============================================================
  Stream<List<ChatMessage>> messagesStream(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => ChatMessage.fromMap(d.id, chatId, d.data()))
          .where((m) => !m.isDeleted)
          .toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  // ============================================================
  // Stream — chat واحد (للـ AppBar)
  // ============================================================
  Stream<Chat?> chatStream(String chatId) {
    return _chats.doc(chatId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return Chat.fromMap(snap.id, snap.data()!);
    });
  }

  // ============================================================
  // إرسال رسالة
  // ============================================================
  Future<void> sendMessage({
    required String chatId,
    required String senderUid,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.length > 2000) {
      throw ArgumentError('الرسالة طويلة جداً');
    }

    final chatRef = _chats.doc(chatId);
    final chatSnap = await chatRef.get();
    if (!chatSnap.exists) throw Exception('المحادثة غير موجودة');

    final participants =
        List<String>.from(chatSnap.data()?['participants'] ?? const []);
    if (!participants.contains(senderUid)) {
      throw Exception('غير مصرح');
    }

    final otherUid = participants.firstWhere(
      (p) => p != senderUid,
      orElse: () => '',
    );

    // 1) أضف الرسالة
    final msgRef = chatRef.collection('messages').doc();
    await msgRef.set({
      'senderUid': senderUid,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [senderUid],
      'isDeleted': false,
    });

    // 2) حدّث chat (lastMessage + unread)
    final currentUnread = (chatSnap.data()?['unread'] as Map?) ?? {};
    final otherUnread = (currentUnread[otherUid] as num?)?.toInt() ?? 0;

    await chatRef.update({
      'lastMessage': trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageSenderUid': senderUid,
      'unread': {
        ...currentUnread,
        otherUid: otherUnread + 1,
        senderUid: 0,
      },
    });
  }

  // ============================================================
  // تحديد الرسائل كمقروءة
  // ============================================================
  Future<void> markAsRead({
    required String chatId,
    required String myUid,
  }) async {
    final chatRef = _chats.doc(chatId);
    final chatSnap = await chatRef.get();
    if (!chatSnap.exists) return;

    final participants =
        List<String>.from(chatSnap.data()?['participants'] ?? const []);
    if (!participants.contains(myUid)) return;

    // 1) صفّر unread للمستخدم
    final currentUnread = (chatSnap.data()?['unread'] as Map?) ?? {};
    await chatRef.update({
      'unread': {
        ...currentUnread,
        myUid: 0,
      },
    });

    // 2) حدّث readBy للرسائل الأخيرة (آخر 50 رسالة غير مقروءة)
    final msgsSnap = await chatRef
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    final batch = _db.batch();
    for (final doc in msgsSnap.docs) {
      final readBy =
          List<String>.from(doc.data()['readBy'] ?? const []);
      if (!readBy.contains(myUid)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([myUid]),
        });
      }
    }
    await batch.commit();
  }

  // ============================================================
  // عدّاد الرسائل غير المقروءة (إجمالي)
  // ============================================================
  Stream<int> totalUnreadStream(String myUid) {
    return _chats
        .where('participants', arrayContains: myUid)
        .snapshots()
        .map((snap) {
      int total = 0;
      for (final doc in snap.docs) {
        final unread = (doc.data()['unread'] as Map?) ?? {};
        total += ((unread[myUid] as num?)?.toInt() ?? 0);
      }
      return total;
    });
  }

  // ============================================================
  // Message Requests
  // ============================================================
  Stream<List<MessageRequest>> pendingRequestsStream(String myUid) {
    return _requests
        .where('toUid', isEqualTo: myUid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => MessageRequest.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> sendMessageRequest({
    required String fromUid,
    required String toUid,
  }) async {
    final chatId = chatIdFor(fromUid, toUid);
    await _requests.doc(chatId).set({
      'fromUid': fromUid,
      'toUid': toUid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> hasPendingRequest({
    required String fromUid,
    required String toUid,
  }) async {
    final chatId = chatIdFor(fromUid, toUid);
    final snap = await _requests.doc(chatId).get();
    if (!snap.exists) return false;
    return snap.data()?['status'] == 'pending';
  }

  Future<void> acceptRequest(String chatId) async {
    await _requests.doc(chatId).update({'status': 'accepted'});
  }

  Future<void> rejectRequest(String chatId) async {
    await _requests.doc(chatId).delete();
  }

  // ============================================================
  // حذف chat (للمستخدم نفسه فقط، اختياري)
  // ============================================================
  Future<void> clearChatMessages(String chatId) async {
    try {
      final msgs = await _chats.doc(chatId).collection('messages').get();
      final batch = _db.batch();
      for (final doc in msgs.docs) {
        batch.update(doc.reference, {'isDeleted': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('clearChatMessages error: $e');
    }
  }
}

final chatService = ChatService.instance;
