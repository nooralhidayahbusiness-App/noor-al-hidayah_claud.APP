import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// The tafsir of every verse, in Arabic and English.
class TafsirData {
  const TafsirData({
    required this.arName,
    required this.enName,
    required this.ar,
    required this.en,
  });

  final String arName;
  final String enName;
  final List<List<String>> ar;
  final List<List<String>> en;

  /// The tafsir of one verse (empty when it is explained with its neighbours).
  String textFor({
    required bool arabic,
    required int surah,
    required int ayah,
  }) {
    final table = arabic ? ar : en;
    if (surah < 1 || surah > table.length) return '';
    final list = table[surah - 1];
    if (ayah < 1 || ayah > list.length) return '';
    return list[ayah - 1];
  }

  String sourceName(bool arabic) => arabic ? arName : enName;
}

/// Loads assets/data/tafsir.json (built by tool/build_tafsir_data.py).
class TafsirService {
  static Future<TafsirData>? _cached;

  /// Available right away once [load] has finished.
  static TafsirData? cachedData;

  static Future<TafsirData> load() => _cached ??= _read();

  static Future<TafsirData> _read() async {
    final raw = await rootBundle.loadString('assets/data/tafsir.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;

    List<List<String>> table(Map<String, dynamic> part) {
      return [
        for (final surah in part['surahs'] as List<dynamic>)
          [for (final text in surah as List<dynamic>) text as String],
      ];
    }

    final ar = json['ar'] as Map<String, dynamic>;
    final en = json['en'] as Map<String, dynamic>;
    final data = TafsirData(
      arName: ar['name'] as String,
      enName: en['name'] as String,
      ar: table(ar),
      en: table(en),
    );
    cachedData = data;
    return data;
  }
}
