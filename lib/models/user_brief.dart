/// نموذج مختصر لبيانات مستخدم — يُستخدم في:
/// - قائمة المتابعين/المتابَعين
/// - البطاقات في المجتمع
/// - الإشعارات
class UserBrief {
  final String uid;
  final String email;
  final String name;
  final String avatar; // 'man' | 'woman'
  final bool verified;
  final String bio;

  const UserBrief({
    required this.uid,
    required this.email,
    required this.name,
    required this.avatar,
    required this.verified,
    required this.bio,
  });

  factory UserBrief.fromMap(String uid, Map<String, dynamic> map) {
    final profile = (map['profile'] as Map<String, dynamic>?) ?? const {};
    return UserBrief(
      uid: uid,
      email: (map['email'] as String?) ?? '',
      name: _cleanName(profile['name'] as String?),
      avatar: (map['avatar'] as String?) ?? 'man',
      verified: (profile['verified'] as bool?) ?? false,
      bio: (profile['bio'] as String?) ?? '',
    );
  }

  static String _cleanName(String? raw) {
    final t = (raw ?? '').trim();
    return t.isEmpty ? 'مستخدم' : t;
  }

  /// قيم افتراضية عند عدم وجود بيانات
  static UserBrief empty(String uid) => UserBrief(
        uid: uid,
        email: '',
        name: 'مستخدم',
        avatar: 'man',
        verified: false,
        bio: '',
      );
}
