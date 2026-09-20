import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/daily_content.dart';

/// Loads the daily lists built by tool/build_daily_content.py.
class DailyContentService {
  static Future<DailyContent>? _cached;

  static Future<DailyContent> load() => _cached ??= _read();

  static Future<DailyContent> _read() async {
    final verses = await _readList('assets/data/daily_verses.json');
    final hadiths = await _readList('assets/data/daily_hadith.json');
    final duas = await _readList('assets/data/daily_duas.json');
    if (verses.isEmpty || hadiths.isEmpty || duas.isEmpty) {
      throw StateError('Daily content files are empty');
    }
    return DailyContent(
      verses: [
        for (final v in verses) QuranEntry.fromJson(v as Map<String, dynamic>),
      ],
      hadiths: [
        for (final h in hadiths) HadithEntry.fromJson(h as Map<String, dynamic>),
      ],
      duas: [
        for (final d in duas) QuranEntry.fromJson(d as Map<String, dynamic>),
      ],
    );
  }

  static Future<List<dynamic>> _readList(String path) async {
    final raw = await rootBundle.loadString(path);
    return jsonDecode(raw) as List<dynamic>;
  }
}
