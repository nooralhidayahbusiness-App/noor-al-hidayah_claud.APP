import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../models/mosque.dart';

class MosquesService {
  MosquesService._();
  static final MosquesService instance = MosquesService._();

  static const List<String> _endpoints = [
  'https://overpass-api.de/api/interpreter',
  'https://overpass.kumi.systems/api/interpreter',
  'https://overpass.private.coffee/api/interpreter',
];

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

    http.Response? res;
Exception? lastError;

for (final endpoint in _endpoints) {
  try {
    final r = await http
        .post(
          Uri.parse(endpoint),
          headers: {
            'User-Agent': 'NoorAlHidayahApp/1.0',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {'data': query},
        )
        .timeout(const Duration(seconds: 25));
    if (r.statusCode == 200) {
      res = r;
      break;
    }
    lastError = Exception('HTTP ${r.statusCode}');
  } catch (e) {
    lastError = e is Exception ? e : Exception(e.toString());
  }
}

try {
  if (res == null) {
    throw lastError ?? Exception('All Overpass endpoints failed');
  }

      final data = json.decode(res.body) as Map<String, dynamic>;
      final elements = (data['elements'] as List?) ?? [];

      final list = <Mosque>[];
      for (final el in elements) {
        final e = el as Map<String, dynamic>;
        final tags = (e['tags'] as Map?) ?? {};

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
          latitude,
          longitude,
          lat,
          lng,
        );

        final brg = _bearing(
          latitude,
          longitude,
          lat,
          lng,
        );

        list.add(Mosque(
          id: e['id'].toString(),
          name: name,
          latitude: lat,
          longitude: lng,
          address: address,
          distanceKm: distKm,
          bearing: brg,
        ));
      }

      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return list;
    } catch (e) {
      throw Exception('Failed to fetch mosques: $e');
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

  double _haversine(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _bearing(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final phi1 = _toRad(lat1);
    final phi2 = _toRad(lat2);
    final deltaLambda = _toRad(lng2 - lng1);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final theta = math.atan2(y, x);
    return (_toDeg(theta) + 360) % 360;
  }

  double _toRad(double degrees) => degrees * math.pi / 180.0;
  double _toDeg(double radians) => radians * 180.0 / math.pi;
}

final mosquesService = MosquesService.instance;
