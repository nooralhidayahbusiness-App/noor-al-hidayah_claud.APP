/// جملة واحدة من الأذان مع توقيتها.
class AdhanPhrase {
  final String textAr;
  final String textEn;
  final int startMs;
  final int endMs;
  final int repeat; // عدد التكرارات

  const AdhanPhrase({
    required this.textAr,
    required this.textEn,
    required this.startMs,
    required this.endMs,
    this.repeat = 1,
  });

  Duration get start => Duration(milliseconds: startMs);
  Duration get end => Duration(milliseconds: endMs);
  Duration get duration => Duration(milliseconds: endMs - startMs);
}

/// التوقيتات التقريبية لجمل الأذان (لكل مؤذن).
/// تستخدم لعرض النص المتحرك أثناء تشغيل الصوت.
class AdhanTimings {
  /// التوقيتات العامة — تُستخدم كافتراضي.
  static const List<AdhanPhrase> generic = [
    AdhanPhrase(
      textAr: 'اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ',
      textEn: 'Allahu Akbar, Allahu Akbar',
      startMs: 0,
      endMs: 8000,
    ),
    AdhanPhrase(
      textAr: 'اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ',
      textEn: 'Allahu Akbar, Allahu Akbar',
      startMs: 8000,
      endMs: 16000,
    ),
    AdhanPhrase(
      textAr: 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ',
      textEn: 'Ashhadu an la ilaha illa Allah',
      startMs: 16000,
      endMs: 24000,
    ),
    AdhanPhrase(
      textAr: 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ',
      textEn: 'Ashhadu an la ilaha illa Allah',
      startMs: 24000,
      endMs: 32000,
    ),
    AdhanPhrase(
      textAr: 'أَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ اللَّهِ',
      textEn: 'Ashhadu anna Muhammadan rasul Allah',
      startMs: 32000,
      endMs: 40000,
    ),
    AdhanPhrase(
      textAr: 'أَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ اللَّهِ',
      textEn: 'Ashhadu anna Muhammadan rasul Allah',
      startMs: 40000,
      endMs: 48000,
    ),
    AdhanPhrase(
      textAr: 'حَيَّ عَلَى الصَّلَاةِ',
      textEn: 'Hayya ala as-salah',
      startMs: 48000,
      endMs: 55000,
    ),
    AdhanPhrase(
      textAr: 'حَيَّ عَلَى الصَّلَاةِ',
      textEn: 'Hayya ala as-salah',
      startMs: 55000,
      endMs: 62000,
    ),
    AdhanPhrase(
      textAr: 'حَيَّ عَلَى الْفَلَاحِ',
      textEn: 'Hayya ala al-falah',
      startMs: 62000,
      endMs: 69000,
    ),
    AdhanPhrase(
      textAr: 'حَيَّ عَلَى الْفَلَاحِ',
      textEn: 'Hayya ala al-falah',
      startMs: 69000,
      endMs: 76000,
    ),
    AdhanPhrase(
      textAr: 'اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ',
      textEn: 'Allahu Akbar, Allahu Akbar',
      startMs: 76000,
      endMs: 84000,
    ),
    AdhanPhrase(
      textAr: 'لَا إِلَهَ إِلَّا اللَّهُ',
      textEn: 'La ilaha illa Allah',
      startMs: 84000,
      endMs: 95000,
    ),
  ];

  /// التوقيتات لكل مؤذن — مختلفة حسب سرعته.
  static List<AdhanPhrase> forReciter(String id) {
    // حالياً نستخدم نفس التوقيتات العامة لكل المؤذنين.
    // يمكن لاحقاً تخصيص كل مؤذن بتوقيتاته الخاصة.
    return generic;
  }
}
