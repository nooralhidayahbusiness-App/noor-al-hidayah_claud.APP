import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/prayer_times_data.dart';
import 'storage_service.dart';

class PrayerServiceException implements Exception {
  const PrayerServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Fetches prayer times from the free Aladhan API + caches offline.
class PrayerService {
  static const _host = 'api.aladhan.com';
  final StorageService _storage = StorageService();

  Future<PrayerTimesData> byCoordinates(double latitude, double longitude) {
    final key = 'lat_${latitude.toStringAsFixed(3)}_lng_${longitude.toStringAsFixed(3)}';
    return _fetchWithCache(
      '/v1/timings/${_today()}',
      {
        'latitude': '$latitude',
        'longitude': '$longitude',
      },
      key,
    );
  }

  Future<PrayerTimesData> byAddress(String address) {
    final key = 'addr_${address.trim().toLowerCase()}';
    return _fetchWithCache(
      '/v1/timingsByAddress/${_today()}',
      {'address': address},
      key,
    );
  }

  String _today() {
    final d = DateTime.now();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day-$month-${d.year}';
  }

  /// ✅ 1) جرّب الشبكة، 2) احفظ cache، 3) عند الفشل → استخدم cache.
  Future<PrayerTimesData> _fetchWithCache(
    String path,
    Map<String, String> query,
    String cacheKey,
  ) async {
    // 1) محاولة الشبكة
    try {
      final uri = Uri.https(_host, path, query);
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        // احفظ في cache
        await _storage.savePrayerCache(json, cacheKey);
        return PrayerTimesData.fromApi(json);
      }
      debugPrint('Prayer API status: ${response.statusCode}');
    } catch (e) {
      debugPrint('Prayer network error: $e');
    }

    // 2) فشل الشبكة → جرّب cache
    final cached = await _storage.loadPrayerCache(cacheKey);
    if (cached != null) {
      debugPrint('Using cached prayer times (offline)');
      return PrayerTimesData.fromApi(cached);
    }

    // 3) لا شبكة ولا cache → خطأ
    throw const PrayerServiceException('network');
  }
}
