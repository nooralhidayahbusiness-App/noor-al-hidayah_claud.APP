import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';

void main() {
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
