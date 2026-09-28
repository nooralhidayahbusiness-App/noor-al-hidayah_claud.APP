import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// خدمة جلب أسعار الذهب والفضة مباشرة من API مجاني (بدون مفتاح).
/// المصدر: goldprice.org (يُستخدم مجاناً للاستخدامات الشخصية).
class MetalsService {
  MetalsService._();

  static const _endpoint = 'https://data-asg.goldprice.org/dbXRates/USD';
  static const _troyOunceGrams = 31.1034768;

  static double? goldPerOunceUsd;
  static double? silverPerOunceUsd;
  static DateTime? lastFetch;

  /// سعر جرام الذهب 24K بالدولار.
  static double get goldPerGramUsd =>
      (goldPerOunceUsd ?? 2650.0) / _troyOunceGrams;

  /// سعر جرام الفضة بالدولار.
  static double get silverPerGramUsd =>
      (silverPerOunceUsd ?? 31.0) / _troyOunceGrams;

  /// جلب الأسعار. يُرجِع `true` عند النجاح.
  static Future<bool> fetch() async {
    try {
      final res = await http
          .get(
            Uri.parse(_endpoint),
            headers: {'User-Agent': 'Mozilla/5.0'},
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode != 200) return false;

      final data = json.decode(res.body) as Map<String, dynamic>;
      final items = (data['items'] as List?) ?? [];
      if (items.isEmpty) return false;

      final first = items.first as Map<String, dynamic>;
      final gold = (first['xauPrice'] as num?)?.toDouble();
      final silver = (first['xagPrice'] as num?)?.toDouble();
      if (gold == null || silver == null) return false;

      goldPerOunceUsd = gold;
      silverPerOunceUsd = silver;
      lastFetch = DateTime.now();
      return true;
    } catch (_) {
      return false;
    }
  }
}
