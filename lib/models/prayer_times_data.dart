class PrayerTimesData {
  const PrayerTimesData({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriAr,
    required this.hijriEn,
  });

  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String hijriAr;
  final String hijriEn;

  /// The five daily prayers in order (sunrise is not a prayer).
  List<MapEntry<String, String>> get prayers => [
        MapEntry('fajr', fajr),
        MapEntry('dhuhr', dhuhr),
        MapEntry('asr', asr),
        MapEntry('maghrib', maghrib),
        MapEntry('isha', isha),
      ];

  factory PrayerTimesData.fromApi(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final timings = data['timings'] as Map<String, dynamic>;

    String time(String key) {
      final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch('${timings[key]}');
      if (match == null) throw FormatException('Bad time for $key');
      return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
    }

    var hijriAr = '';
    var hijriEn = '';
    // The hijri date is optional: if anything is missing we simply skip it.
    try {
      final date = data['date'] as Map<String, dynamic>;
      final hijri = date['hijri'] as Map<String, dynamic>;
      final month = hijri['month'] as Map<String, dynamic>;
      final weekday = hijri['weekday'] as Map<String, dynamic>;
      hijriAr =
          '${weekday['ar']}، ${hijri['day']} ${month['ar']} ${hijri['year']} هـ';
      hijriEn =
          '${_englishWeekday(date)}, ${hijri['day']} ${month['en']} ${hijri['year']} AH';
    } catch (_) {}

    return PrayerTimesData(
      fajr: time('Fajr'),
      sunrise: time('Sunrise'),
      dhuhr: time('Dhuhr'),
      asr: time('Asr'),
      maghrib: time('Maghrib'),
      isha: time('Isha'),
      hijriAr: hijriAr,
      hijriEn: hijriEn,
    );
  }
}


/// English weekday name (Sunday, Monday ...). The API's own English weekday
/// for the hijri date is a transliteration ("Al Ahad"), so we use the
/// gregorian one, and fall back to the device date.
String _englishWeekday(Map<String, dynamic> date) {
  const names = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  try {
    final gregorian = date['gregorian'] as Map<String, dynamic>;
    final weekday = gregorian['weekday'] as Map<String, dynamic>;
    final english = weekday['en'] as String?;
    if (english != null && english.isNotEmpty) return english;
  } catch (_) {}
  return names[DateTime.now().weekday - 1];
}
