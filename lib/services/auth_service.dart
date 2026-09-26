import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Readable error keys (translated in strings_prayer.dart), so the UI never
/// shows Firebase's raw English error messages.
class AuthException implements Exception {
  const AuthException(this.key);
  final String key;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// قائمة إيميلات المالك (تحصل على شعار true.me.png تلقائياً).
  static const List<String> _ownerEmails = [
    'abdelrahmenbenromdhan11@gmail.com',
    'vevocom888@gmail.com',
    'nooralimanechannel@gmail.com',
    'nooralhidayahbusiness@gmail.com',
  ];

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
  Stream<User?> get authChanges => _auth.authStateChanges();

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  Map<String, dynamic> _buildInitialProfile(String email) {
    final isOwner = _ownerEmails.contains(email.toLowerCase());
    return {
      'name': '',
      'bio': '',
      'isPublic': true,
      'country': '',
      'verified': isOwner,
      'verifiedType': isOwner ? 'owner' : 'none',
      'faceScanDone': false,
    };
  }

  Future<void> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid != null) {
        await _userDoc(uid).set({
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'avatar': 'man',
          'profile': _buildInitialProfile(email.trim()),
          'stats': {
            'points': 0,
            'level': 1,
            'streak': 0,
            'lastActiveDate': null,
            'challengesCompleted': 0,
            'totalCorrectAnswers': 0,
            'quranKhatmas': 0,
            'aiTeacherScore': 0,
            'redeemedCoupons': <String>[],
          },
          'inventory': {
            'backgrounds': ['default'],
            'voices': ['default'],
            'themes': ['default'],
            'activeBackground': 'default',
            'activeVoice': 'default',
            'activeTheme': 'default',
          },
          'settings': {
            'language': 'ar',
            'theme': 'dark',
            'notifications': {
              'fajr': true,
              'dhuhr': true,
              'asr': true,
              'maghrib': true,
              'isha': true,
              'adhanEnabled': true,
              'adhanBeforeMinutes': 0,
              'dailyChallenge': true,
              'quranReminder': true,
              'dailyVerse': true,
            },
          },
          'progress': {
            'challenges': {},
            'quran': {},
            'aiTeacher': {},
          },
        }, SetOptions(merge: true));
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    } catch (e) {
      throw const AuthException('authErrGeneric');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    } catch (_) {
      throw const AuthException('authErrGeneric');
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Merges [data] into the current user's document (creates it if needed).
  Future<void> saveUserData(Map<String, dynamic> data) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _userDoc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> loadUserData() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final snap = await _userDoc(uid).get();
    return snap.data();
  }

  String _mapError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'authErrEmailInUse';
      case 'invalid-email':
        return 'authErrInvalidEmail';
      case 'weak-password':
        return 'authErrWeakPassword';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'authErrWrongCredentials';
      case 'too-many-requests':
        return 'authErrTooMany';
      case 'network-request-failed':
        return 'authErrNetwork';
      default:
        return 'authErrGeneric';
    }
  }
}

final AuthService authService = AuthService.instance;
