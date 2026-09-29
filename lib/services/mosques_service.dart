import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../models/mosque.dart';

class MosquesService {
  MosquesService._();
  static final MosquesService instance = MosquesService._();

  static const _endpoint = 'https://overpass-api.de/api/interpreter';

  /// يبحث عن المساجد حول نقطة معينة.
  /// [radiusMeters] نصف القطر بالأمتار (افتراضي 10000 = 10 كم).
  Future<List<Mosque>> findNearby({
    required double latitude,
    required double longitude,
    int radiusMeters = 10000,
  }) async {
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
);
out center tags;
''';

    try {
      final res = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'User-Agent': 'NoorAlHidayahApp/1.0',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {'data': query},
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode != 200) {
        throw Exception('Overpass HTTP ${res.statusCode}');
      }

      final data = json.decode(res.body) as Map<String, dynamic>;
      final elements = (data['elements'] as List?) ?? [];

      final list = <Mosque>[];
      for (final el in elements) {
        final e = el as Map<String, dynamic>;
        final tags = (e['tags'] as Map?) ?? {};

        // الإحداثيات (node له lat/lon، way له center).
        double? lat;
        double? lng;
        if (e['lat'] != null && e['lon'] != null) {
          lat = (e['lat'] as num).toDouble();
          lng = (e['lon'] as num).toDouble();
        } else if (e['center'] != null) {
          final c = e['center'] as Map;
          lat = (c['lat'] as num?)?.toDouble();
          lng = (c['lon'] as num?)?.toDouble();
        }

        if (lat == null || lng == null) continue;

        final name = (tags['name:ar'] as String?) ??
            (tags['name'] as String?) ??
            (tags['name:en'] as String?) ??
            'مسجد';

        final address = _buildAddress(tags);

        final distKm = _haversine(
          lat1: latitude,
          lng1: longitude,
          lat2: lat,
          lng2: lng,
        );

        final bearing = _bearing(
          lat1: latitude,
          lng1: longitude,
          lat2: lat,
          lng2: lng,
        );

        list.add(Mosque(
          id: e['id'].toString(),
          name: name,
          latitude: lat,
          longitude: lng,
          address: address,
          distanceKm: distKm,
          bearing: bearing,
        ));
      }

      // ترتيب حسب المسافة
      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return list;
    } catch (e) {
      throw Exception('فشل البحث عن المساجد: $e');
    }
  }

  String? _buildAddress(Map tags) {
    final parts = <String>[];
    final street = tags['addr:street'] as String?;
    final city = tags['addr:city'] as String?;
    final country = tags['addr:country'] as String?;
    if (street != null && street.isNotEmpty) parts.add(street);
    if (city != null && city.isNotEmpty) parts.add(city);
    if (country != null && country.isNotEmpty) parts.add(country);
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  /// المسافة بالكيلومتر (Haversine).
  double _haversine({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  /// الاتجاه بالدرجات من الشمال.
  double _bearing({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    final φ1 = _toRad(lat1);
    final φ2 = _toRad(lat2);
    final Δλ = _toRad(lng2 - lng1);
    final y = math.sin(Δλ) * math.cos(φ2);
    final x = math.cos(φ1) * math.sin(φ2) -
        math.sin(φ1) * math.cos(φ2) * math.cos(Δλ);
    final θ = math.atan2(y, x);
    return (_toDeg(θ) + 360) % 360;
  }

  double _toRad(double d) => d * math.pi / 180.0;
  double _toDeg(double r) => r * 180.0 / math.pi;
}

final mosquesService = MosquesService.instance;
