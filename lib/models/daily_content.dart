/// A verse from the Quran (used for the verse of the day and the dua of the day).
class QuranEntry {
  const QuranEntry({
    required this.surahAr,
    required this.surahEn,
    required this.ayah,
    required this.text,
  });

  final String surahAr;
  final String surahEn;
  final int ayah;
  final String text;

  factory QuranEntry.fromJson(Map<String, dynamic> json) {
    return QuranEntry(
      surahAr: json['name'] as String,
      surahEn: 'Surah ${json['englishName']}',
      ayah: (json['ayah'] as num).toInt(),
      text: json['text'] as String,
    );
  }
}

class HadithEntry {
  const HadithEntry({required this.number, required this.text});

  final int number;
  final String text;

  factory HadithEntry.fromJson(Map<String, dynamic> json) {
    return HadithEntry(
      number: (json['number'] as num).toInt(),
      text: json['text'] as String,
    );
  }
}

/// The three daily lists. Every day picks the next item of each list.
class DailyContent {
  const DailyContent({
    required this.verses,
    required this.hadiths,
    required this.duas,
  });

  final List<QuranEntry> verses;
  final List<HadithEntry> hadiths;
  final List<QuranEntry> duas;

  /// رقم اليوم (منذ 1 يناير 2024) لتاريخ معيّن
  static int dayIndex(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day)
        .difference(DateTime.utc(2024, 1, 1))
        .inDays;
  }

  static int get _day => dayIndex(DateTime.now());

  QuranEntry get verseToday => verses[_day % verses.length];
  HadithEntry get hadithToday => hadiths[(_day + 7) % hadiths.length];
  QuranEntry get duaToday => duas[(_day + 13) % duas.length];

  /// آية يوم معيّن (تُستعمل لجدولة إشعارات الأيام القادمة)
  QuranEntry verseFor(DateTime date) => verses[dayIndex(date) % verses.length];
}
