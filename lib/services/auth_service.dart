import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Readable error keys
class AuthException implements Exception {
  const AuthException(this.key);
  final String key;
}

/// يُستدعى عند signOut
typedef SignOutHandler = Future<void> Function();

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// قائمة إيميلات المالك
  static const List<String> _ownerEmails = [
    'abdelrahmenbenromdhan11@gmail.com',
    'vevocom888@gmail.com',
    'nooralimanechannel@gmail.com',
    'nooralhidayahbusiness@gmail.com',
  ];

  // ============================================================
  // SignOut Handlers
  // ============================================================
  final List<SignOutHandler> _signOutHandlers = [];

  void addSignOutHandler(SignOutHandler handler) {
    if (!_signOutHandlers.contains(handler)) {
      _signOutHandlers.add(handler);
    }
  }

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
  Stream<User?> get authChanges => _auth.authStateChanges();

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  bool get isOwner {
    final email = _auth.currentUser?.email?.toLowerCase();
    if (email == null) return false;
    return _ownerEmails.contains(email);
  }

  // ============================================================
  // Initial user doc (مشترك بين email & google)
  // ============================================================
  Map<String, dynamic> _buildInitialProfile(String email) {
    final isOwner = _ownerEmails.contains(email.toLowerCase());
    return {
      'name': '',
      'bio': '',
      'isPublic': true,
      'country': '',
      'gender': '',
      'photoMode': 'symbol',
      'customPhotoBase64': '',
      'verified': isOwner,
      'verifiedType': isOwner ? 'owner' : 'none',
      'faceScanDone': false,
      'setupComplete': false,
    };
  }

  Future<void> _createInitialUserDoc({
    required String uid,
    required String email,
  }) async {
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

  // ============================================================
  // Register (Email/Password)
  // ============================================================
  Future<void> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid != null) {
        await _createInitialUserDoc(uid: uid, email: email);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    } catch (e) {
      throw const AuthException('authErrGeneric');
    }
  }

  // ============================================================
  // Login (Email/Password)
  // ============================================================
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

  // ============================================================
  // Google Sign-In
  // ============================================================
  /// يرجّع true لو نجح الدخول، false لو ألغى المستخدم.
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // المستخدم أغلق نافذة الاختيار
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final uid = userCredential.user?.uid;
      final isNew = userCredential.additionalUserInfo?.isNewUser ?? false;

      // لو مستخدم جديد → أنشئ ملفه
      if (uid != null && isNew) {
        await _createInitialUserDoc(
          uid: uid,
          email: userCredential.user!.email ?? '',
        );
      }

      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      throw const AuthException('authErrGeneric');
    }
  }

  // ============================================================
  // SignOut
  // ============================================================
  Future<void> signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
    for (final handler in _signOutHandlers) {
      try {
        await handler();
      } catch (e) {
        debugPrint('SignOut handler error: $e');
      }
    }
  }

  // ============================================================
  // Data access
  // ============================================================
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
      case 'account-exists-with-different-credential':
        return 'authErrEmailInUse';
      default:
        return 'authErrGeneric';
    }
  }
}

final AuthService authService = AuthService.instance;
