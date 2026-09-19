import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/prayer_times_data.dart';

class PrayerServiceException implements Exception {
  const PrayerServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Fetches prayer times from the free Aladhan API.
class PrayerService {
  static const _host = 'api.aladhan.com';

  Future<PrayerTimesData> byCoordinates(double latitude, double longitude) {
    return _fetch('/v1/timings/${_today()}', {
      'latitude': '$latitude',
      'longitude': '$longitude',
    });
  }

  Future<PrayerTimesData> byAddress(String address) {
    return _fetch('/v1/timingsByAddress/${_today()}', {'address': address});
  }

  String _today() {
    final d = DateTime.now();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day-$month-${d.year}';
  }

  Future<PrayerTimesData> _fetch(String path, Map<String, String> query) async {
    try {
      final uri = Uri.https(_host, path, query);
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw const PrayerServiceException('server');
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PrayerTimesData.fromApi(json);
    } on PrayerServiceException {
      rethrow;
    } catch (_) {
      throw const PrayerServiceException('network');
    }
  }
}
