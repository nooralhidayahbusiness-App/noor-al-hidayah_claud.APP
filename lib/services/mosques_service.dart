import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mosque.dart';

class MosquesService {
  MosquesService._();
  static final MosquesService instance = MosquesService._();

  /// عدة خوادم Overpass — إذا فشل الأول ننتقل للتالي تلقائياً.
  static const List<String> _endpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
  ];

  static const String _cacheKey = 'mosques_cache_v1';

  /// أقصى عدد مساجد تُعرض (الأقرب أولاً) للحفاظ على سرعة الخريطة.
  static const int _maxResults = 80;

  Future<List<Mosque>> findNearby({
    required double latitude,
    required double longitude,
    int radiusMeters = 10000,
  }) async {
    // nwr = نقاط + مبانٍ + علاقات (كثير من المساجد مرسومة كمبنى وليس نقطة)
    final query = '[out:json][timeout:25];'
        'nwr["amenity"="place_of_worship"]["religion"="muslim"]'
        '(around:$radiusMeters,$latitude,$longitude);'
        'out tags center;';

    final cacheId = _cacheId(latitude, longitude, radiusMeters);

    String? lastError;
    for (final endpoint in _endpoints) {
      try {
        final res = await http.post(
          Uri.parse(endpoint),
          headers: {'User-Agent': 'NoorAlHidayahApp/1.0'},
          body: {'data': query},
        ).timeout(const Duration(seconds: 25));

        if (res.statusCode != 200) {
          lastError = 'HTTP ${res.statusCode}';
          debugPrint('[MOSQUES] $endpoint → ${res.statusCode}');
          continue;
        }

        final data = json.decode(utf8.decode(res.bodyBytes))
            as Map<String, dynamic>;
        final elements = (data['elements'] as List?) ?? [];
        final raw = _parseRaw(elements);

        await _saveCache(cacheId, raw);
        return _build(raw, latitude, longitude);
      } catch (e) {
        lastError = e.toString();
        debugPrint('[MOSQUES] $endpoint failed: $e');
      }
    }

    // كل الخوادم فشلت → استخدم آخر نتيجة محفوظة لنفس المنطقة
    final cached = await _loadCache(cacheId);
    if (cached != null) {
      debugPrint('[MOSQUES] using cached results');
      return _build(cached, latitude, longitude);
    }

    throw Exception(lastError ?? 'Network error');
  }

  // ============================================================
  // تحويل عناصر Overpass إلى بيانات خام مبسّطة
  // ============================================================
  List<Map<String, dynamic>> _parseRaw(List elements) {
    final out = <Map<String, dynamic>>[];
    for (final el in elements) {
      if (el is! Map) continue;
      final e = Map<String, dynamic>.from(el);
      final tags = (e['tags'] as Map?) ?? {};

      double? lat = (e['lat'] as num?)?.toDouble();
      double? lng = (e['lon'] as num?)?.toDouble();

      // المباني والعلاقات: الإحداثيات داخل center
      final center = e['center'];
      if ((lat == null || lng == null) && center is Map) {
        lat = (center['lat'] as num?)?.toDouble();
        lng = (center['lon'] as num?)?.toDouble();
      }
      if (lat == null || lng == null) continue;

      final name = (tags['name:ar'] as String?) ??
          (tags['name'] as String?) ??
          (tags['name:en'] as String?) ??
          'مسجد';

      out.add({
        'id': '${e['type']}_${e['id']}',
        'name': name,
        'lat': lat,
        'lng': lng,
        'address': _buildAddress(tags),
      });
    }
    return out;
  }

  List<Mosque> _build(
    List<Map<String, dynamic>> raw,
    double latitude,
    double longitude,
  ) {
    final list = <Mosque>[];
    for (final r in raw) {
      final lat = (r['lat'] as num).toDouble();
      final lng = (r['lng'] as num).toDouble();
      list.add(Mosque(
        id: r['id'].toString(),
        name: r['name'].toString(),
        latitude: lat,
        longitude: lng,
        address: r['address'] as String?,
        distanceKm: _haversine(latitude, longitude, lat, lng),
        bearing: _bearing(latitude, longitude, lat, lng),
      ));
    }
    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list.length > _maxResults ? list.sublist(0, _maxResults) : list;
  }

  // ============================================================
  // التخزين المؤقت (للعمل عند ضعف الشبكة)
  // ============================================================
  String _cacheId(double lat, double lng, int radius) =>
      '${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}_$radius';

  Future<void> _saveCache(
    String id,
    List<Map<String, dynamic>> raw,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // نحفظ الأقرب فقط لتقليل الحجم
      final trimmed = raw.length > 150 ? raw.sublist(0, 150) : raw;
      await prefs.setString(
        _cacheKey,
        json.encode({
          'id': id,
          'savedAt': DateTime.now().toIso8601String(),
          'items': trimmed,
        }),
      );
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>?> _loadCache(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final text = prefs.getString(_cacheKey);
      if (text == null) return null;
      final data = json.decode(text) as Map<String, dynamic>;
      if (data['id'] != id) return null;

      final savedAt = DateTime.tryParse(data['savedAt'] as String? ?? '');
      if (savedAt == null ||
          DateTime.now().difference(savedAt).inDays > 7) {
        return null;
      }
      return (data['items'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return null;
    }
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
