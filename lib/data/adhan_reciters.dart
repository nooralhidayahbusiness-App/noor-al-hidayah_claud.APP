/// نموذج بيانات مؤذن.
class AdhanReciter {
  final String id;
  final String nameAr;
  final String nameEn;
  final String countryAr;
  final String countryEn;
  final String mp3Url;
  final int price;
  final bool isVip;

  const AdhanReciter({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.countryAr,
    required this.countryEn,
    required this.mp3Url,
    required this.price,
    this.isVip = false,
  });
}

/// قائمة المؤذنين — روابط MP3 مباشرة مجانية.
const List<AdhanReciter> kAdhanReciters = [
  AdhanReciter(
    id: 'default',
    nameAr: 'الأذان الأساسي',
    nameEn: 'Default Adhan',
    countryAr: 'أذان عام',
    countryEn: 'General',
    mp3Url:
        'https://www.islamcan.com/audio/adhan/azan1.mp3',
    price: 0,
  ),
  AdhanReciter(
    id: 'makkah',
    nameAr: 'الحرم المكي',
    nameEn: 'Makkah Haram',
    countryAr: 'السعودية',
    countryEn: 'Saudi Arabia',
    mp3Url:
        'https://www.islamcan.com/audio/adhan/azan2.mp3',
    price: 500,
  ),
  AdhanReciter(
    id: 'madinah',
    nameAr: 'الحرم المدني',
    nameEn: 'Madinah Haram',
    countryAr: 'السعودية',
    countryEn: 'Saudi Arabia',
    mp3Url:
        'https://www.islamcan.com/audio/adhan/azan3.mp3',
    price: 500,
  ),
  AdhanReciter(
    id: 'egypt',
    nameAr: 'الأذان المصري',
    nameEn: 'Egyptian Adhan',
    countryAr: 'مصر',
    countryEn: 'Egypt',
    mp3Url:
        'https://www.islamcan.com/audio/adhan/azan4.mp3',
    price: 400,
  ),
  AdhanReciter(
    id: 'turkey',
    nameAr: 'الأذان التركي',
    nameEn: 'Turkish Adhan',
    countryAr: 'تركيا',
    countryEn: 'Turkey',
    mp3Url:
        'https://www.islamcan.com/audio/adhan/azan5.mp3',
    price: 400,
  ),
  AdhanReciter(
    id: 'morocco',
    nameAr: 'الأذان المغربي',
    nameEn: 'Moroccan Adhan',
    countryAr: 'المغرب',
    countryEn: 'Morocco',
    mp3Url:
        'https://www.islamcan.com/audio/adhan/azan6.mp3',
    price: 400,
  ),
  AdhanReciter(
    id: 'yemen',
    nameAr: 'الأذان اليمني',
    nameEn: 'Yemeni Adhan',
    countryAr: 'اليمن',
    countryEn: 'Yemen',
    mp3Url:
        'https://www.islamcan.com/audio/adhan/azan7.mp3',
    price: 300,
  ),
  AdhanReciter(
    id: 'egypt_old',
    nameAr: 'الأذان المصري التقليدي',
    nameEn: 'Classic Egyptian Adhan',
    countryAr: 'مصر',
    countryEn: 'Egypt',
    mp3Url:
        'https://www.islamcan.com/audio/adhan/azan8.mp3',
    price: 600,
  ),
  AdhanReciter(
    id: 'syria',
    nameAr: 'الأذان الشامي',
    nameEn: 'Levantine Adhan',
    countryAr: 'سوريا',
    countryEn: 'Syria',
    mp3Url:
        'https://www.islamcan.com/audio/adhan/azan9.mp3',
    price: 500,
  ),
  AdhanReciter(
    id: 'fajr_egypt',
    nameAr: 'أذان الفجر المصري',
    nameEn: 'Egyptian Fajr Adhan',
    countryAr: 'مصر',
    countryEn: 'Egypt',
    mp3Url:
        'https://www.islamcan.com/audio/adhan/azan10.mp3',
    price: 700,
  ),
];

/// البحث عن مؤذن بالمعرّف.
AdhanReciter? adhanReciterById(String id) {
  for (final r in kAdhanReciters) {
    if (r.id == id) return r;
  }
  return null;
}
