import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'core/firebase_options.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
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
