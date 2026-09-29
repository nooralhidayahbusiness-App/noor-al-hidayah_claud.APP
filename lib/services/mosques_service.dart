import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../models/mosque.dart';

class MosquesService {
  MosquesService._();
  static final MosquesService instance = MosquesService._();

  /// نلف الطلب بـ CORS proxy ليعمل على الويب.
  static const String _proxy = 'https://api.allorigins.win/raw?url=';
  static const String _overpass =
      'https://overpass-api.de/api/interpreter';

  Future<List<Mosque>> findNearby({
    required double latitude,
    required double longitude,
    int radiusMeters = 10000,
  }) async {
    final query = '[out:json][timeout:60];'
        'node["amenity"="place_of_worship"]["religion"="muslim"]'
        '(around:$radiusMeters,$latitude,$longitude);'
        'out;';

    final overpassUrl = Uri.parse(_overpass);
    final finalUrl = Uri.parse(
      '$_proxy${Uri.encodeComponent(overpassUrl.toString())}'
      '&data=${Uri.encodeComponent(query)}',
    );

    http.Response res;
    try {
      res = await http
          .get(
            finalUrl,
            headers: {'User-Agent': 'NoorAlHidayahApp/1.0'},
          )
          .timeout(const Duration(seconds: 45));
    } catch (e) {
      throw Exception('Network error: $e');
    }

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    // مع CORS proxy، قد يكون الرد بتنسيق غير مباشر.
    var body = res.body;
    if (!body.contains('"elements"')) {
      // محاولة فك التغليف
      try {
        final wrapped = json.decode(body);
        if (wrapped is Map && wrapped['contents'] != null) {
          body = wrapped['contents'] as String;
        }
      } catch (_) {}
    }

    if (!body.contains('"elements"')) {
      throw Exception('Invalid response from Overpass');
    }

    final data = json.decode(body) as Map<String, dynamic>;
    final elements = (data['elements'] as List?) ?? [];

    final list = <Mosque>[];
    for (final el in elements) {
      final e = el as Map<String, dynamic>;
      final tags = (e['tags'] as Map?) ?? {};

      final lat = (e['lat'] as num?)?.toDouble();
      final lng = (e['lon'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      final name = (tags['name:ar'] as String?) ??
          (tags['name'] as String?) ??
          (tags['name:en'] as String?) ??
          'مسجد';

      final address = _buildAddress(tags);
      final distKm = _haversine(latitude, longitude, lat, lng);
      final brg = _bearing(latitude, longitude, lat, lng);

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
  }

  String? _buildAddress(Map tags) {
    final parts = <String>[];
    final street = tags['addr:street'] as String?;
    final city = tags['addr:city'] as String?;
    if (street != null && street.isNotEmpty) parts.add(street);
    if (city != null && city.isNotEmpty) parts.add(city);
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _bearing(double lat1, double lng1, double lat2, double lng2) {
    final phi1 = _toRad(lat1);
    final phi2 = _toRad(lat2);
    final deltaLambda = _toRad(lng2 - lng1);
    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);
    final theta = math.atan2(y, x);
    return (_toDeg(theta) + 360) % 360;
  }

  double _toRad(double d) => d * math.pi / 180.0;
  double _toDeg(double r) => r * 180.0 / math.pi;
}

final mosquesService = MosquesService.instance;
