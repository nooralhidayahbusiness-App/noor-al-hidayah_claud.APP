class Reciter {
  const Reciter({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.subfolder,
  });

  final String id;
  final String nameAr;
  final String nameEn;

  /// The everyayah.com folder name for this reciter's recitation.
  final String subfolder;

  /// URL of one verse's mp3 file.
  String ayahUrl(int surah, int ayah) {
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$subfolder/$s$a.mp3';
  }
}

const List<Reciter> kReciters = [
  Reciter(id: 'alafasy', nameAr: 'مشاري راشد العفاسي', nameEn: 'Mishary Alafasy', subfolder: 'Alafasy_128kbps'),
  Reciter(id: 'almuaiqly', nameAr: 'ماهر المعيقلي', nameEn: 'Maher Al-Muaiqly', subfolder: 'MaherAlMuaiqly128kbps'),
  Reciter(id: 'alsudais', nameAr: 'عبد الرحمن السديس', nameEn: 'Abdurrahman Al-Sudais', subfolder: 'Abdurrahmaan_As-Sudais_192kbps'),
  Reciter(id: 'alghamdi', nameAr: 'سعد الغامدي', nameEn: 'Saad Al-Ghamdi', subfolder: 'Ghamadi_40kbps'),
  Reciter(id: 'aldossari', nameAr: 'ياسر الدوسري', nameEn: 'Yasser Al-Dossari', subfolder: 'Yasser_Ad-Dussary_128kbps'),
  Reciter(id: 'faresabbad', nameAr: 'فارس عباد', nameEn: 'Fares Abbad', subfolder: 'Fares_Abbad_64kbps'),
  Reciter(id: 'alhussary', nameAr: 'محمود خليل الحصري', nameEn: 'Mahmoud Al-Hussary', subfolder: 'Husary_128kbps'),
  Reciter(id: 'alminshawi', nameAr: 'محمد صديق المنشاوي', nameEn: 'Al-Minshawi', subfolder: 'Minshawy_Murattal_128kbps'),
  Reciter(id: 'abdulbasit', nameAr: 'عبد الباسط عبد الصمد', nameEn: 'Abdul Basit', subfolder: 'Abdul_Basit_Murattal_192kbps'),
  Reciter(id: 'alshuraim', nameAr: 'سعود الشريم', nameEn: 'Saud Al-Shuraim', subfolder: 'Saood_ash-Shuraym_128kbps'),
  Reciter(id: 'alshatri', nameAr: 'أبو بكر الشاطري', nameEn: 'Abu Bakr Al-Shatri', subfolder: 'Abu_Bakr_Ash-Shaatree_128kbps'),
  Reciter(id: 'alajami', nameAr: 'أحمد العجمي', nameEn: 'Ahmed Al-Ajami', subfolder: 'Ahmed_ibn_Ali_al-Ajamy_64kbps_QuranExplorer.Com'),
  Reciter(id: 'alhudhaify', nameAr: 'علي الحذيفي', nameEn: 'Ali Al-Hudhaify', subfolder: 'Hudhaify_128kbps'),
  Reciter(id: 'muhammadayyoub', nameAr: 'محمد أيوب', nameEn: 'Muhammad Ayyoub', subfolder: 'Muhammad_Ayyoub_128kbps'),
];

Reciter reciterById(String id) =>
    kReciters.firstWhere((r) => r.id == id, orElse: () => kReciters.first);
