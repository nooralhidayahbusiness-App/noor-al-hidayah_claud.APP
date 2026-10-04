import 'package:flutter/material.dart';

import '../screens/gender_select_screen.dart';
import '../screens/home_shell.dart';
import '../screens/location_screen.dart';
import '../screens/welcome_screen.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'navigation.dart';

/// Where to go after the user signs in or signs up.
Future<void> goAfterAuth(BuildContext context) async {
  // 1) فحص هل أكمل المستخدم الإعداد (الاسم + الجنس)
  bool setupComplete = false;
  try {
    final data = await authService.loadUserData();
    final profile = (data?['profile'] as Map?) ?? {};
    setupComplete = (profile['setupComplete'] as bool?) ?? false;
  } catch (_) {}

  if (!context.mounted) return;

  // 2) لو ما أكمل الإعداد → شاشة اختيار الجنس
  if (!setupComplete) {
    Navigator.of(context).pushAndRemoveUntil(
      fadeRoute(const GenderSelectScreen()),
      (route) => false,
    );
    return;
  }

  // 3) فحص الموقع
  final saved = await StorageService().loadLocation();
  if (!context.mounted) return;

  if (saved == null) {
    Navigator.of(context).pushAndRemoveUntil(
      fadeRoute(const LocationScreen()),
      (route) => false,
    );
  } else {
    Navigator.of(context).pushAndRemoveUntil(
      fadeRoute(const HomeShell()),
      (route) => false,
    );
  }
}

/// Where to go after the user signs out.
Future<void> goAfterSignOut(BuildContext context) async {
  Navigator.of(context).pushAndRemoveUntil(
    fadeRoute(const WelcomeScreen()),
    (route) => false,
  );
}

void openLocationPicker(BuildContext context) {
  Navigator.of(context).push(fadeRoute(const LocationScreen()));
}
