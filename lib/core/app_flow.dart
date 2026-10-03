import 'package:flutter/material.dart';

import '../screens/home_shell.dart';
import '../screens/location_screen.dart';
import '../screens/welcome_screen.dart';
import '../services/storage_service.dart';
import 'navigation.dart';

/// Where to go after the user signs in or signs up.
Future<void> goAfterAuth(BuildContext context) async {
  final saved = await StorageService().loadLocation();
  if (!context.mounted) return;
  if (saved == null) {
    Navigator.of(context).push(fadeRoute(const LocationScreen()));
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
