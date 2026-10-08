import 'dart:convert';

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

  // ✅ جديد: cache لمواقيت الصلاة
  static const _prayerCacheKey = 'prayer_times_cache_v2';

  Future<SavedLocation?> loadLocation() async {
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
    await _saveLocal(location);

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

  // ============================================================
  // ✅ cache لمواقيت الصلاة
  // ============================================================

  /// يحفظ JSON مواقيت الصلاة كـ cache.
  /// [locationKey] = "lat_lng" أو "address".
  Future<void> savePrayerCache(
    Map<String, dynamic> json,
    String locationKey,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = {
        'savedAt': DateTime.now().toIso8601String(),
        'locationKey': locationKey,
        'data': json,
      };
      await prefs.setString(_prayerCacheKey, jsonEncode(payload));
    } catch (e) {
      debugPrint('savePrayerCache error: $e');
    }
  }

  /// يعيد JSON مخزّن أو null.
  /// [maxAgeHours] = أقصى عمر للـ cache قبل اعتباره غير صالح.
  Future<Map<String, dynamic>?> loadPrayerCache(
    String locationKey, {
    int maxAgeHours = 24 * 7,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prayerCacheKey);
      if (raw == null) return null;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final savedKey = decoded['locationKey'] as String?;
      if (savedKey != locationKey) return null;

      final savedAt = DateTime.tryParse(decoded['savedAt'] as String? ?? '');
      if (savedAt == null) return null;
      if (DateTime.now().difference(savedAt).inHours > maxAgeHours) {
        return null;
      }

      return decoded['data'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('loadPrayerCache error: $e');
      return null;
    }
  }

  Future<void> clearPrayerCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prayerCacheKey);
    } catch (_) {}
  }
}
