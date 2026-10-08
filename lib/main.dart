import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'core/firebase_options.dart';
import 'core/theme.dart';
import 'screens/adhan_screen.dart';
import 'screens/splash_screen.dart';
import 'services/adhan_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/push_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Firebase
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  } catch (_) {}

  // 2) الإشعارات المحلية
  try {
    await notificationService.init();
    notificationService.onPrayerTap = (prayerKey, time) {
      final nav = navigatorKey.currentState;
      if (nav == null) return;
      nav.push(
        MaterialPageRoute(
          builder: (_) => AdhanScreen(
            prayerKey: prayerKey,
            prayerTime: time,
          ),
        ),
      );
    };
  } catch (_) {}

  // 3) خدمة الأذان
  try {
    await adhanService.init();
  } catch (_) {}

  // 4) راقب تسجيل الدخول
  authService.authChanges.listen((user) {
    if (user != null) {
      pushService.saveTokenForCurrentUser();
    }
  });

  // 5) شغّل التطبيق
  runApp(const NoorApp());

  // 6) OneSignal بعد runApp
  Future.microtask(() async {
    try {
      await pushService.init();
    } catch (_) {}
  });
}

class NoorApp extends StatelessWidget {
  const NoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (ctx, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'نور الهداية',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          builder: (context, child) => Directionality(
            textDirection: appState.direction,
            child: child!,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
