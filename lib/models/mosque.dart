/// نموذج بيانات مسجد.
class Mosque {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final double distanceKm;
  final double bearing;

  const Mosque({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.bearing,
    this.address,
  });

  /// الاتجاه بالإنجليزية (N، NE، E...).
  String cardinalEn() {
    final d = ((bearing % 360) + 360) % 360;
    if (d < 22.5 || d >= 337.5) return 'N';
    if (d < 67.5) return 'NE';
    if (d < 112.5) return 'E';
    if (d < 157.5) return 'SE';
    if (d < 202.5) return 'S';
    if (d < 247.5) return 'SW';
    if (d < 292.5) return 'W';
    return 'NW';
  }

  /// الاتجاه بالعربية.
  String cardinalAr() {
    final d = ((bearing % 360) + 360) % 360;
    if (d < 22.5 || d >= 337.5) return 'شمال';
    if (d < 67.5) return 'شمال شرق';
    if (d < 112.5) return 'شرق';
    if (d < 157.5) return 'جنوب شرق';
    if (d < 202.5) return 'جنوب';
    if (d < 247.5) return 'جنوب غرب';
    if (d < 292.5) return 'غرب';
    return 'شمال غرب';
  }

  /// المسافة بصيغة نصية (متر أو كم).
  String distanceText() {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} م';
    }
    return '${distanceKm.toStringAsFixed(1)} كم';
  }
}
