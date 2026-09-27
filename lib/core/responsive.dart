import 'package:flutter/material.dart';

/// أحجام متجاوبة — صغيرة ومتناسقة للجوال والحاسوب.
class R {
  R._();

  /// معامل التصغير:
  /// - حاسوب (≥ 1000px) → 0.78
  /// - تابلت (≥ 700px) → 0.62
  /// - جوال كبير (≥ 500px) → 0.50
  /// - جوال صغير (< 500px) → 0.44
  static double scale(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w >= 1000) return 0.78;
    if (w >= 700) return 0.62;
    if (w >= 500) return 0.50;
    return 0.44;
  }

  static double s(BuildContext c, double base) => base * scale(c);
  static double f(BuildContext c, double base) => base * scale(c);
}
