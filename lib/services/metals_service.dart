import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة جلب أسعار الذهب والفضة + أسعار الصرف مباشرة من APIs مجانية.
class MetalsService {
  MetalsService._();

  static const _goldEndpoint =
      'https://data-asg.goldprice.org/dbXRates/USD';
  static const _fxEndpoint = 'https://open.er-api.com/v6/latest/USD';
  static const _troyOunceGrams = 31.1034768;

  /// سعر الأونصة بالدولار.
  static double goldPerOunceUsd = 2650.0;
  static double silverPerOunceUsd = 31.0;

  /// خريطة أسعار الصرف: 1 USD = X من كل عملة.
  static Map<String, double> fxRates = {'USD': 1.0};

  static DateTime? lastFetch;

  // ========== سعر الجرام بعملة معينة ==========
  static double goldPerGram(String code) =>
      (goldPerOunceUsd / _troyOunceGrams) * (fxRates[code] ?? 1.0);

  static double silverPerGram(String code) =>
      (silverPerOunceUsd / _troyOunceGrams) * (fxRates[code] ?? 1.0);

  static double rate(String code) => fxRates[code] ?? 1.0;

  // ========== جلب الأسعار ==========
  static Future<bool> fetch() async {
    final prefs = await SharedPreferences.getInstance();
    // نستخدم cache لمدة 30 دقيقة.
    final lastMs = prefs.getInt('metals_last_fetch');
    if (lastMs != null &&
        DateTime.now().millisecondsSinceEpoch - lastMs <
            30 * 60 * 1000) {
      _loadFromCache(prefs);
      if (fxRates.length > 1) return true;
    }

    try {
      final results = await Future.wait([
        _fetchGoldAndSilver(),
        _fetchFx(),
      ]);
      if (!results.contains(true)) return false;

      final now = DateTime.now();
      lastFetch = now;
      await prefs.setInt('metals_last_fetch', now.millisecondsSinceEpoch);
      await prefs.setString('metals_gold', goldPerOunceUsd.toString());
      await prefs.setString('metals_silver', silverPerOunceUsd.toString());
      await prefs.setString('metals_fx', json.encode(fxRates));
      return true;
    } catch (_) {
      return false;
    }
  }

  static void _loadFromCache(SharedPreferences prefs) {
    final g = prefs.getString('metals_gold');
    final s = prefs.getString('metals_silver');
    final fx = prefs.getString('metals_fx');
    if (g != null) goldPerOunceUsd = double.tryParse(g) ?? goldPerOunceUsd;
    if (s != null) silverPerOunceUsd = double.tryParse(s) ?? silverPerOunceUsd;
    if (fx != null) {
      try {
        final m = json.decode(fx) as Map<String, dynamic>;
        fxRates = m.map((k, v) => MapEntry(k, (v as num).toDouble()));
      } catch (_) {}
    }
  }

  static Future<bool> _fetchGoldAndSilver() async {
    try {
      final res = await http.get(
        Uri.parse(_goldEndpoint),
        headers: {'User-Agent': 'Mozilla/5.0'},
      ).timeout(const Duration(seconds: 12));
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
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _fetchFx() async {
    try {
      final res = await http.get(
        Uri.parse(_fxEndpoint),
        headers: {'User-Agent': 'Mozilla/5.0'},
      ).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return false;
      final data = json.decode(res.body) as Map<String, dynamic>;
      final rates = (data['rates'] as Map?) ?? {};
      final map = <String, double>{'USD': 1.0};
      rates.forEach((k, v) {
        if (v is num) map[k.toString()] = v.toDouble();
      });
      if (map.length < 50) return false;
      fxRates = map;
      return true;
    } catch (_) {
      return false;
    }
  }
}
