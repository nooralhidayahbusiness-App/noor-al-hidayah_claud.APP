import 'dart:math' as math;

/// حساب اتجاه القبلة والمسافة إلى مكة المكرمة.
class QiblaService {
  QiblaService._();

  /// إحداثيات الكعبة المشرفة.
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  /// يحسب زاوية القبلة بالدرجات من الشمال (0-360).
  static double qiblaDirection({
    required double latitude,
    required double longitude,
  }) {
    final lat1 = _toRad(latitude);
    final lat2 = _toRad(kaabaLat);
    final dLng = _toRad(kaabaLng - longitude);

    final y = math.sin(dLng);
    final x = math.cos(lat1) * math.tan(lat2) - math.sin(lat1) * math.cos(dLng);

    final bearing = math.atan2(y, x);
    return (_toDeg(bearing) + 360) % 360;
  }

  /// المسافة إلى مكة بالكيلومترات (Haversine).
  static double distanceToKaaba({
    required double latitude,
    required double longitude,
  }) {
    const R = 6371.0; // نصف قطر الأرض بالكيلومتر

    final dLat = _toRad(kaabaLat - latitude);
    final dLng = _toRad(kaabaLng - longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(latitude)) *
            math.cos(_toRad(kaabaLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  /// اسم الاتجاه بالعربية (شمال، جنوب، شرق، غرب...).
  static String cardinalAr(double degrees) {
    final d = ((degrees % 360) + 360) % 360;
    if (d < 22.5 || d >= 337.5) return 'شمال';
    if (d < 67.5) return 'شمال شرق';
    if (d < 112.5) return 'شرق';
    if (d < 157.5) return 'جنوب شرق';
    if (d < 202.5) return 'جنوب';
    if (d < 247.5) return 'جنوب غرب';
    if (d < 292.5) return 'غرب';
    return 'شمال غرب';
  }

  static String cardinalEn(double degrees) {
    final d = ((degrees % 360) + 360) % 360;
    if (d < 22.5 || d >= 337.5) return 'N';
    if (d < 67.5) return 'NE';
    if (d < 112.5) return 'E';
    if (d < 157.5) return 'SE';
    if (d < 202.5) return 'S';
    if (d < 247.5) return 'SW';
    if (d < 292.5) return 'W';
    return 'NW';
  }

  static double _toRad(double d) => d * math.pi / 180.0;
  static double _toDeg(double r) => r * 180.0 / math.pi;
}
