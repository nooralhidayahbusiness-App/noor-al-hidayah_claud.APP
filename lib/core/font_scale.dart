import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// تفضيل المستخدم لحجم الخط (يُضرب في حجم النص الأساسي لكل التطبيق).
/// 1.0 = عادي (الحجم الافتراضي الجديد).
class FontScale extends ValueNotifier<double> {
  FontScale._() : super(1.0);

  static final FontScale instance = FontScale._();

  static const String _key = 'font_scale_factor';

  /// الخيارات المتاحة: صغير / عادي / كبير / كبير جداً
  static const List<double> options = <double>[0.85, 1.0, 1.15, 1.3];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getDouble(_key);
      if (saved != null && saved >= 0.7 && saved <= 1.6) {
        value = saved;
      }
    } catch (_) {}
  }

  Future<void> set(double factor) async {
    value = factor;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_key, factor);
    } catch (_) {}
  }
}

final FontScale fontScale = FontScale.instance;
