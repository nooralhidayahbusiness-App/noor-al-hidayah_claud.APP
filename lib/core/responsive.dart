import 'package:flutter/material.dart';

/// أحجام متجاوبة — تتناسب مع عرض الشاشة.
class R {
  R._();

  /// معامل التصغير حسب عرض الشاشة:
  /// - حاسوب (≥ 1000px) → 1.00
  /// - تابلت (≥ 700px) → 0.90
  /// - جوال كبير (≥ 500px) → 0.82
  /// - جوال صغير (< 500px) → 0.74
  static double scale(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w >= 1000) return 1.00;
    if (w >= 700) return 0.90;
    if (w >= 500) return 0.82;
    return 0.74;
  }

  /// حجم مُصغّر.
  static double s(BuildContext c, double base) => base * scale(c);

  /// حجم خط مُصغّر.
  static double f(BuildContext c, double base) => base * scale(c);
}
