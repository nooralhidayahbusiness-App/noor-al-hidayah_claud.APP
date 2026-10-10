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

  // cache قديم ليوم واحد (يبقى كاحتياط أخير)
  static const _prayerCacheKey = 'prayer_times_cache_v2';

  // ✅ جديد: تقويم مواقيت الصلاة لعدة أسابيع (للعمل بدون إنترنت)
  static const _calendarKey = 'prayer_calendar_v1';

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
  // cache قديم لمواقيت يوم واحد (احتياط)
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
      await prefs.remove(_calendarKey);
    } catch (_) {}
  }

  // ============================================================
  // ✅ تقويم مواقيت الصلاة (أيام متعددة)
  // المفتاح: التاريخ الميلادي بصيغة dd-MM-yyyy
  // ============================================================

  /// يحوّل "dd-MM-yyyy" إلى تاريخ.
  DateTime? _parseDateKey(String key) {
    final p = key.split('-');
    if (p.length != 3) return null;
    final d = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final y = int.tryParse(p[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y, m, d);
  }

  /// يحفظ أيام التقويم لموقع معيّن (يدمجها مع المحفوظ لنفس الموقع).
  Future<void> saveCalendarDays(
    String locationKey,
    Map<String, Map<String, dynamic>> days,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      Map<String, dynamic> merged = {};
      final raw = prefs.getString(_calendarKey);
      if (raw != null) {
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          if (decoded['locationKey'] == locationKey) {
            merged = Map<String, dynamic>.from(
              (decoded['days'] as Map?) ?? {},
            );
          }
        } catch (_) {}
      }

      merged.addAll(days);

      // نحذف الأيام القديمة (أقدم من أمس) لتقليل الحجم
      final now = DateTime.now();
      final cutoff = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
      merged.removeWhere((key, _) {
        final d = _parseDateKey(key);
        return d == null || d.isBefore(cutoff);
      });

      await prefs.setString(
        _calendarKey,
        jsonEncode({
          'locationKey': locationKey,
          'savedAt': DateTime.now().toIso8601String(),
          'days': merged,
        }),
      );
    } catch (e) {
      debugPrint('saveCalendarDays error: $e');
    }
  }

  /// يعيد بيانات يوم معيّن من التقويم المحفوظ (أو null).
  Future<Map<String, dynamic>?> loadCalendarDay(
    String locationKey,
    String dateKey,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_calendarKey);
      if (raw == null) return null;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded['locationKey'] != locationKey) return null;

      final days = decoded['days'] as Map?;
      final day = days?[dateKey];
      if (day is Map) return Map<String, dynamic>.from(day);
      return null;
    } catch (e) {
      debugPrint('loadCalendarDay error: $e');
      return null;
    }
  }

  /// عدد الأيام المحفوظة من اليوم فصاعداً (لمعرفة متى نحدّث التقويم).
  Future<int> calendarDaysAhead(String locationKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_calendarKey);
      if (raw == null) return 0;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded['locationKey'] != locationKey) return 0;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final days = (decoded['days'] as Map?) ?? {};

      var count = 0;
      for (final key in days.keys) {
        final d = _parseDateKey(key.toString());
        if (d != null && !d.isBefore(today)) count++;
      }
      return count;
    } catch (_) {
      return 0;
    }
  }
}
