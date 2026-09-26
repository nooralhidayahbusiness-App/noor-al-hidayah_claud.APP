import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// خدمة موحدة لكل بيانات المستخدم: الملف الشخصي، النقاط، المستويات،
/// المخزون (الخلفيات/الأصوات/الثيمات)، الإعدادات والتقدم.
class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid);
// =========================== COUPONS ===========================
/// هل استخدم المستخدم هذا الكود مسبقاً؟
Future<bool> hasUsedCoupon(String code) async {
  final doc = _doc;
  if (doc == null) return false;
  final snap = await doc.get();
  final stats = (snap.data()?['stats'] as Map?) ?? {};
  final used = (stats['redeemedCoupons'] as List?) ?? [];
  return used.contains(code);
}

/// سجّل استخدام الكود.
Future<void> markCouponUsed(String code) async {
  final doc = _doc;
  if (doc == null) return;
  await doc.set({
    'stats': {
      'redeemedCoupons': FieldValue.arrayUnion([code]),
    }
  }, SetOptions(merge: true));
}

// =========================== VERIFICATION ===========================
Future<void> setUserVerified({bool faceScan = false}) async {
  final doc = _doc;
  if (doc == null) return;
  await doc.set({
    'profile': {
      'verified': true,
      'verifiedType': 'user',
      'faceScanDone': faceScan,
    }
  }, SetOptions(merge: true));
}
  }

  // =========================== PROFILE ===========================
  Future<Map<String, dynamic>> loadProfile() async {
    final doc = _doc;
    if (doc == null) return {};
    final snap = await doc.get();
    return Map<String, dynamic>.from(
      (snap.data()?['profile'] as Map?) ?? {},
    );
  }

  Future<void> saveProfile({
    String? name,
    String? bio,
    bool? isPublic,
    String? country,
  }) async {
    final doc = _doc;
    if (doc == null) return;
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (bio != null) data['bio'] = bio;
    if (isPublic != null) data['isPublic'] = isPublic;
    if (country != null) data['country'] = country;
    if (data.isEmpty) return;
    await doc.set({
      'profile': data,
    }, SetOptions(merge: true));
  }

  // =========================== STATS / POINTS ===========================
  Future<Map<String, dynamic>> loadStats() async {
    final doc = _doc;
    if (doc == null) return {};
    final snap = await doc.get();
    return Map<String, dynamic>.from(
      (snap.data()?['stats'] as Map?) ?? {},
    );
  }

  /// يحسب المستوى من النقاط: كل مستوى يحتاج 100 * (مستواه) نقطة.
  static int levelFromPoints(int points) {
    // level 1: 0-99، level 2: 100-399، level 3: 400-899، level 4: 900-1599...
    // الصيغة: level = floor(sqrt(points / 100)) + 1
    return (points / 100).clamp(0, double.infinity).toInt();
  }

  /// يحسب عدد النقاط المطلوبة للمستوى القادم.
  static int pointsForNextLevel(int currentLevel) {
    return 100 * currentLevel * currentLevel;
  }

  Future<void> addPoints(int amount) async {
    final doc = _doc;
    if (doc == null || amount == 0) return;
    await doc.set({
      'stats': {'points': FieldValue.increment(amount)}
    }, SetOptions(merge: true));
    // تحديث المستوى تلقائياً
    await _recomputeLevel();
  }

  Future<void> _recomputeLevel() async {
    final doc = _doc;
    if (doc == null) return;
    final snap = await doc.get();
    final stats = (snap.data()?['stats'] as Map?) ?? {};
    final points = (stats['points'] as num?)?.toInt() ?? 0;
    final newLevel = (points / 100).toInt().clamp(1, 999);
    if (newLevel != (stats['level'] as int? ?? 1)) {
      await doc.set({
        'stats': {'level': newLevel}
      }, SetOptions(merge: true));
    }
  }

  Future<void> incrementStreak() async {
    final doc = _doc;
    if (doc == null) return;
    await doc.set({
      'stats': {'streak': FieldValue.increment(1)}
    }, SetOptions(merge: true));
  }

  // =========================== INVENTORY ===========================
  Future<Map<String, dynamic>> loadInventory() async {
    final doc = _doc;
    if (doc == null) return {};
    final snap = await doc.get();
    return Map<String, dynamic>.from(
      (snap.data()?['inventory'] as Map?) ?? {},
    );
  }

  Future<void> unlockItem(String type, String id) async {
    // type = backgrounds | voices | themes
    final doc = _doc;
    if (doc == null) return;
    await doc.set({
      'inventory': {
        type: FieldValue.arrayUnion([id]),
      }
    }, SetOptions(merge: true));
  }

  Future<void> setActive(String type, String id) async {
    // type = activeBackground | activeVoice | activeTheme
    final doc = _doc;
    if (doc == null) return;
    await doc.set({
      'inventory': {type: id}
    }, SetOptions(merge: true));
  }

  // =========================== SETTINGS ===========================
  Future<Map<String, dynamic>> loadSettings() async {
    final doc = _doc;
    if (doc == null) return {};
    final snap = await doc.get();
    return Map<String, dynamic>.from(
      (snap.data()?['settings'] as Map?) ?? {},
    );
  }

  Future<void> saveSettings(Map<String, dynamic> data) async {
    final doc = _doc;
    if (doc == null || data.isEmpty) return;
    await doc.set({
      'settings': data,
    }, SetOptions(merge: true));
  }

  // =========================== PROGRESS ===========================
  Future<Map<String, dynamic>> loadProgress(String section) async {
    final doc = _doc;
    if (doc == null) return {};
    final snap = await doc.get();
    final progress = (snap.data()?['progress'] as Map?) ?? {};
    return Map<String, dynamic>.from((progress[section] as Map?) ?? {});
  }

  Future<void> saveProgress(String section, Map<String, dynamic> data) async {
    final doc = _doc;
    if (doc == null || data.isEmpty) return;
    await doc.set({
      'progress': {section: data}
    }, SetOptions(merge: true));
  }
}

final UserService userService = UserService.instance;
