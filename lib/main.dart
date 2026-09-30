import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'core/firebase_options.dart';
import 'core/theme.dart';
import 'screens/adhan_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  } catch (_) {}
  try {
    await notificationService.init();
    // عند الضغط على إشعار الصلاة → افتح شاشة الأذان
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
  runApp(const NoorApp());
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
