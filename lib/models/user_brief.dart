import 'dart:convert';
import 'dart:typed_data';

/// الإيميلات الأربعة للمالك — تُعطى 'owner' دائماً بغض النظر عن Firestore
const List<String> kOwnerEmails = [
  'abdelrahmenbenromdhan11@gmail.com',
  'vevocom888@gmail.com',
  'nooralimanechannel@gmail.com',
  'nooralhidayahbusiness@gmail.com',
];

class UserBrief {
  final String uid;
  final String email;
  final String name;
  final String avatar; // 'man' | 'woman'
  final bool verified;
  final String verifiedType; // 'owner' | 'me' | 'user' | 'none'
  final String bio;
  final String photoBase64;

  const UserBrief({
    required this.uid,
    required this.email,
    required this.name,
    required this.avatar,
    required this.verified,
    required this.verifiedType,
    required this.bio,
    required this.photoBase64,
  });

  factory UserBrief.fromMap(String uid, Map<String, dynamic> map) {
    final profile = (map['profile'] as Map<String, dynamic>?) ?? const {};
    final email = (map['email'] as String?) ?? '';
    final emailLower = email.toLowerCase();
    final isOwnerEmail = kOwnerEmails.contains(emailLower);

    return UserBrief(
      uid: uid,
      email: email,
      name: _cleanName(profile['name'] as String?),
      avatar: (map['avatar'] as String?) ?? 'man',
      // لو إيميل مالك → verified دائماً true
      verified: isOwnerEmail || ((profile['verified'] as bool?) ?? false),
      // لو إيميل مالك → verifiedType = 'owner' دائماً (نتخطى Firestore)
      verifiedType: isOwnerEmail
          ? 'owner'
          : ((profile['verifiedType'] as String?) ?? 'none'),
      bio: (profile['bio'] as String?) ?? '',
      photoBase64: (profile['photoBase64'] as String?) ?? '',
    );
  }

  static String _cleanName(String? raw) {
    final t = (raw ?? '').trim();
    return t.isEmpty ? 'مستخدم' : t;
  }

  /// نوع الشعار الفعلي — يفحص verified أولاً
  String get badgeType {
    if (!verified) return 'none';
    if (verifiedType == 'owner' ||
        verifiedType == 'me' ||
        verifiedType == 'user') {
      return verifiedType;
    }
    return 'user';
  }

  /// بايتات صورة التوثيق
  Uint8List? get photoBytes {
    if (photoBase64.isEmpty) return null;
    try {
      return base64Decode(photoBase64);
    } catch (_) {
      return null;
    }
  }

  static UserBrief empty(String uid) => UserBrief(
        uid: uid,
        email: '',
        name: 'مستخدم',
        avatar: 'man',
        verified: false,
        verifiedType: 'none',
        bio: '',
        photoBase64: '',
      );
}
