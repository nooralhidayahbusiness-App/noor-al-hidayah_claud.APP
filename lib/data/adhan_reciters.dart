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
  // ============ الافتراضي ============
  AdhanReciter(
    id: 'default',
    nameAr: 'الأذان الأساسي',
    nameEn: 'Default Adhan',
    countryAr: 'أذان عام',
    countryEn: 'General',
    mp3Url: 'https://www.islamcan.com/audio/adhan/azan1.mp3',
    price: 0,
  ),

  // ============ مؤذنون جدد (من praytimes.org) ============
  AdhanReciter(
    id: 'abdulbasit',
    nameAr: 'عبد الباسط عبد الصمد',
    nameEn: 'Abdul Basit',
    countryAr: 'مصر',
    countryEn: 'Egypt',
    mp3Url: 'https://praytimes.org/audio/sunni/Abdul-Basit.mp3',
    price: 700,
    isVip: true,
  ),
  AdhanReciter(
    id: 'abdulhakam',
    nameAr: 'عبد الحكيم',
    nameEn: 'Abdul Hakam',
    countryAr: 'مصر',
    countryEn: 'Egypt',
    mp3Url: 'https://praytimes.org/audio/sunni/Abdul-Hakam.mp3',
    price: 500,
  ),
  AdhanReciter(
    id: 'alaqsa',
    nameAr: 'المسجد الأقصى',
    nameEn: 'Al-Aqsa Mosque',
    countryAr: 'فلسطين',
    countryEn: 'Palestine',
    mp3Url: 'https://praytimes.org/audio/sunni/Adhan-Alaqsa.mp3',
    price: 600,
  ),
  AdhanReciter(
    id: 'madinah',
    nameAr: 'الحرم المدني',
    nameEn: 'Madinah Haram',
    countryAr: 'السعودية',
    countryEn: 'Saudi Arabia',
    mp3Url: 'https://praytimes.org/audio/sunni/Adhan-Madinah.mp3',
    price: 500,
  ),
  AdhanReciter(
    id: 'makkah',
    nameAr: 'الحرم المكي',
    nameEn: 'Makkah Haram',
    countryAr: 'السعودية',
    countryEn: 'Saudi Arabia',
    mp3Url: 'https://praytimes.org/audio/sunni/Adhan-Makkah.mp3',
    price: 500,
  ),
  AdhanReciter(
    id: 'egypt',
    nameAr: 'الأذان المصري',
    nameEn: 'Egyptian Adhan',
    countryAr: 'مصر',
    countryEn: 'Egypt',
    mp3Url: 'https://praytimes.org/audio/sunni/Adhan-Egypt.mp3',
    price: 400,
  ),
  AdhanReciter(
    id: 'naghshbandi',
    nameAr: 'النقشبندي',
    nameEn: 'Naghshbandi',
    countryAr: 'مصر',
    countryEn: 'Egypt',
    mp3Url: 'https://praytimes.org/audio/sunni/Naghshbandi.mp3',
    price: 600,
  ),
  AdhanReciter(
    id: 'saber',
    nameAr: 'صابر',
    nameEn: 'Saber',
    countryAr: 'مصر',
    countryEn: 'Egypt',
    mp3Url: 'https://praytimes.org/audio/sunni/Saber.mp3',
    price: 400,
  ),
  AdhanReciter(
    id: 'yusufislam',
    nameAr: 'يوسف إسلام',
    nameEn: 'Yusuf Islam',
    countryAr: 'بريطانيا',
    countryEn: 'UK',
    mp3Url: 'https://praytimes.org/audio/sunni/Yusuf-Islam.mp3',
    price: 500,
  ),
];

/// البحث عن مؤذن بالمعرّف.
AdhanReciter? adhanReciterById(String id) {
  for (final r in kAdhanReciters) {
    if (r.id == id) return r;
  }
  return null;
}
