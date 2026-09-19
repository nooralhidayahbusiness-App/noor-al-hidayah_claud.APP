import 'package:flutter/material.dart';

import '../screens/location_screen.dart';
import '../screens/prayer_times_screen.dart';
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
      fadeRoute(const PrayerTimesScreen()),
      (route) => false,
    );
  }
}
