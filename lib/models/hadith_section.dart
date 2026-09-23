class HadithItem {
  const HadithItem({required this.arabic, required this.english, required this.chapter, this.number});
  final String arabic;
  final String english;
  final String chapter;
  final int? number;

  factory HadithItem.fromJson(Map<String, dynamic> json) {
    return HadithItem(
      arabic: json['ar'] as String,
      english: json['en'] as String,
      chapter: json['chapter'] as String,
      number: (json['number'] as num?)?.toInt(),
    );
  }
}

class HadithSection {
  const HadithSection({required this.id, required this.nameAr, required this.nameEn, required this.hadiths});
  final String id;
  final String nameAr;
  final String nameEn;
  final List<HadithItem> hadiths;

  factory HadithSection.fromJson(Map<String, dynamic> json) {
    return HadithSection(
      id: json['id'] as String,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      hadiths: [for (final h in json['hadiths'] as List<dynamic>) HadithItem.fromJson(h as Map<String, dynamic>)],
    );
  }
}
