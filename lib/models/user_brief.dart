import 'dart:convert';
import 'dart:typed_data';

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
  final String avatar;
  final String gender;
  final String photoMode;
  final String bio;
  final String photoBase64;
  final String customPhotoBase64;
  final bool verified;
  final String verifiedType;
  final bool premiumActive;
  final DateTime? premiumExpiresAt;
  final bool isPublic;

  const UserBrief({
    required this.uid,
    required this.email,
    required this.name,
    required this.avatar,
    required this.gender,
    required this.photoMode,
    required this.bio,
    required this.photoBase64,
    required this.customPhotoBase64,
    required this.verified,
    required this.verifiedType,
    required this.premiumActive,
    required this.premiumExpiresAt,
    this.isPublic = true,
  });

  factory UserBrief.fromMap(String uid, Map<String, dynamic> map) {
    final profile = (map['profile'] as Map<String, dynamic>?) ?? const {};
    final email = (map['email'] as String?) ?? '';
    final emailLower = email.toLowerCase();
    final isOwnerEmail = kOwnerEmails.contains(emailLower);

    final premiumMap =
        (profile['premium'] as Map<String, dynamic>?) ?? const {};
    final premiumActive = (premiumMap['active'] as bool?) ?? false;
    final premiumExpTs = premiumMap['expiresAt'];
    DateTime? premiumExpiresAt;
    if (premiumExpTs != null) {
      try {
        premiumExpiresAt = (premiumExpTs as dynamic).toDate();
      } catch (_) {
        premiumExpiresAt = null;
      }
    }

    final avatar = (map['avatar'] as String?) ?? 'man';
    final gender = (profile['gender'] as String?) ?? avatar;

    return UserBrief(
      uid: uid,
      email: email,
      name: _cleanName(profile['name'] as String?),
      avatar: avatar,
      gender: gender,
      photoMode: (profile['photoMode'] as String?) ?? 'symbol',
      bio: (profile['bio'] as String?) ?? '',
      photoBase64: (profile['photoBase64'] as String?) ?? '',
      customPhotoBase64: (profile['customPhotoBase64'] as String?) ?? '',
      verified: isOwnerEmail || ((profile['verified'] as bool?) ?? false),
      verifiedType: isOwnerEmail
          ? 'owner'
          : ((profile['verifiedType'] as String?) ?? 'none'),
      premiumActive: premiumActive,
      premiumExpiresAt: premiumExpiresAt,
      isPublic: (profile['isPublic'] as bool?) ?? true,
    );
  }

  static String _cleanName(String? raw) {
    final t = (raw ?? '').trim();
    return t.isEmpty ? 'مستخدم' : t;
  }

  bool get isOwner => verifiedType == 'owner';

  bool get isPremium {
    if (!premiumActive) return false;
    if (premiumExpiresAt == null) return false;
    return premiumExpiresAt!.isAfter(DateTime.now());
  }

  bool get isVerified =>
      verified || isOwner || verifiedType == 'me' || verifiedType == 'user';

  List<String> get badges {
    if (isOwner) return const ['owner'];

    final list = <String>[];
    if (isPremium) list.add('premium');
    if (verified) {
      if (verifiedType == 'me') list.add('me');
      else if (verifiedType == 'user') list.add('user');
    }
    return list;
  }

  String get badgeType {
    if (isOwner) return 'owner';
    if (isPremium) return 'premium';
    if (verified) {
      if (verifiedType == 'me') return 'me';
      if (verifiedType == 'user') return 'user';
    }
    return 'none';
  }

  Uint8List? get customPhotoBytes {
    if (customPhotoBase64.isEmpty) return null;
    try {
      return base64Decode(customPhotoBase64);
    } catch (_) {
      return null;
    }
  }

  Uint8List? get verificationPhotoBytes {
    if (photoBase64.isEmpty) return null;
    try {
      return base64Decode(photoBase64);
    } catch (_) {
      return null;
    }
  }

  Uint8List? get displayPhotoBytes {
    if (photoMode == 'custom' && customPhotoBytes != null) {
      return customPhotoBytes;
    }
    return verificationPhotoBytes;
  }

  Uint8List? get photoBytes => displayPhotoBytes;

  static UserBrief empty(String uid) => UserBrief(
        uid: uid,
        email: '',
        name: 'مستخدم',
        avatar: 'man',
        gender: 'man',
        photoMode: 'symbol',
        bio: '',
        photoBase64: '',
        customPhotoBase64: '',
        verified: false,
        verifiedType: 'none',
        premiumActive: false,
        premiumExpiresAt: null,
        isPublic: true,
      );
}
