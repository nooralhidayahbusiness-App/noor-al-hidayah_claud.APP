import 'dart:async';
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

/// Fetches prayer times from the free Aladhan API.
///
/// ✅ يحمّل تقويم الشهر كاملاً (واللاحق عند اقتراب نهايته) ويحفظه،
/// فيعمل التطبيق أسابيع بدون إنترنت.
class PrayerService {
  static const _host = 'api.aladhan.com';
  final StorageService _storage = StorageService();

  /// عند بقاء أقل من هذا العدد من الأيام المحفوظة نحدّث التقويم بالخلفية.
  static const int _refreshBelowDays = 10;

  Future<PrayerTimesData> byCoordinates(double latitude, double longitude) {
    final key =
        'lat_${latitude.toStringAsFixed(3)}_lng_${longitude.toStringAsFixed(3)}';
    return _load(
      locationKey: key,
      calendarPath: (y, m) => '/v1/calendar/$y/$m',
      todayPath: '/v1/timings/${_today()}',
      query: {
        'latitude': '$latitude',
        'longitude': '$longitude',
      },
    );
  }

  Future<PrayerTimesData> byAddress(String address) {
    final key = 'addr_${address.trim().toLowerCase()}';
    return _load(
      locationKey: key,
      calendarPath: (y, m) => '/v1/calendarByAddress/$y/$m',
      todayPath: '/v1/timingsByAddress/${_today()}',
      query: {'address': address},
    );
  }

  String _today() {
    final d = DateTime.now();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day-$month-${d.year}';
  }

  Future<PrayerTimesData> _load({
    required String locationKey,
    required String Function(int year, int month) calendarPath,
    required String todayPath,
    required Map<String, String> query,
  }) async {
    final todayKey = _today();

    // 1) التقويم المحفوظ (أسرع ويعمل بدون إنترنت)
    final cachedDay = await _storage.loadCalendarDay(locationKey, todayKey);
    if (cachedDay != null) {
      try {
        final data = PrayerTimesData.fromApi({'data': cachedDay});

        // تحديث التقويم بالخلفية إذا قارب على النفاد
        final ahead = await _storage.calendarDaysAhead(locationKey);
        if (ahead < _refreshBelowDays) {
          unawaited(_fetchCalendar(locationKey, calendarPath, query));
        }
        return data;
      } catch (e) {
        debugPrint('Cached calendar day invalid: $e');
      }
    }

    // 2) لا يوجد تقويم → حمّله من الشبكة
    final ok = await _fetchCalendar(locationKey, calendarPath, query);
    if (ok) {
      final fresh = await _storage.loadCalendarDay(locationKey, todayKey);
      if (fresh != null) {
        try {
          return PrayerTimesData.fromApi({'data': fresh});
        } catch (e) {
          debugPrint('Fresh calendar day invalid: $e');
        }
      }
    }

    // 3) فشل التقويم → مواقيت اليوم فقط من الشبكة
    try {
      final uri = Uri.https(_host, todayPath, query);
      final response =
          await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        await _storage.savePrayerCache(json, locationKey);
        return PrayerTimesData.fromApi(json);
      }
      debugPrint('Prayer API status: ${response.statusCode}');
    } catch (e) {
      debugPrint('Prayer network error: $e');
    }

    // 4) احتياط أخير: cache قديم ليوم واحد
    final legacy = await _storage.loadPrayerCache(locationKey);
    if (legacy != null) {
      debugPrint('Using legacy cached prayer times (offline)');
      return PrayerTimesData.fromApi(legacy);
    }

    throw const PrayerServiceException('network');
  }

  /// يحمّل تقويم الشهر الحالي (والتالي إذا كنا في النصف الثاني) ويحفظه.
  Future<bool> _fetchCalendar(
    String locationKey,
    String Function(int year, int month) calendarPath,
    Map<String, String> query,
  ) async {
    final now = DateTime.now();
    final months = <DateTime>[DateTime(now.year, now.month)];
    if (now.day >= 15) {
      // DateTime يتعامل مع الشهر 13 كيناير السنة التالية
      months.add(DateTime(now.year, now.month + 1));
    }

    final days = <String, Map<String, dynamic>>{};

    for (final m in months) {
      try {
        final uri = Uri.https(_host, calendarPath(m.year, m.month), query);
        final response =
            await http.get(uri).timeout(const Duration(seconds: 20));
        if (response.statusCode != 200) {
          debugPrint('Calendar API status: ${response.statusCode}');
          continue;
        }

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (json['data'] as List?) ?? [];

        for (final item in list) {
          if (item is! Map) continue;
          final date = item['date'];
          final timings = item['timings'];
          if (date is! Map || timings is! Map) continue;

          final gregorian = date['gregorian'];
          final String? key =
              gregorian is Map ? (gregorian['date'] as String?) : null;
          if (key == null) continue;

          // نحفظ ما نحتاجه فقط (بدون meta) لتقليل الحجم
          days[key] = {'timings': timings, 'date': date};
        }
      } catch (e) {
        debugPrint('Calendar fetch error: $e');
      }
    }

    if (days.isEmpty) return false;

    await _storage.saveCalendarDays(locationKey, days);
    debugPrint('[PRAYER] Calendar cached: ${days.length} days');
    return true;
  }
}
