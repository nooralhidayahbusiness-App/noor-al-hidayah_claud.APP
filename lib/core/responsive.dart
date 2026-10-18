import 'package:flutter/material.dart';

/// أحجام متجاوبة — قيم وسطى جميلة للجوال والحاسوب.
class R {
  R._();

  /// معامل تصغير الأبعاد (المسافات والأيقونات والأحجام):
  /// - حاسوب (≥ 1000px) → 0.88
  /// - تابلت (≥ 700px) → 0.78
  /// - جوال كبير (≥ 500px) → 0.68
  /// - جوال صغير (< 500px) → 0.62
  static double scale(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w >= 1000) return 0.88;
    if (w >= 700) return 0.78;
    if (w >= 500) return 0.68;
    return 0.62;
  }

  /// ✅ معامل الخطوط (أكبر من معامل الأبعاد حتى تكون النصوص أوضح):
  /// كان 0.62 على الجوال، صار 0.78 (+26% تقريباً).
  static double fontScale(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w >= 1000) return 0.98;
    if (w >= 700) return 0.92;
    if (w >= 500) return 0.86;
    return 0.78;
  }

  static double s(BuildContext c, double base) => base * scale(c);
  static double f(BuildContext c, double base) => base * fontScale(c);
}
