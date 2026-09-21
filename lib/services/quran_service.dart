import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/quran.dart';

/// Loads the whole Quran built by tool/build_quran_data.py.
class QuranService {
  static Future<QuranData>? _cached;

  static Future<QuranData> load() => _cached ??= _read();

  static Future<QuranData> _read() async {
    final raw = await rootBundle.loadString('assets/data/quran.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final surahs = [
      for (final s in json['surahs'] as List<dynamic>)
        QuranSurah.fromJson(s as Map<String, dynamic>),
    ];
    if (surahs.length != 114) {
      throw StateError('Quran data is incomplete');
    }
    return QuranData(surahs);
  }
}
