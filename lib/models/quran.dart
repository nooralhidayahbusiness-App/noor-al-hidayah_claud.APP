class QuranAyah {
  const QuranAyah({
    required this.number,
    required this.uthmani,
    required this.simple,
    required this.translation,
    required this.page,
    required this.juz,
  });

  final int number;
  final String uthmani;
  final String simple;
  final String translation;
  final int page;
  final int juz;

  factory QuranAyah.fromJson(Map<String, dynamic> json) {
    return QuranAyah(
      number: (json['i'] as num).toInt(),
      uthmani: json['u'] as String,
      simple: json['s'] as String,
      translation: json['t'] as String,
      page: (json['p'] as num).toInt(),
      juz: (json['j'] as num).toInt(),
    );
  }
}

class QuranSurah {
  const QuranSurah({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.meaning,
    required this.type,
    required this.count,
    required this.ayahs,
  });

  final int number;
  final String nameAr;
  final String nameEn;
  final String meaning;

  /// 'Meccan' or 'Medinan'.
  final String type;
  final int count;
  final List<QuranAyah> ayahs;

  bool get isMeccan => type == 'Meccan';

  factory QuranSurah.fromJson(Map<String, dynamic> json) {
    return QuranSurah(
      number: (json['n'] as num).toInt(),
      nameAr: json['ar'] as String,
      nameEn: json['en'] as String,
      meaning: json['mean'] as String,
      type: json['type'] as String,
      count: (json['count'] as num).toInt(),
      ayahs: [
        for (final a in json['ayahs'] as List<dynamic>)
          QuranAyah.fromJson(a as Map<String, dynamic>),
      ],
    );
  }
}

class QuranData {
  const QuranData(this.surahs);

  final List<QuranSurah> surahs;

  QuranSurah surah(int number) => surahs[number - 1];

  /// The basmalah, taken from the first verse of Al-Fatiha.
  String basmalah({required bool simple}) {
    final first = surahs.first.ayahs.first;
    return simple ? first.simple : first.uthmani;
  }
}
