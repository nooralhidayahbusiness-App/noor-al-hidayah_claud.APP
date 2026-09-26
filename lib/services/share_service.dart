import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_location.dart';
import 'auth_service.dart';

/// Keeps the chosen location locally AND synced to Firestore.
class StorageService {
  static const _lat = 'location_lat';
  static const _lng = 'location_lng';
  static const _address = 'location_address';
  static const _label = 'location_label';

  Future<SavedLocation?> loadLocation() async {
    // 1) نحاول نقرأ من Firestore أولاً
    try {
      if (authService.isSignedIn) {
        final data = await authService.loadUserData();
        if (data != null && data['location_label'] != null) {
          final loc = SavedLocation(
            label: data['location_label'] as String,
            latitude: (data['location_lat'] as num?)?.toDouble(),
            longitude: (data['location_lng'] as num?)?.toDouble(),
            address: data['location_address'] as String?,
          );
          await _saveLocal(loc);
          return loc;
        }
      }
    } catch (e) {
      debugPrint('StorageService.loadLocation remote error: $e');
    }

    // 2) ما فيه شي؟ نرجع للنسخة المحلية
    final prefs = await SharedPreferences.getInstance();
    final label = prefs.getString(_label);
    if (label == null) return null;
    return SavedLocation(
      label: label,
      latitude: prefs.getDouble(_lat),
      longitude: prefs.getDouble(_lng),
      address: prefs.getString(_address),
    );
  }

  Future<void> saveLocation(SavedLocation location) async {
    // 1) حفظ محلي
    await _saveLocal(location);

    // 2) حفظ في Firestore
    try {
      await authService.saveUserData({
        'location_label': location.label,
        'location_lat': location.latitude,
        'location_lng': location.longitude,
        'location_address': location.address,
      });
    } catch (e) {
      debugPrint('StorageService.saveLocation remote error: $e');
    }
  }

  Future<void> _saveLocal(SavedLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_label, location.label);
    final lat = location.latitude;
    final lng = location.longitude;
    if (lat != null && lng != null) {
      await prefs.setDouble(_lat, lat);
      await prefs.setDouble(_lng, lng);
      await prefs.remove(_address);
    } else {
      await prefs.remove(_lat);
      await prefs.remove(_lng);
      await prefs.setString(_address, location.address ?? location.label);
    }
  }
}
