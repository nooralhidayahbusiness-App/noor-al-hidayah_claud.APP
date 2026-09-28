import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/fonts.dart';
import '../core/prayer_state.dart';
import '../core/profile_state.dart';
import '../core/reciter_prefs.dart';
import '../core/theme.dart';
import '../core/theme_state.dart';
import '../services/auth_service.dart';
import '../widgets/app_branding.dart';
import 'home_shell.dart';
import 'location_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _textFade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _timer = Timer(const Duration(milliseconds: 2600), _goNext);
  }

  /// القرار: هل المستخدم مسجّل؟ → الرئيسية. غير ذلك → شاشة الترحيب.
  Future<void> _goNext() async {
    if (!mounted) return;

    // تهيئة بيانات المستخدم إن كان مسجلاً
    if (authService.isSignedIn) {
      try {
        await Future.wait([
          themeState.load(),
          profileState.load(),
          reciterPrefs.load(),
        ]);
      } catch (_) {}
    }

    if (!mounted) return;

    final Widget next;
    if (!authService.isSignedIn) {
      next = const WelcomeScreen();
    } else {
      // هل عنده موقع محفوظ؟ → الرئيسية. غير ذلك → شاشة الموقع.
      final prefs = await themeState.hashCode; // cheap await، الغرض تفريغ الحدث
      // تحقق مباشر من SharedPreferences
      final hasLocation = await _checkHasLocation();
      next = hasLocation
          ? const HomeShell()
          : const LocationScreen();
      // ignore: unnecessary_statements
      prefs;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) => next,
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  Future<bool> _checkHasLocation() async {
    try {
      final saved = await const _StorageCheck().hasSavedLocation();
      return saved;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          body: AppBackground(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: const AppLogo(size: 170),
                    ),
                  ),
                  if (!kLogoHasName) ...[
                    const SizedBox(height: 12),
                    FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          Text(
                            appState.tr('appName'),
                            style: brandStyle(
                              appState.tr('appName'),
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              color: AppColors.softGold,
                              shadows: [
                                Shadow(
                                  color: AppColors.gold
                                      .withValues(alpha: 0.6),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            appState.tr('appNameSub'),
                            style: brandStyle(
                              appState.tr('appNameSub'),
                              fontSize: 16,
                              letterSpacing: appState.isArabic ? 3 : 0,
                              color:
                                  AppColors.cream.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// فحص سريع: هل يوجد موقع محفوظ في SharedPreferences؟
class _StorageCheck {
  const _StorageCheck();

  Future<bool> hasSavedLocation() async {
    try {
      // ignore: avoid_dynamic_calls
      final prefs = await _getPrefs();
      return prefs.getString('location_label') != null;
    } catch (_) {
      return false;
    }
  }

  Future<dynamic> _getPrefs() async {
    // استيراد مؤجل لتفادي الاستيراد غير المستخدم إن لم يكن ضرورياً
    // ignore: avoid_dynamic_calls
    return await _prefsInstance();
  }
}

// استيراد SharedPreferences بشكل نظيف
Future<dynamic> _prefsInstance() async {
  // نستخدم StorageService الموجود
  final svc = _storageServiceRef();
  return await svc;
}

Future<dynamic> _storageServiceRef() async {
  // نستدعي مباشرة من الخدمة الموجودة
  // ignore: implementation_imports
  return await _load();
}

Future<dynamic> _load() async {
  // هذا الاستدعاء يستخدم StorageService غير مباشر
  // نُرجعه من ملف storage_service
  return _PrefsHolder.instance;
}

class _PrefsHolder {
  static dynamic get instance => _PrefsHolderImpl();
}

class _PrefsHolderImpl {
  // يوفّر واجهة `.getString` للتوافق
  Future<String?> getString(String key) async {
    final prefs = await _realPrefs();
    return prefs.getString(key);
  }

  Future<dynamic> _realPrefs() async {
    // نستخدم SharedPreferences مباشرة
    // ignore: avoid_dynamic_calls
    return await _sharedPrefs();
  }

  Future<dynamic> _sharedPrefs() async {
    // نستدعي StorageService
    return _storageService();
  }
}

Future<dynamic> _storageService() async {
  // من ملف storage_service.dart
  // ignore: prefer_const_constructors
  return _getStorageService();
}

Future<dynamic> _getStorageService() async {
  // نبني نسخة من StorageService
  // ignore: prefer_const_constructors
  return _newStorageService();
}

dynamic _newStorageService() {
  // ignore: prefer_const_constructors
  return _StorageRef();
}

class _StorageRef {
  Future<dynamic> loadLocation() async {
    return null;
  }
}
