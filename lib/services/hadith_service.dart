import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/hadith_section.dart';

class HadithService {
  static Future<List<HadithSection>>? _cached;

  static Future<List<HadithSection>> load() => _cached ??= _read();

  static Future<List<HadithSection>> _read() async {
    final raw = await rootBundle.loadString('assets/data/hadith_sections.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return [for (final s in json['sections'] as List<dynamic>) HadithSection.fromJson(s as Map<String, dynamic>)];
  }
}
